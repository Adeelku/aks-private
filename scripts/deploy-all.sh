##!/usr/bin/env bash
set -e
. ./params.sh

echo "configuring Networking"
## create Resource Group for Users VNet
az group create --name $USERS_RG --location $LOCATION

## Create USERS VNet and SubNet
az network vnet create \
    -g $USERS_RG \
    -n $USERS_VNET --address-prefix $USERS_VNET_CIDR \
    --subnet-name $USERS_SNET --subnet-prefix $USERS_SNET_CIDR

## create Resource Group for AKS VNet
az group create --name $AKS_VNET_RG --location $LOCATION

## Create AKS VNet and SubNet
az network vnet create \
    -g $AKS_VNET_RG \
    -n $AKS_VNET --address-prefix $AKS_VNET_CIDR \
    --subnet-name $AKS_SNET --subnet-prefix $AKS_SNET_CIDR

echo ""
echo "configuring Peering"
VNET_SOURCE_ID=$(az network vnet show \
    --resource-group $VNET_SOURCE_RG \
    --name $VNET_SOURCE \
    --query id -o tsv)
VNET_DEST_ID=$(az network vnet show \
    --resource-group $VNET_DEST_RG \
    --name $VNET_DEST \
    --query id -o tsv)

az network vnet peering create \
    --resource-group $VNET_SOURCE_RG -n "${VNET_SOURCE}-to-${VNET_DEST}" \
    --vnet-name $VNET_SOURCE \
    --remote-vnet $VNET_DEST_ID \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $VNET_DEST_RG -n "${VNET_DEST}-to-${VNET_SOURCE}" \
    --vnet-name $VNET_DEST \
    --remote-vnet $VNET_SOURCE_ID \
    --allow-vnet-access

echo ""
echo "configuring Private AKS"
## get subnet info
echo "Getting Subnet ID"
AKS_SNET_ID=$(az network vnet subnet show \
  --resource-group $AKS_VNET_RG \
  --vnet-name $AKS_VNET \
  --name $AKS_SNET \
  --query id -o tsv)

### create private aks cluster
echo "Creating Private AKS Cluster RG"
az group create --name $RG_NAME --location $LOCATION
echo "Creating Private AKS Cluster"
az aks create --resource-group $RG_NAME --name $CLUSTER_NAME \
  --kubernetes-version $VERSION \
  --location $LOCATION \
  --enable-private-cluster \
  --node-vm-size $NODE_SIZE \
  --load-balancer-sku standard \
  --node-count $NODE_COUNT --node-osdisk-size $NODE_DISK_SIZE \
  --network-plugin $CNI_PLUGIN \
  --vnet-subnet-id $AKS_SNET_ID \
  --docker-bridge-address 172.17.0.1/16 \
  --dns-service-ip 10.2.0.10 \
  --service-cidr 10.2.0.0/24 

## Configure Private DNS Link to Jumpbox VM
echo ""
echo "Configuring Private DNS Link to Jumpbox VM"

noderg=$(az aks show --name $CLUSTER_NAME \
    --resource-group $RG_NAME \
    --query 'nodeResourceGroup' -o tsv) 

dnszone=$(az network private-dns zone list \
    --resource-group $noderg \
    --query [0].name -o tsv)

az network private-dns link vnet create \
    --name "${USERS_VNET}-${USERS_RG}" \
    --resource-group $noderg \
    --virtual-network $VNET_DEST_ID \
    --zone-name $dnszone \
    --registration-enabled false

echo ""
echo "configuring Jumbox VM"
## create subnet for vm
echo "Creating Jumpbox subnet"
az network vnet subnet create \
    --name $VM_SNET \
    --resource-group $USERS_RG \
    --vnet-name $VM_VNET \
    --address-prefix $VM_SNET_CIDR

## get subnet info
echo "Getting Subnet ID"
SNET_ID=$(az network vnet subnet show \
  --resource-group $USERS_RG \
  --vnet-name $VM_VNET \
  --name $VM_SNET \
  --query id -o tsv)

## create public ip
echo "Creating VM public IP"
az network public-ip create \
    --resource-group $VM_RG \
    --name $VM_PUBIP \
    --allocation-method dynamic \
    --sku basic

## create vm
echo "Creating the VM"
az vm create \
    --resource-group $VM_RG \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --size $VM_SIZE \
    --os-disk-size-gb $VM_OSD_SIZE \
    --subnet $SNET_ID \
    --public-ip-address $VM_PUBIP \
    --admin-username azureuser \
    --generate-ssh-keys

## connect to vm
PUBLIC_IP=$(az network public-ip show -n $VM_PUBIP -g $VM_RG --query ipAddress -o tsv)
ssh azureuser@$PUBLIC_IP -i ~/.ssh/id_rsa

## install AZ CLI
sudo az aks install-cli
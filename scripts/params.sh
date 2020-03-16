## AKS
LOCATION="canadacentral"
RG_NAME="aks-private-rg"
CLUSTER_NAME="aks-private"
NODE_SIZE="Standard_B2s"
NODE_COUNT="1"
NODE_DISK_SIZE="30"
VERSION="1.16.7"
CNI_PLUGIN="kubenet"

## Networking
AKS_VNET="vnet-private-aks"
AKS_VNET_RG="net-private-rg"
AKS_VNET_CIDR="10.10.0.0/16"
AKS_SNET="aks-subnet"
AKS_SNET_CIDR="10.10.0.0/24"
USERS_VNET="vnet-users"
USERS_RG="users-rg"
USERS_VNET_CIDR="10.100.0.0/16"
USERS_SNET="users-subnet"
USERS_SNET_CIDR="10.100.100.0/24"

##Peering
VNET_SOURCE_RG=$AKS_VNET_RG
VNET_SOURCE=$AKS_VNET
VNET_DEST_RG=$USERS_RG
VNET_DEST=$USERS_VNET

## Jumpbox VM
VM_NAME="vm-jumpbox"
VM_IMAGE="UbuntuLTS"
VM_SIZE="Standard_B1s"
VM_OSD_SIZE="32"
VM_RG=$USERS_RG
VM_VNET=$USERS_VNET
VM_SNET="jumpbox-subnet"
VM_SNET_CIDR="10.100.110.0/28"
VM_PUBIP="vm-jumpbox-pip"

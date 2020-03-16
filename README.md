# Create AKS Private Cluster 

For more details, check the following blog post on [atouati.com](https://atouati.com/posts/2020/03/aks-private-cluster/) 

## Prerequisites

* The Azure CLI version 2.2.0 or later

## Creating a Private AKS Cluster

Executing ./scripts/deploy-all.sh script will automatically provision the following resources using variables that you define in ./scripts/params.sh:

* Networking
  * Create the Users Vnet and subnet
  * Create the AKS Vnet and subnet
  * Create peering between both Vnets
* Create AKS Private Cluster
* Configure Private DNS Link tUsers Vnet 
  * Enable jumbox to resolve API Server's Private Endpoint IP
* Jumbox VM
  * Create a subnet for the VM in the Users Vnet
  * Create the Linux Jumpbox VM
  * SSH to the VM

## Accessing the API Server privately

When the cluster and its supporting resources are created, you will automatically SSH to the jumbox using your SSH Key 

* install AZ CLI

Follow these [instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest#manual-install-instructions) to install AZ CLI on the jumpbox

* Install Kubectl

```bash
sudo az aks install-cli
```

* Configure Connection to the API server

```bash
az aks get-credentials -g <aks-rg> -n <cluster-name>
```

* check the connection


```bash
kubectl get nodes
```

The following example output shows the single node created in the previous steps. Make sure that the status of the node is Ready:

```bash
NAME                       STATUS   ROLES   AGE     VERSION
aks-nodepool1-31718369-0   Ready    agent   6m44s   v1.16.7
```



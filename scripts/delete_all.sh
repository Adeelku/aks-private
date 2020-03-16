##!/usr/bin/env bash

set -e
. ./params.sh

## remove jumpbox
# az group delete -y -n $USERS_RG
 
## remove Private AKS
# az group delete -y -n $RG_NAME

## remove VNET
# az group delete -y -n $AKS_VNET_RG

#!/bin/sh

# https://learn.microsoft.com/en-us/azure/bastion/connect-native-client-windows#connect-tunnel

set SUBSCRIPTIONID=

az login
az account list
az account set --subscription "$SUBSCRIPTIONID"

az network bastion tunnel --name "devnet-bastion" --resource-group "dev" --target-resource-id "/subscriptions/$SUBSCRIPTIONID/resourceGroups/dev/providers/Microsoft.Compute/virtualMachines/vm1" --resource-port "3389" --port "33389"
// Creates a virtual network
@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object = {}

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Group ID of the network security group')
param networkSecurityGroupId string

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Dev subnet address prefix')
param devSubnetPrefix string = '10.10.0.0/24'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      { 
        name: 'dev'
        properties: {
          addressPrefix: devSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.ContainerRegistry'
            }
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
    ]
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name

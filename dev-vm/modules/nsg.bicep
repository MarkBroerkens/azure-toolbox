// Creates a network security group preconfigured for use with Azure ML
// To learn more, see https://docs.microsoft.com/en-us/azure/machine-learning/how-to-access-azureml-behind-firewall
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the network security group')
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          }   
      }
    ]
  }
}

output networkSecurityGroup string = nsg.id

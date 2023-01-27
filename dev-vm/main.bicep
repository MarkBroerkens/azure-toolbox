// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up

// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string = 'mark'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Dev subnet address prefix')
param devSubnetPrefix string = '10.10.0.0/24'

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Bastion subnet address prefix')
param azureBastionSubnetPrefix string = '10.10.250.0/27'




//@description('VM size for the default compute cluster')
//param amlComputeDefaultVmSize string = 'Standard_DS3_v2'

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Virtual network and network security group
module nsg 'modules/nsg.bicep' = { 
  name: 'nsg-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags 
    nsgName: 'nsg-${name}-${uniqueSuffix}'
  }
}

module vnet 'modules/vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vnetAddressPrefix: vnetAddressPrefix
    devSubnetPrefix: devSubnetPrefix
    tags: tags
  }
  dependsOn: [
    nsg
  ]
}

// Dependent resources for the Azure Machine Learning workspace
module vm 'modules/vm.bicep' = {
  name: 'vm-${name}-${uniqueSuffix}-deployment'
  params: {
    vmName: 'vm-${name}-${uniqueSuffix}'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: '${vnet.outputs.id}/subnets/dev'
  }
  dependsOn: [
    vnet
  ]
}

// Dependent resources for the Azure Machine Learning workspace
module keyvault 'modules/keyvault.bicep' = {
  name: 'kv-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    keyvaultPleName: 'ple-${name}-${uniqueSuffix}-kv'
    subnetId: '${vnet.outputs.id}/subnets/dev'
    virtualNetworkId: vnet.outputs.id
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}


// Dependent resources for the Azure Machine Learning workspace
module storage 'modules/storage.bicep' = {
  name: 'st-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st-${name}-${uniqueSuffix}'
    storagePleBlobName: 'ple-${name}-${uniqueSuffix}-st-blob'
    storagePleFileName: 'ple-${name}-${uniqueSuffix}-st-file'
    storageSkuName: 'Standard_LRS'
    subnetId: '${vnet.outputs.id}/subnets/dev'
    virtualNetworkId: vnet.outputs.id
    tags: tags
  }
  dependsOn: [
    vnet
  ]
}

module bastion 'modules/bastion.bicep' = {
  name: 'bas-${name}-${uniqueSuffix}-deployment'
  params: {
    bastionHostName: 'bas-${name}-${uniqueSuffix}'
    location: location
    vnetName: vnet.outputs.name
    addressPrefix: azureBastionSubnetPrefix
  }
  dependsOn: [
    vnet
  ]
}

output storageName string = storage.outputs.storageId
output vmName string = vm.outputs.vmName


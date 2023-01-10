
param acrName string 

@description('ACR tier, e.g. Basic')
param acrSku string

param acrLocation string = resourceGroup().location

var acrNameUnique = '${acrName}${uniqueString(resourceGroup().id)}'

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrNameUnique
  location: acrLocation
  sku: {
  name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}


param acrName string

@description('ACR tier, e.g. Basic')
param acrSku string

param acrLocation string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: acrLocation
  sku: {
  name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

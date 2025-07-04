param location string 
param projectName string 
param linuxFxVersion string = 'DOCKER|nginx:latest'
param postgresConnectionString string
param keyVaultName string
param subnetAppId string // Subnet ID for App Service VNet integration
param signalrConnectionString string
param appInsightsConnectionString string

// 1) App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${projectName}-plan'
  location: location
  sku: { name: 'P0v3', tier: 'PremiumV3', capacity: 1 }
  properties: {
    reserved: true // Set to true for Linux plans
    zoneRedundant : false // Not zone redundant
  }
}

// 2) App Service with Managed Identity
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${projectName}-api'
  location: location
  kind: 'app,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: { 
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'Azure__SignalR__ConnectionString'
          value: signalrConnectionString
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ]
     }
    httpsOnly: true
  }
}

// 3) Storage Account for Blob Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${projectName}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

 
// 4) Grant “Storage Blob Data Contributor” on your Storage Account
resource blobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appService.id, 'blobDataContributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'  // Storage Blob Data Contributor
    )
    principalId: appService.identity.principalId
  }
}

// VNet Integration
resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2022-03-01' = {
  name: 'vnet'
  parent: appService
  properties: { vnetResourceId: subnetAppId, isSwift: true }
}

// 5) Inject the Storage connection string into App Settings
//    ARM will retrieve the primary key at deploy-time.
var storageConnString = storageAccount.listKeys().keys[0].value

resource appSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    BlobStorageConnectionString: storageConnString
    PostgresConnectionString: postgresConnectionString
  }
}

// Reference the Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

// Role assignment: allow app's managed identity to read secrets from Key Vault
resource keyVaultReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appService.id, 'keyvault-reader')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets User
    principalId: appService.identity.principalId
  }
}

output appServiceDefaultHost string = appService.properties.defaultHostName

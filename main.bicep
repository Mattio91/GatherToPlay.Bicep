param location string = resourceGroup().location
param projectName string = 'gathertoplay'
param keyVaultName string

param postgresAdminUser string
param postgresAdminPasswordSecretName string


param linuxFxVersion string = 'DOCKER|nginx:latest'



resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}


module vnetMod './modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    projectName: projectName
  }
}

module postgresMod './modules/postgres.bicep' = {
  name: 'postgres'
  params: {
    location: location
    projectName: projectName
    subnetDbId: vnetMod.outputs.subnetDbId
    dnsZoneId: vnetMod.outputs.dnsZoneId
    dbAdminUser: postgresAdminUser
    keyVaultId: keyVault.id
    dbAdminPasswordSecretName: postgresAdminPasswordSecretName
  }
}

module signalrMod './modules/signalr.bicep' = {
  name: 'signalr'
  params: {
    location: location
    projectName: projectName
  }
}

module appinsightsMod './modules/appinsights.bicep' = {
  name: 'appinsights'
  params: {
    location: location
    projectName: projectName
  }
}


module staticwebapp './modules/staticwebapp.bicep' = {
  name: 'staticWebApp'
  params: {
    location: location
    projectName: projectName
  }
}

module appserviceMod './modules/appservice.bicep' = {
  name: 'appservice'
  params: {
    location: location
    projectName: projectName
    subnetAppId: vnetMod.outputs.subnetAppId
    postgresConnectionString: postgresMod.outputs.postgresConnectionString
    keyVaultName: keyVaultName
    linuxFxVersion: linuxFxVersion
    signalrConnectionString: listKeys(signalrMod.name, '2022-02-01').primaryConnectionString
    appInsightsConnectionString: appinsightsMod.outputs.appInsightsConnectionString
  }
}


module frontdoorMod './modules/frontdoor.bicep' = {
  name: 'frontdoor'
  params: {
    location: location
    projectName: projectName
    frontendHost: staticwebapp.outputs.defaultHostName // e.g. gathertoplay-frontend.azurestaticapps.net
    backendApiHost: appserviceMod.outputs.appServiceDefaultHost // e.g. gathertoplay-api.azurewebsites.net
  }
}

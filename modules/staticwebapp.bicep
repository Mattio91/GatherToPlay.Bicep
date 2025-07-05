param location string = resourceGroup().location
param projectName string = 'gathertoplay'

resource staticWebApp 'Microsoft.Web/staticSites@2024-11-01' = {
  name: '${projectName}-frontend'
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
}

output defaultHostName string = staticWebApp.properties.defaultHostname

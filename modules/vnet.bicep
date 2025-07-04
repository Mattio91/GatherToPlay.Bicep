param location string
param projectName string

var vnetName = '${projectName}-vnet'
var subnetDbName = 'db'
var subnetAppName = 'appsvc'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.1.0.0/16' ] }
    subnets: [
      {
        name: subnetDbName
        properties: {
          addressPrefix: '10.1.1.0/24'
          delegations: [
            {
              name: 'dbDelegation'
              properties: { serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers' }
            }
          ]
        }
      }
      {
        name: subnetAppName
        properties: { addressPrefix: '10.1.2.0/24' }
      }
    ]
  }
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.postgres.database.azure.com'
  location: 'global'
}

resource dnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnsZone.name}-link'
  parent: dnsZone
  location: 'global'
  properties: {
    virtualNetwork: { id: vnet.id }
    registrationEnabled: false
  }
}

// Output subnet resource IDs the correct way:
output subnetDbId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetDbName)
output subnetAppId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetAppName)
output vnetName string = vnet.name
output dnsZoneId string = dnsZone.id

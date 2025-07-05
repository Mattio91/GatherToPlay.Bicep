param location string
param projectName string
param subnetDbId string
param dnsZoneId string
param dbAdminUser string
param keyVaultId string
param dbAdminPasswordSecretName string

var postgresServerName = '${projectName}-pg'
var postgresDbName = 'gathertoplay'

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: postgresServerName
  location: location
  properties: {
    version: '15'
    administratorLogin: dbAdminUser
    administratorLoginPassword: listSecret('${keyVaultId}/secrets/${dbAdminPasswordSecretName}', '2015-06-01').value
    storage: { storageSizeGB: 32 }
    network: {
      delegatedSubnetResourceId: subnetDbId
      privateDnsZoneArmResourceId: dnsZoneId
    }
    highAvailability: { mode: 'Disabled' }
    backup: { backupRetentionDays: 7, geoRedundantBackup: 'Disabled' }
    createMode: 'Default'
  }
  sku: {
      name: 'B_Standard_B1ms'
      tier: 'Burstable'
    }
}

resource pgDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  name: postgresDbName
  parent: postgres
}

output serverName string = postgres.name
output dbName string = postgresDbName
output adminUser string = dbAdminUser
output dbHost string = '${postgres.name}.postgres.database.azure.com'
output postgresConnectionString string = 'Host=${postgres.name}.postgres.database.azure.com;Database=${postgresDbName};Username=${dbAdminUser}@${postgres.name};Password=@Microsoft.KeyVault(SecretUri=${reference(keyVaultId).vaultUri}secrets/${dbAdminPasswordSecretName}/);Port=5432;SSL Mode=Require'


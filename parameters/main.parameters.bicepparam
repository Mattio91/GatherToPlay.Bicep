using '../main.bicep'

param location = 'swedencentral'

param projectName = 'gathertoplay'

param postgresAdminUser = 'sqladminuser'

param linuxFxVersion = 'DOCKER|nginx:latest'

param keyVaultName = 'prod-gather-keyvault'

param postgresAdminPasswordSecretName = 'prod-gather-postgres-key'

param locationStaticWeb = 'westeurope'

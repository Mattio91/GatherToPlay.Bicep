using '../main.bicep'

param location = 'westeurope'

param projectName = 'gathertoplay'

param postgresAdminUser = 'sqladminuser'

param linuxFxVersion = 'DOCKER|nginx:latest'

param keyVaultName = 'prod-gather-keyvault'

param postgresAdminPasswordSecretName = 'prod-gather-postgres-key'

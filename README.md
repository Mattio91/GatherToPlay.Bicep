# GatherToPlay Bicep Project

This project contains Bicep templates for deploying Azure resources for the GatherToPlay application. The structure is organized to separate the main Bicep file from individual resource modules, facilitating easier management and maintenance of the infrastructure as code.

## Project Structure

- **main.bicep**: The main Bicep template for deploying resources. It defines the parameters and resources for the Azure infrastructure.
  
- **parameters**:
  - **main.parameters.json**: Contains parameter values for the development environment, providing specific configurations for Bicep deployments.

- **modules**:
  - **frontend.bicep**: Defines resources for the Azure Static Web App, including configuration and settings.
  - **backend.bicep**: Defines resources for the Azure App Service, including the app service plan and web app configuration.
  - **database.bicep**: Defines resources for the Azure SQL Database, including server and database configurations.
  - **cosmosdb.bicep**: Defines resources for the Azure Cosmos DB account, including settings and capabilities.
  - **storage.bicep**: Defines resources for the Azure Storage Account, including configuration and settings.
  - **signalr.bicep**: Defines resources for the Azure SignalR Service, including configuration and pricing tier.
  - **monitoring.bicep**: Defines resources for Azure Application Insights, including configuration for monitoring and diagnostics.

## Usage

To deploy the infrastructure, use the main Bicep file along with the appropriate parameter files for your environment. Each module can be modified independently to cater to specific resource requirements.
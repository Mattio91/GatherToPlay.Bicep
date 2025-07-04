param location string
param projectName string

resource signalr 'Microsoft.SignalRService/SignalR@2022-02-01' = {
  name: '${projectName}-signalr'
  location: location
  sku: {
    name: 'Free_F1'
    tier: 'Free'
  }
}

output signalrConnectionString string = signalr.properties.hostName // Or use the connection string if needed

param location string
param projectName string
param frontendHost string // e.g. gathertoplay-frontend.azurestaticapps.net
param backendApiHost string // e.g. gathertoplay-api.azurewebsites.net
/////NOT USED YET/////

//frondoor app
resource afdProfile 'Microsoft.Cdn/profiles@2025-04-15' = {
  name: '${projectName}-afd'
  location: location
  sku: { name: 'Standard_AzureFrontDoor' }
}

// Origins for frontend and backend
resource afdOriginGroup 'Microsoft.Cdn/profiles/originGroups@2025-04-15' = {
  parent: afdProfile
  name: 'default-group'
  properties: {
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 255
    }
    sessionAffinityState: 'Disabled'
  }
}

// Frontend (Static Web App) origin
resource frontendOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2025-04-15' = {
  parent: afdOriginGroup
  name: 'frontend'
  properties: {
    hostName: frontendHost
    httpsPort: 443
    originHostHeader: frontendHost
    priority: 1 // Lower priority means higher precedence
    weight: 50 // Weight for load balancing
    enabledState: 'Disabled' 
  }
}

// Backend API origin
resource backendOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2025-04-15' = {
  parent: afdOriginGroup
  name: 'backend'
  properties: {
    hostName: backendApiHost
    httpsPort: 443
    originHostHeader: backendApiHost
    priority: 2
    weight: 50
    enabledState: 'Disabled' // Initially disabled, can be enabled later
  }
}

resource backendRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2025-04-15' = {
  parent: afdEndpoint
  name: 'api-route'
  properties: {
    originGroup: { id: afdOriginGroup.id }
    patternsToMatch: [ '/api/*' ]
    supportedProtocols: [ 'Http', 'Https' ]
    forwardingProtocol: 'HttpsOnly'
    enabledState: 'Enabled'
  }
}

resource frontendRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2025-04-15' = {
  parent: afdEndpoint
  name: 'frontend-route'
  properties: {
    originGroup: { id: afdOriginGroup.id }
    patternsToMatch: [ '/*' ]
    supportedProtocols: [ 'Http', 'Https' ]
    forwardingProtocol: 'HttpsOnly'
    enabledState: 'Enabled'
  }
}

resource wafPolicy 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2022-05-01' = {
  name: '${projectName}-afd-waf'
  location: location
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
    customRules: {
      rules: [
        // Block all except Poland
        {
          name: 'BlockNonPL'
          priority: 1
          ruleType: 'MatchRule'
          action: 'Block'
          matchConditions: [
            {
              matchVariable: 'RemoteAddr'
              operator: 'GeoMatch'
              negateCondition: true
              matchValue: [ 'PL' ]
            }
          ]
        }
        // Limit file upload to 20MB
        {
          name: 'LimitFileUpload'
          priority: 2
          ruleType: 'MatchRule'
          action: 'Block'
          matchConditions: [
            {
              matchVariable: 'RequestBodySize'
              operator: 'GreaterThan'
              matchValue: [ '20971520' ]
            }
          ]
        }
      ]
    }
  }
}

resource afdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2025-04-15' = {
  parent: afdProfile
  name: '${projectName}-afd-endpoint'
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

output afdEndpointHost string = '${afdEndpoint.name}.azurefd.net'
output wafPolicyId string = wafPolicy.id

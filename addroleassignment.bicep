@description('Name of the KeyVault resource ex. kv-myservice.')
param ResourceName string
@description('Principal Id of the Azure resource (Managed Identity).')
param principalId string
@description('Assigned permissions for Principal Id (Managed Identity)')
param RoleDefentionID string
targetScope = 'subscription'
resource addroleassignment  'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('${ResourceName}${deployment().name}${RoleDefentionID}')
  scope: subscription()
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', RoleDefentionID)
    principalId: principalId
  }
}

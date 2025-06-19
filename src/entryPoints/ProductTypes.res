@unboxed
type productTypes =
  | @as("orchestration") Orchestration(UserInfoTypes.version)
  | @as("recon") Recon
  | @as("recovery") Recovery
  | @as("vault") Vault
  | @as("cost_observability") CostObservability
  | @as("dynamic_routing") DynamicRouting

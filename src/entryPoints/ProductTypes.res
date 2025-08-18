type productTypes =
  | Orchestration(UserInfoTypes.version)
  | Recon(UserInfoTypes.version)
  | Vault
  | CostObservability
  | DynamicRouting
  | Recovery
  | OnBoarding(string)
  | UnknownProduct

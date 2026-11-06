type triggerModel = InternalTriggers | ExternalTriggers

type retryAlgorithm = Monitoring | Smart | Cascading

type recoveryProfile = {
  triggerModel: triggerModel,
  retryAlgorithm: option<retryAlgorithm>,
  // Kept untyped so fields the dashboard doesn't edit are sent back unchanged on save
  retryConfig: option<Dict.t<JSON.t>>,
}

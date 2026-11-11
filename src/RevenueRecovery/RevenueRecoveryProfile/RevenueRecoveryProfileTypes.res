type triggerModel =
  | @as("internal_triggers") InternalTriggers
  | @as("external_triggers") ExternalTriggers

type retryAlgorithm =
  | @as("monitoring") Monitoring
  | @as("smart") Smart
  | @as("cascading") Cascading

type recoveryProfile = {
  triggerModel: triggerModel,
  retryAlgorithm: option<retryAlgorithm>,
  retryConfig: option<Dict.t<JSON.t>>,
  webhookDetails: option<Dict.t<JSON.t>>,
  paymentResponseHashKey: string,
}

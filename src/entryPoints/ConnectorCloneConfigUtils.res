let getConnectorCloneAllowList = (config: JSON.t): array<string> => {
  open LogicUtils
  config
  ->getDictFromJsonObject
  ->getDictfromDict("connector_clone")
  ->getStrArrayFromDict("paymentProcessors", [])
  ->Array.map(String.toLowerCase)
}

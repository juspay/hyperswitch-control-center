open LogicUtils
open RetryStrategiesAnalyticsTypes

let getTitleForColumn = (col: retrySummaryCols): string => {
  switch col {
  | StaticRetries => "Static Retry Uplifter"
  | SmartRetries => "Smart Retry Uplifts"
  | SmartRetriesBooster => "Booster Retry Uplifter"
  | AuthRatePercent => "Authorization Rate (%)"
  | DeltaPercent => "Delta (%)"
  | SoftDeclinesRecoveredPercent => "Soft Declines"
  | HardDeclinesRecoveredPercent => "Hard Declines"
  }
}

let getDescriptionForColumn = (col: retrySummaryCols): string => {
  switch col {
  | StaticRetries => "Authorization success rate improvements observed by invoices following external retry logic"
  | SmartRetries => "Authorization success rate improvements observed by retrying only soft decline transactions."
  | SmartRetriesBooster => "Authorization success rate improvements observed by retrying both soft and hard decline transactions."
  | _ => ""
  }
}

let getStringFromVariant = (col: retrySummaryCols): string => {
  switch col {
  | StaticRetries => (#static_retries: response_keys :> string)
  | SmartRetries => (#smart_retries: response_keys :> string)
  | SmartRetriesBooster => (#smart_retries_booster: response_keys :> string)
  | AuthRatePercent => (#auth_rate_percent: response_keys :> string)
  | DeltaPercent => (#delta_percent: response_keys :> string)
  | SoftDeclinesRecoveredPercent => (#soft_declines_percent: response_keys :> string)
  | HardDeclinesRecoveredPercent => (#hard_declines_percent: response_keys :> string)
  }
}

let getRetriesObject = (data: JSON.t, key: retrySummaryCols): Dict.t<JSON.t> => {
  data->getDictFromJsonObject->getObj(key->getStringFromVariant, Dict.make())
}

let getRecoveredOrders = (retriesObject: Dict.t<JSON.t>): Dict.t<JSON.t> => {
  retriesObject->getObj("recovered_orders", Dict.make())
}

let getRetryStrategyData = (data: JSON.t, key: retrySummaryCols): retryStrategyData => {
  let retriesObject = getRetriesObject(data, key)
  let recoveredOrders = getRecoveredOrders(retriesObject)

  {
    auth_rate_percent: retriesObject->getFloat(AuthRatePercent->getStringFromVariant, 0.0),
    delta_percent: retriesObject->getFloat(DeltaPercent->getStringFromVariant, 0.0),
    recovered_orders: {
      soft_declines_percent: recoveredOrders->getFloat(
        SoftDeclinesRecoveredPercent->getStringFromVariant,
        0.0,
      ),
      hard_declines_percent: recoveredOrders->getFloat(
        HardDeclinesRecoveredPercent->getStringFromVariant,
        0.0,
      ),
    },
  }
}

let itemToObjectMapper = (data: JSON.t): retrySummaryObject => {
  {
    static_retries: getRetryStrategyData(data, StaticRetries),
    smart_retries: getRetryStrategyData(data, SmartRetries),
    smart_retries_booster: getRetryStrategyData(data, SmartRetriesBooster),
  }
}

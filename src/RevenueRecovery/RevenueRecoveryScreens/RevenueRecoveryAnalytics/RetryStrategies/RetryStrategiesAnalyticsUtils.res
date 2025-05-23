open LogicUtils
open RetryStrategiesAnalyticsTypes

let getTitleForColumn = (col: retrySummaryCols): string => {
  switch col {
  | StaticRetries => "Static Retry Upliftss"
  | SmartRetries => "Smart Retry Uplifts"
  | SmartRetriesBooster => "Booster Retry Upliftsr"
  | AuthRatePercent => "Authorization Rate (%)"
  | DeltaPercent => "Delta (%)"
  | SoftDeclinesRecoveredPercent => "Soft Declines"
  | HardDeclinesRecoveredPercent => "Hard Declines"
  }
}

let getStringFromVariant = (col: retrySummaryCols): string => {
  switch col {
  | StaticRetries => "static_retries"
  | SmartRetries => "smart_retries"
  | SmartRetriesBooster => "smart_retries_booster"
  | AuthRatePercent => "auth_rate_percent"
  | DeltaPercent => "delta_percent"
  | SoftDeclinesRecoveredPercent => "soft_declines_percent"
  | HardDeclinesRecoveredPercent => "hard_declines_percent"
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

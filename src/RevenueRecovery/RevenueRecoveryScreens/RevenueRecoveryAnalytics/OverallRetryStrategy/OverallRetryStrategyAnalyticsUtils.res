open OverallRetryStrategyAnalyticsTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | TimeBucket => "time_bucket"
  | Transactions => "transactions"
  | StaticRetrySuccessRate => "static_retry_success_rate"
  | SmartRetrySuccessRate => "smart_retry_success_rate"
  | SmartRetryBoosterSuccessRate => "smart_retry_booster_success_rate"
  }
}

let itemToRetryTrendEntryMapper: Dict.t<JSON.t> => retryTrendEntry = dict => {
  {
    time_bucket: dict->getString(TimeBucket->getStringFromVariant, ""),
    transactions: dict->getInt(Transactions->getStringFromVariant, 0),
    static_retry_success_rate: dict->getFloat(StaticRetrySuccessRate->getStringFromVariant, 0.0),
    smart_retry_success_rate: dict->getFloat(SmartRetrySuccessRate->getStringFromVariant, 0.0),
    smart_retry_booster_success_rate: dict->getFloat(
      SmartRetryBoosterSuccessRate->getStringFromVariant,
      0.0,
    ),
  }
}

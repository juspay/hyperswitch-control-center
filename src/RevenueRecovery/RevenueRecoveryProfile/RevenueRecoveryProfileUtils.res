open RevenueRecoveryProfileTypes
open LogicUtils

let triggerModelKey = "revenue_recovery_trigger_model"
let retryAlgorithmKey = "revenue_recovery_retry_algorithm_type"
let retryConfigKey = "revenue_recovery_config"

let retryThresholdKey = "billing_connector_retry_threshold"
let maxRetryCountKey = "max_retry_count"
let gracePeriodDaysKey = "grace_period_days"
let maxHardDeclineRetriesKey = "max_hard_decline_retries"
let enablePartialAuthorizationKey = "enable_partial_authorization"

let maxAllowedRetries = 15

let configurationSection: VerticalStepIndicatorTypes.section = {
  id: "configuration",
  name: "Configuration",
  icon: "nd-flag",
  subSections: None,
}

let getTriggerModelFromString = value =>
  switch value {
  | "external_triggers" => ExternalTriggers
  | _ => InternalTriggers
  }

let getRetryAlgorithmFromString = value =>
  switch value {
  | "monitoring" => Some(Monitoring)
  | "smart" => Some(Smart)
  | "cascading" => Some(Cascading)
  | _ => None
  }

let getTriggerModelLabel = model =>
  switch model {
  | InternalTriggers => "Managed Recovery"
  | ExternalTriggers => "Scheduled Only Recovery"
  }

let getRetryAlgorithmLabel = (algorithm: retryAlgorithm) => (algorithm :> string)->capitalizeString

let mapJsonToRecoveryProfile = json => {
  let dict = json->getDictFromJsonObject
  {
    triggerModel: dict->getString(triggerModelKey, "")->getTriggerModelFromString,
    retryAlgorithm: dict->getString(retryAlgorithmKey, "")->getRetryAlgorithmFromString,
    retryConfig: dict->Dict.get(retryConfigKey)->Option.flatMap(JSON.Decode.object),
  }
}

let isExternalModel = recoveryProfile =>
  switch recoveryProfile {
  | Some({triggerModel: ExternalTriggers}) => true
  | _ => false
  }

let isRecoveryOnboarded = (~recoveryProfile, ~hasConfiguredBillingConnector) =>
  hasConfiguredBillingConnector || recoveryProfile->isExternalModel

let getTriggerModelRoute = model =>
  switch model {
  | InternalTriggers => "/v2/recovery/onboarding"
  | ExternalTriggers => "/v2/recovery/onboarding/configuration"
  }

// Connector defaults of 0 retries would stop recovery immediately, so these start from usable values
let getDefaultRetryConfig = () =>
  [
    (retryThresholdKey, 3->JSON.Encode.int),
    (maxRetryCountKey, maxAllowedRetries->JSON.Encode.int),
    (gracePeriodDaysKey, RevenueRecoveryOnboardingUtils.defaultGracePeriodDays->JSON.Encode.int),
    (
      maxHardDeclineRetriesKey,
      RevenueRecoveryOnboardingUtils.hardDeclineTotalRetries->JSON.Encode.int,
    ),
    (enablePartialAuthorizationKey, false->JSON.Encode.bool),
  ]->Dict.fromArray

let getRetryConfigInitialValues = retryConfig =>
  [(retryConfigKey, retryConfig->Option.getOr(getDefaultRetryConfig())->JSON.Encode.object)]
  ->Dict.fromArray
  ->JSON.Encode.object

let getRetryConfigFieldName = key => `${retryConfigKey}.${key}`

let validateRetryConfig = values => {
  let errors = Dict.make()
  let retryConfig = values->getDictFromJsonObject->getDictfromDict(retryConfigKey)
  let setError = (key, message) =>
    errors->Dict.set(key->getRetryConfigFieldName, message->JSON.Encode.string)

  switch retryConfig->getOptionInt(retryThresholdKey) {
  | None => retryThresholdKey->setError("Please enter start retry count")
  | Some(value) if value > maxAllowedRetries =>
    retryThresholdKey->setError(
      `Start retry count cannot be more than ${maxAllowedRetries->Int.toString}`,
    )
  | Some(_) => ()
  }

  switch retryConfig->getOptionInt(maxRetryCountKey) {
  | None | Some(0) => maxRetryCountKey->setError("Please enter max retry count")
  | Some(value) if value > maxAllowedRetries =>
    maxRetryCountKey->setError(
      `Max retry count cannot be more than ${maxAllowedRetries->Int.toString}`,
    )
  | Some(_) => ()
  }

  switch retryConfig->getOptionInt(gracePeriodDaysKey) {
  | Some(value) if value > 0 => ()
  | _ => gracePeriodDaysKey->setError("Please enter grace period")
  }

  switch retryConfig->getOptionInt(maxHardDeclineRetriesKey) {
  | None => maxHardDeclineRetriesKey->setError("Please enter hard decline retries")
  | Some(value) if value > retryConfig->getInt(maxRetryCountKey, maxAllowedRetries) =>
    maxHardDeclineRetriesKey->setError("Hard decline retries cannot be more than total retries")
  | Some(_) => ()
  }

  errors->JSON.Encode.object
}

// The merchant doesn't exist yet when a new merchant picks a model, so the choice has to
// survive the create merchant popup and the switch to that merchant
let pendingTriggerModelKey = "recovery_pending_trigger_model"

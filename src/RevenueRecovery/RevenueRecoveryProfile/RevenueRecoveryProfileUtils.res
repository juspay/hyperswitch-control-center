open RevenueRecoveryProfileTypes
open LogicUtils
open VerticalStepIndicatorTypes

let triggerModelKey = "revenue_recovery_trigger_model"
let retryAlgorithmKey = "revenue_recovery_retry_algorithm_type"
let retryConfigKey = "revenue_recovery_config"

let retryThresholdKey = "billing_connector_retry_threshold"
let maxRetryCountKey = "max_retry_count"
let gracePeriodDaysKey = "grace_period_days"
let maxHardDeclineRetriesKey = "max_hard_decline_retries"
let enablePartialAuthorizationKey = "enable_partial_authorization"

let webhookDetailsKey = "webhook_details"
let webhookUrlKey = "webhook_url"
let webhookUrlFieldName = `${webhookDetailsKey}.${webhookUrlKey}`
let paymentResponseHashKeyKey = "payment_response_hash_key"

let maxAllowedRetries = 15

let scheduledOnlyOnboardingSteps: array<scheduledOnlyOnboardingSections> = [
  #configuration,
  #setupWebhook,
]

let getScheduledOnlyStepName = (step: scheduledOnlyOnboardingSections) =>
  switch step {
  | #configuration => "Configuration"
  | #setupWebhook => "Setup Webhook"
  }

let getScheduledOnlyStepIcon = (step: scheduledOnlyOnboardingSections) =>
  switch step {
  | #configuration => "nd-settings"
  | #setupWebhook => "nd-webhook"
  }

let scheduledOnlyOnboardingSections = scheduledOnlyOnboardingSteps->Array.map(step => {
  id: (step :> string),
  name: step->getScheduledOnlyStepName,
  icon: step->getScheduledOnlyStepIcon,
  subSections: None,
})

let scheduledOnlyDefaultStep: step = {
  sectionId: (#configuration: scheduledOnlyOnboardingSections :> string),
  subSectionId: None,
}

let getScheduledOnlySectionVariant = (step: step) =>
  scheduledOnlyOnboardingSteps
  ->Array.find(section => (section :> string) == step.sectionId)
  ->Option.getOr(#configuration)

let getTriggerModelFromString = value =>
  [InternalTriggers, ExternalTriggers]
  ->Array.find(model => (model :> string) == value)
  ->Option.getOr(InternalTriggers)

let getRetryAlgorithmFromString = value =>
  [Monitoring, Smart, Cascading]->Array.find(algorithm => (algorithm :> string) == value)

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
    webhookDetails: dict->Dict.get(webhookDetailsKey)->Option.flatMap(JSON.Decode.object),
    paymentResponseHashKey: dict->getString(paymentResponseHashKeyKey, ""),
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

let getWebhookUrl = values =>
  values->getDictFromJsonObject->getStringFromNestedDict(webhookDetailsKey, webhookUrlKey, "")

let getWebhookInitialValues = webhookDetails => {
  let webhookUrl = webhookDetails->Option.getOr(Dict.make())->getString(webhookUrlKey, "")
  [
    (
      webhookDetailsKey,
      [(webhookUrlKey, webhookUrl->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object,
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// The profile update replaces webhook_details as a whole, so the saved fields are sent back with the URL
let getWebhookDetailsBody = (~webhookUrl, ~webhookDetails) => {
  let details = webhookDetails->Option.getOr(Dict.make())->Dict.copy
  if webhookUrl->isNonEmptyString {
    details->Dict.set(webhookUrlKey, webhookUrl->JSON.Encode.string)
  } else {
    details->Dict.delete(webhookUrlKey)
  }
  details->JSON.Encode.object
}

let validateWebhookUrl = (errors, values, ~isLiveMode) =>
  values
  ->getWebhookUrl
  ->getNonEmptyString
  ->mapOptionOrDefault((), webhookUrl =>
    PaymentSettingsUtils.validateCustom(WebhookDetails, errors, webhookUrl, isLiveMode)
  )

// The merchant doesn't exist yet when a new merchant picks a model, so the choice has to
// survive the create merchant popup and the switch to that merchant
let pendingTriggerModelKey = "recovery_pending_trigger_model"

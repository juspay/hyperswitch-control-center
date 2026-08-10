open SuperpositionTypes

let displayConfigs = [
  ShouldPerformEligibility,
  ShouldCallPMModularService,
  EnableExtendedCardBin,
  ShouldStoreEligibilityCheckDataForAuthentication,
]

let getDimensionsForFixedContext = dimensionEntity =>
  switch dimensionEntity {
  | Org => "organization_id"
  | Merchant => "processor_merchant_id"
  | Profile => "profile_id"
  }

let configEnumToString = config =>
  switch config {
  | ShouldPerformEligibility => "should_perform_eligibility"
  | ShouldCallPMModularService => "should_call_pm_modular_service"
  | EnableExtendedCardBin => "enable_extended_card_bin"
  | ShouldStoreEligibilityCheckDataForAuthentication => "should_store_eligibility_check_data_for_authentication"
  }

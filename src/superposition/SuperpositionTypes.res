type dimensionEntity =
  | Org
  | Merchant
  | Profile

type configFolder = | @as("payments") Payments

type configEnums =
  | @as("should_perform_eligibility") ShouldPerformEligibility
  | @as("should_call_pm_modular_service") ShouldCallPMModularService
  | @as("enable_extended_card_bin") EnableExtendedCardBin
  | @as("should_store_eligibility_check_data_for_authentication")
  ShouldStoreEligibilityCheckDataForAuthentication

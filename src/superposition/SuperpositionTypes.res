type dimensionEntity =
  | Org
  | Merchant
  | Profile

type configEnums =
  | ShouldPerformEligibility
  | ShouldCallPMModularService
  | EnableExtendedCardBin
  | ShouldStoreEligibilityCheckDataForAuthentication

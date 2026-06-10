type dimensionEntity =
  | Org
  | Merchant
  | Profile

type configEnums =
  | ShouldPerformEligibilty
  | ShouldCallPMModularService
  | EnableExtendedCardBin
  | ShouldStoreEligibilityCheckDataForAuthentication

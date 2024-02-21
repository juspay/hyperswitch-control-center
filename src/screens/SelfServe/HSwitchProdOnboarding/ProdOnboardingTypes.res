type sectionHeadingVariant = [
  | #ProductionAgreement
  | #SetupProcessor
  | #ConfigureEndpoint
  | #SetupComplete
]
type setupProcessor = {connector_id: string}
type prodOnboading = {
  configureEndpoint: bool,
  productionAgreement: bool,
  setupComplete: bool,
  setupProcessor: setupProcessor,
}

type subsectionVariant =
  | SELECT_PROCESSOR
  | SETUP_CREDS
  | SETUP_WEBHOOK_PROCESSOR
  | REPLACE_API_KEYS
  | SETUP_WEBHOOK_USER
  | TEST_LIVE_PAYMENT
  | SETUP_COMPLETED

type checkListType = {
  headerText: string,
  headerVariant: sectionHeadingVariant,
  itemsVariants: array<subsectionVariant>,
}

type previewStates =
  | SELECT_PROCESSOR_PREVIEW
  | LIVE_ENDPOINTS_PREVIEW
  | COMPLETE_SETUP_PREVIEW

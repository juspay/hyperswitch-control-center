open QuickStartUtils
type step =
  PLUGIN_INSTALL | PLUGIN_CONFIGURE | WEBHOOK_SETUP | PROCESSOR_SETUP | COMPLETED_WOOCOMMERCE

let variantToEnumMapper = variantValue => {
  switch variantValue {
  | PLUGIN_INSTALL => #DownloadWoocom
  | PLUGIN_CONFIGURE => #ConfigureWoocom
  | WEBHOOK_SETUP => #SetupWoocomWebhook
  | PROCESSOR_SETUP => #FirstProcessorConnected
  | COMPLETED_WOOCOMMERCE => #DownloadWoocom
  }
}

let enumToValueMapper = (variantValue, typedValue: QuickStartTypes.responseType) => {
  switch variantValue {
  | PLUGIN_INSTALL => typedValue.downloadWoocom
  | PLUGIN_CONFIGURE => typedValue.configureWoocom
  | WEBHOOK_SETUP => typedValue.setupWoocomWebhook
  | PROCESSOR_SETUP => typedValue.firstProcessorConnected.processorID->String.length > 0
  | COMPLETED_WOOCOMMERCE => true
  }
}

let getSidebarOptionsForWooCommerceIntegration: (
  string,
  step,
) => array<HSSelfServeSidebar.sidebarOption> = (enumDetails, wooCommercePageState) => {
  // TODO:Refactor code to more dynamic cases

  let currentPageStateEnum = wooCommercePageState->variantToEnumMapper

  open LogicUtils
  let enumValue = enumDetails->safeParse->getTypedValueFromDict

  [
    {
      title: "Download and Install Plugin",
      status: Boolean(enumValue.downloadWoocom)->getStatusValue(
        #DownloadWoocom,
        currentPageStateEnum,
      ),
      link: "",
    },
    {
      title: "Configure Plugin",
      status: Boolean(enumValue.configureWoocom)->getStatusValue(
        #ConfigureWoocom,
        currentPageStateEnum,
      ),
      link: "",
    },
    {
      title: "Setup Webhook and Save Changes",
      status: Boolean(enumValue.setupWoocomWebhook)->getStatusValue(
        #SetupWoocomWebhook,
        currentPageStateEnum,
      ),
      link: "",
    },
    {
      title: "Setup a Processor",
      status: String(enumValue.firstProcessorConnected.processorID)->getStatusValue(
        #FirstProcessorConnected,
        currentPageStateEnum,
      ),
      link: "",
    },
  ]
}

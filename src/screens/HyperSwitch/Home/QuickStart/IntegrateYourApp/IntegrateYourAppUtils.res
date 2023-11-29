type migrateFromStripeSteps =
  DownloadAPIKey | InstallDeps | ReplaceAPIKeys | ReconfigureCheckout | LoadCheckout

type standardIntegrationSteps =
  DownloadTestAPIKey | CreatePayment | DisplayCheckout | DisplayPaymentConfirmation

type pluginSteps =
  | InstallPlugin
  | ConfigurePlugin
  | SetUpWebhook
type processorSteps =
  | SetupSBXCredentials
  | SetupWebhookSelf
  | SetupPaymentMethod

type woocommerceIntegrationSteps = SetUpPlugin(pluginSteps) | SetupProcessor(processorSteps)

let getCurrentMigrateFromStripeStepHeading = (step: migrateFromStripeSteps) => {
  switch step {
  | DownloadAPIKey => "Download Test API Key"
  | InstallDeps => "Install Dependencies"
  | ReplaceAPIKeys => "Replace API Key"
  | ReconfigureCheckout => "Reconfigure Checkout Form"
  | LoadCheckout => "Load Hyperswitch Checkout"
  }
}

let getNavigationStepForMigrateFromStripe = (~currentStep, ~forward=false, ()) => {
  switch currentStep {
  | DownloadAPIKey => forward ? InstallDeps : DownloadAPIKey
  | InstallDeps => forward ? ReplaceAPIKeys : DownloadAPIKey
  | ReplaceAPIKeys => forward ? ReconfigureCheckout : InstallDeps
  | ReconfigureCheckout => forward ? LoadCheckout : ReplaceAPIKeys
  | LoadCheckout => forward ? LoadCheckout : ReconfigureCheckout
  }
}

let getCurrentStandardIntegrationStepHeading = (step: standardIntegrationSteps) => {
  switch step {
  | DownloadTestAPIKey => "Download Test API Key"
  | CreatePayment => "Create A Payment"
  | DisplayCheckout => "Display Hyperswitch Checkout Page"
  | DisplayPaymentConfirmation => "Display Payment Confirmation Page"
  }
}

let getCurrentWooCommerceIntegrationStepHeading = (step: woocommerceIntegrationSteps) => {
  switch step {
  | SetUpPlugin(subStep) =>
    switch subStep {
    | InstallPlugin => "Download Test API Key"
    | ConfigurePlugin => "Configure Plugin"
    | SetUpWebhook => "Setup Webhook and Save Changes"
    }
  | SetupProcessor(subStep) =>
    switch subStep {
    | SetupSBXCredentials => "Choose a primary processor, setup more later"
    | SetupWebhookSelf => "Setup Webhook"
    | SetupPaymentMethod => "Choose Payment Methods"
    }
  }
}

let getNavigationStepForStandardIntegration = (
  ~currentStep: standardIntegrationSteps,
  ~forward=false,
  (),
) => {
  switch currentStep {
  | DownloadTestAPIKey => forward ? CreatePayment : DownloadTestAPIKey
  | CreatePayment => forward ? DisplayCheckout : DownloadTestAPIKey
  | DisplayCheckout => forward ? DisplayPaymentConfirmation : CreatePayment
  | DisplayPaymentConfirmation => forward ? DisplayPaymentConfirmation : DisplayCheckout
  }
}

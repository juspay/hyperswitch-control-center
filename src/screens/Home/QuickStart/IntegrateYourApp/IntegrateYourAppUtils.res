type migrateFromStripeSteps =
  DownloadAPIKey | InstallDeps | ReplaceAPIKeys | ReconfigureCheckout | LoadCheckout

type standardIntegrationSteps =
  DownloadTestAPIKey | CreatePayment | DisplayCheckout | DisplayPaymentConfirmation

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

let getPolyMorphicVariantOfIntegrationSubStep: standardIntegrationSteps => QuickStartTypes.sectionHeadingVariant = (
  currentStep: standardIntegrationSteps,
) => {
  switch currentStep {
  | DownloadTestAPIKey => #DownloadTestAPIKey
  | CreatePayment => #CreatePayment
  | DisplayCheckout => #DisplayCheckout
  | DisplayPaymentConfirmation => #DisplayPaymentConfirmation
  }
}

let getPolyMorphicVariantOfMigrateFromStripe: migrateFromStripeSteps => QuickStartTypes.sectionHeadingVariant = (
  currentStep: migrateFromStripeSteps,
) => {
  switch currentStep {
  | DownloadAPIKey => #DownloadTestAPIKeyStripe
  | InstallDeps => #InstallDeps
  | ReplaceAPIKeys => #ReplaceAPIKeys
  | ReconfigureCheckout => #ReconfigureCheckout
  | LoadCheckout => #LoadCheckout
  }
}

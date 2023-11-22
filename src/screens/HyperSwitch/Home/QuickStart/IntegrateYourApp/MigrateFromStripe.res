open IntegrateYourAppUtils

@react.component
let make = (
  ~currentRoute,
  ~frontEndLang,
  ~setFrontEndLang,
  ~backEndLang,
  ~setBackEndLang,
  ~platform,
  ~setPlatform,
  ~markAsDone,
) => {
  let (currentStep, setCurrentStep) = React.useState(_ => DownloadAPIKey)

  let theme = switch ThemeProvider.useTheme() {
  | Dark => "vs-dark"
  | Light => "light"
  }

  let backButton =
    <Button
      buttonState={currentStep === DownloadAPIKey ? Disabled : Normal}
      buttonType={PrimaryOutline}
      text="Back"
      onClick={_ => setCurrentStep(_ => getNavigationStepForMigrateFromStripe(~currentStep, ()))}
      buttonSize=Small
    />

  let nextButton =
    <Button
      buttonType={Primary}
      text="Proceed"
      onClick={_ => {
        if currentStep === LoadCheckout {
          markAsDone()->ignore
        } else {
          setCurrentStep(_ =>
            getNavigationStepForMigrateFromStripe(~currentStep, ~forward=true, ())
          )
        }
      }}
      buttonSize=Small
    />

  <QuickStartUIUtils.BaseComponent
    backButton
    nextButton
    headerText={getCurrentMigrateFromStripeStepHeading(currentStep)}
    customCss="show-scrollbar">
    {switch currentStep {
    | DownloadAPIKey =>
      <UserOnboardingUIUtils.DownloadAPIKey currentRoute currentTabName="downloadApiKey" />
    | InstallDeps =>
      <div className="p-10 bg-gray-50 border rounded flex flex-col gap-4">
        <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
          frontEndLang setFrontEndLang backEndLang setBackEndLang currentRoute platform setPlatform
        />
        <div className="bg-white border rounded">
          <UserOnboardingUIUtils.ShowCodeEditor
            value={frontEndLang->UserOnboardingUtils.getMigrateFromStripeDX(backEndLang)}
            theme
            headerText="Installation"
            langauge=backEndLang
            currentRoute
            currentTabName="2.installDependencies"
          />
        </div>
      </div>
    | ReplaceAPIKeys =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          {"Call loadHyper() with your Hyperswitch publishable key to configure the SDK library, from your website.This will load and invoke the Hyperswitch Checkout experience instead of the Stripe UI Elements."->React.string}
        </div>
        <div className="flex flex-col gap-2">
          <div className="text-grey-900 font-medium"> {"Publishable Key"->React.string} </div>
          <UserOnboardingUIUtils.PublishableKeyArea currentRoute />
        </div>
        <div className="p-10 bg-gray-50 border rounded flex flex-col gap-4">
          <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
            frontEndLang
            setFrontEndLang
            backEndLang
            setBackEndLang
            currentRoute
            platform
            setPlatform
          />
          <UserOnboardingUIUtils.DiffCodeEditor
            valueToShow={backEndLang->UserOnboardingUtils.getReplaceAPIkeys}
            langauge=backEndLang
            currentRoute
            currentTabName="3.replaceaPIkey"
          />
        </div>
      </div>
    | ReconfigureCheckout =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          {"Reconfigure checkout form to import from Hyperswitch. This will import the Hyperswitch unified checkout dependencies."->React.string}
        </div>
        <div className="flex flex-col gap-2">
          <div className="text-grey-900 font-medium"> {"Publishable Key"->React.string} </div>
          <UserOnboardingUIUtils.PublishableKeyArea currentRoute />
        </div>
        <div className="p-10 bg-gray-50 border rounded flex flex-col gap-4">
          <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
            frontEndLang
            setFrontEndLang
            backEndLang
            setBackEndLang
            currentRoute
            platform
            setPlatform
          />
          <UserOnboardingUIUtils.DiffCodeEditor
            valueToShow={frontEndLang->UserOnboardingUtils.getCheckoutForm}
            langauge=frontEndLang
            currentRoute
            currentTabName="4.reconfigureCheckout"
          />
        </div>
      </div>
    | LoadCheckout =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          {"Call loadHyper() with your Hyperswitch publishable key to configure the SDK library, from your website.This will load and invoke the Hyperswitch Checkout experience instead of the Stripe UI Elements."->React.string}
        </div>
        <div className="flex flex-col gap-2">
          <div className="text-grey-900 font-medium"> {"Publishable Key"->React.string} </div>
          <UserOnboardingUIUtils.PublishableKeyArea currentRoute />
        </div>
        <div className="p-10 bg-gray-50 border rounded flex flex-col gap-4">
          <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
            frontEndLang
            setFrontEndLang
            backEndLang
            setBackEndLang
            currentRoute
            platform
            setPlatform
          />
          <UserOnboardingUIUtils.DiffCodeEditor
            valueToShow={frontEndLang->UserOnboardingUtils.getHyperswitchCheckout}
            langauge=frontEndLang
            currentRoute
            currentTabName="5.loadCheckout"
          />
        </div>
      </div>
    }}
  </QuickStartUIUtils.BaseComponent>
}

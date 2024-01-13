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
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (currentStep, setCurrentStep) = React.useState(_ => DownloadAPIKey)
  let {setQuickStartPageState} = React.useContext(GlobalProvider.defaultContext)
  let isLastStep = currentStep === LoadCheckout
  let updateEnumInRecoil = EnumVariantHook.useUpdateEnumInRecoil()

  let theme = switch ThemeProvider.useTheme() {
  | Dark => "vs-dark"
  | Light => "light"
  }

  let backButton =
    <Button
      buttonState={Normal}
      buttonType={PrimaryOutline}
      text="Back"
      onClick={_ => {
        let prevStep = getNavigationStepForMigrateFromStripe(~currentStep, ())
        if currentStep === DownloadAPIKey {
          setQuickStartPageState(_ => IntegrateApp(CHOOSE_INTEGRATION))
        } else {
          let _ = updateEnumInRecoil([
            (String("pending"), currentStep->getPolyMorphicVariantOfMigrateFromStripe),
            (String("ongoing"), prevStep->getPolyMorphicVariantOfMigrateFromStripe),
          ])
          setCurrentStep(_ => prevStep)
        }
      }}
      buttonSize=Small
    />

  let nextButton =
    <Button
      buttonType={Primary}
      text={isLastStep ? "Complete" : "Proceed"}
      onClick={_ => {
        if isLastStep {
          mixpanelEvent(~eventName=`quickstart_integration_completed`, ())
          markAsDone()->ignore
        } else {
          let nextStep = getNavigationStepForMigrateFromStripe(~currentStep, ~forward=true, ())
          let _ = updateEnumInRecoil([
            (String("completed"), currentStep->getPolyMorphicVariantOfMigrateFromStripe),
            (String("ongoing"), nextStep->getPolyMorphicVariantOfMigrateFromStripe),
          ])
          setCurrentStep(_ => nextStep)
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
          <UserOnboardingUIUtils.PublishableKeyArea />
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
            valueToShow={backEndLang->UserOnboardingUtils.getReplaceAPIkeys} langauge=backEndLang
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
          <UserOnboardingUIUtils.PublishableKeyArea />
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
            valueToShow={frontEndLang->UserOnboardingUtils.getCheckoutForm} langauge=frontEndLang
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
          <UserOnboardingUIUtils.PublishableKeyArea />
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
          />
        </div>
      </div>
    }}
  </QuickStartUIUtils.BaseComponent>
}

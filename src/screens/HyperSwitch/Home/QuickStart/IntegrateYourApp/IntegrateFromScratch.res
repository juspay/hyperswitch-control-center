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
  let (currentStep, setCurrentStep) = React.useState(_ => DownloadTestAPIKey)
  let {setQuickStartPageState} = React.useContext(GlobalProvider.defaultContext)
  let isLastStep = currentStep === DisplayPaymentConfirmation
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
        let prevStep = getNavigationStepForStandardIntegration(~currentStep, ())
        if currentStep === DownloadTestAPIKey {
          setQuickStartPageState(_ => IntegrateApp(CHOOSE_INTEGRATION))
        } else {
          let _ = updateEnumInRecoil([
            (String("pending"), currentStep->getPolyMorphicVariantOfIntegrationSubStep),
            (String("ongoing"), prevStep->getPolyMorphicVariantOfIntegrationSubStep),
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
          markAsDone()->ignore
        } else {
          let nextStep = getNavigationStepForStandardIntegration(~currentStep, ~forward=true, ())
          let _ = updateEnumInRecoil([
            (String("completed"), currentStep->getPolyMorphicVariantOfIntegrationSubStep),
            (String("ongoing"), nextStep->getPolyMorphicVariantOfIntegrationSubStep),
          ])

          setCurrentStep(_ => nextStep)
        }
      }}
      buttonSize=Small
    />

  <QuickStartUIUtils.BaseComponent
    backButton
    nextButton
    headerText={getCurrentStandardIntegrationStepHeading(currentStep)}
    customCss="show-scrollbar">
    {switch currentStep {
    | DownloadTestAPIKey =>
      <UserOnboardingUIUtils.DownloadAPIKey currentRoute currentTabName="downloadApiKey" />
    | CreatePayment =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          <p className="text-base font-normal py-2 ">
            {"Create a payment from your server to establish the intent of the customer to start payment."->React.string}
          </p>
          <p>
            {"For the complete API schema, refer "->React.string}
            <span
              className="text-blue-700 underline cursor-pointer"
              onClick={_ =>
                Window._open(
                  "https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create",
                )}>
              {"API docs"->React.string}
            </span>
          </p>
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
          <div className="bg-white border rounded">
            <UIUtils.RenderIf
              condition={backEndLang
              ->UserOnboardingUtils.getInstallDependencies
              ->String.length > 0}>
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getMigrateFromStripeDX(backEndLang)}
                theme
                headerText="Installation"
                langauge=backEndLang
              />
            </UIUtils.RenderIf>
          </div>
          <div className="bg-white border rounded">
            <UserOnboardingUIUtils.ShowCodeEditor
              value={backEndLang->UserOnboardingUtils.getCreateAPayment}
              theme
              headerText="Request"
              customHeight="25vh"
              langauge=backEndLang
            />
          </div>
        </div>
      </div>
    | DisplayCheckout =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          {"Open the Hyperswitch checkout for your user inside an iFrame to display the payment methods."->React.string}
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
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getInstallDependencies->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getInstallDependencies}
                theme
                headerText="Installation"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getInstallDependencies->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getImports}
                theme
                headerText="Imports"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getLoad->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getLoad}
                theme
                headerText="Load"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getInitialize->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getInitialize}
                theme
                headerText="Initialize"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
          <UIUtils.RenderIf
            condition={frontEndLang
            ->UserOnboardingUtils.getCheckoutFormForDisplayCheckoutPage
            ->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getCheckoutFormForDisplayCheckoutPage}
                theme
                headerText="Checkout Form"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
        </div>
      </div>
    | DisplayPaymentConfirmation =>
      <div className="flex flex-col gap-10">
        <div className="text-grey-50">
          {"Handle the response and display the thank you page to the user."->React.string}
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
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getHandleEvents->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getHandleEvents}
                theme
                headerText="Handle Events"
                customHeight="20vh"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
          <UIUtils.RenderIf
            condition={frontEndLang->UserOnboardingUtils.getDisplayConformation->String.length > 0}>
            <div className="bg-white border rounded">
              <UserOnboardingUIUtils.ShowCodeEditor
                value={frontEndLang->UserOnboardingUtils.getDisplayConformation}
                theme
                headerText="Display Payment Confirmation"
                customHeight="20vh"
                langauge=frontEndLang
              />
            </div>
          </UIUtils.RenderIf>
        </div>
      </div>
    }}
  </QuickStartUIUtils.BaseComponent>
}

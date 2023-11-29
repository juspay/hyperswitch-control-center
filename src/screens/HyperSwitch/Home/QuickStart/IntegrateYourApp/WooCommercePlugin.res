open IntegrateYourAppUtils

@react.component
let make = (~currentRoute, ~markAsDone) => {
  let (currentStep, setCurrentStep) = React.useState(_ => SetUpPlugin(InstallPlugin))
  let {setQuickStartPageState} = React.useContext(GlobalProvider.defaultContext)
  let isLastStep = switch currentStep {
  | SetUpPlugin(step) => step === SetUpWebhook
  | SetupProcessor(step) => step === SetupPaymentMethod
  }

  let backButton =
    <Button
      buttonState={Normal}
      buttonType={PrimaryOutline}
      text="Back"
      onClick={_ => Js.log("Back")}
      buttonSize=Small
    />

  let handleNavigation = (~forward) => {Js.log("helpo")}

  let nextButton =
    <Button
      buttonType={Primary}
      text={isLastStep ? "Complete" : "Proceed"}
      onClick={_ => Js.log("Forward")}
      buttonSize=Small
    />

  <QuickStartUIUtils.BaseComponent
    backButton
    nextButton
    headerText={getCurrentWooCommerceIntegrationStepHeading(currentStep)}
    customCss="show-scrollbar">
    {switch currentStep {
    | SetUpPlugin(pluginSubStep) =>
      switch pluginSubStep {
      | InstallPlugin =>
        <WooCommerce.InstallPlugin handleNavigation title="Install Plugin" description="xyz" />
      | ConfigurePlugin =>
        <WooCommerce.ConfigurePlugin handleNavigation title="Install Plugin" description="xyz" />
      | SetUpWebhook =>
        <WooCommerce.ConfigureWebHook handleNavigation title="Install Plugin" description="xyz" />
      }
    | SetupProcessor(processorSubStep) =>
      switch processorSubStep {
      | SetupSBXCredentials
      | SetupWebhookSelf
      | SetupPaymentMethod =>
        <h1> {"Coming"->React.string} </h1>
      }
    }}
  </QuickStartUIUtils.BaseComponent>
}

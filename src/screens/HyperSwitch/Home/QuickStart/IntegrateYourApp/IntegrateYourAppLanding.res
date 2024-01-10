open QuickStartTypes

@react.component
let make = (~integrateAppValue: integrateApp) => {
  open QuickStartUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
  let typedValueOfEnum = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict
  let usePostEnumDetails = EnumVariantHook.usePostEnumDetails()
  let {quickStartPageState, setQuickStartPageState, setDashboardPageState} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let (choiceState, setChoiceState) = React.useState(_ =>
    typedValueOfEnum.integrationMethod.integration_type->textToVariantMapper
  )

  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let currentRoute =
    typedValueOfEnum.integrationMethod.integration_type->textToVariantMapperForBuildHS

  let landingButtonGroup = {
    <div className="flex flex-col gap-4 w-full">
      <Button
        text="I want to integrate Hyperswitch into my app"
        buttonType={Primary}
        onClick={_ => {
          mixpanelEvent(~eventName=`quickstart_integration_landing`, ())
          setQuickStartPageState(_ => IntegrateApp(CHOOSE_INTEGRATION))
        }}
      />
      <Button
        text="Go to Home"
        buttonType={Secondary}
        onClick={_ => {
          setDashboardPageState(_ => #HOME)
          RescriptReactRouter.replace("/home")
        }}
      />
    </div>
  }

  let handleIntegration = async () => {
    try {
      setButtonState(_ => Loading)
      let integartionValue: QuickStartTypes.integrationMethod = {
        integration_type: (choiceState: QuickStartTypes.choiceStateTypes :> string),
      }
      let enumVariant = quickStartPageState->variantToEnumMapper
      let _ = await IntegrationMethod(integartionValue)->usePostEnumDetails(enumVariant)
      setQuickStartPageState(_ => IntegrateApp(CUSTOM_INTEGRATION))
      setButtonState(_ => Normal)
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  let handleMarkAsDone = async () => {
    try {
      let enumVariant = quickStartPageState->variantToEnumMapper
      let _ = await Boolean(true)->usePostEnumDetails(enumVariant)
    } catch {
    | _ => ()
    }
    setQuickStartPageState(_ => GoLive(LANDING))
  }

  <>
    {switch integrateAppValue {
    | LANDING =>
      <div className="h-full flex-1 flex flex-col items-center justify-center">
        <QuickStartUIUtils.StepCompletedPage
          headerText="Configuration is complete. You can now start integrating with us!"
          buttonGroup={landingButtonGroup}
        />
      </div>
    | CHOOSE_INTEGRATION =>
      <div className="flex h-full">
        <HSSelfServeSidebar
          heading="Integrate your app"
          sidebarOptions={enumDetails->getSidebarOptionsForIntegrateYourApp(
            quickStartPageState,
            currentRoute,
            choiceState,
          )}
        />
        <div className="flex-1 flex flex-col items-center justify-center">
          <QuickStartUIUtils.LandingPageChoice
            choiceState
            setChoiceState
            headerText="How would you like to integrate?"
            isVerticalTile=true
            listChoices={integrateYourAppArray}
            nextButton={<Button
              buttonType=Primary
              text="Proceed"
              buttonState
              onClick={_ => {
                mixpanelEvent(~eventName=`quickstart_integration_landing_option`, ())
                handleIntegration()->ignore
              }}
              buttonSize=Small
            />}
          />
        </div>
      </div>
    | CUSTOM_INTEGRATION =>
      <div className="flex h-full">
        <HSSelfServeSidebar
          heading="Integrate your app"
          sidebarOptions={enumDetails->getSidebarOptionsForIntegrateYourApp(
            quickStartPageState,
            currentRoute,
            choiceState,
          )}
        />
        <div className="flex-1 flex flex-col items-center justify-center ml-12">
          <CustomIntegrationPage currentRoute markAsDone={handleMarkAsDone} />
        </div>
      </div>
    }}
  </>
}

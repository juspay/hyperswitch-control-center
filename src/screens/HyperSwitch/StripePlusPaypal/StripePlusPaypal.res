open StripePlusPaypalUtils
open ConnectorTypes
open QuickStartTypes

let steps: array<step> = [STRIPE_CONFIGURE, PAYPAL_CONFIGURE, TEST_PAYMENT]

@react.component
let make = () => {
  let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
  let enums = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict
  let getEnumDetails = EnumVariantHook.useFetchEnumDetails()
  let (selectedConnector, setSelectedConnector) = React.useState(_ => STRIPE)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->Js.Json.object_)
  let (connectorConfigureState, setConnectorConfigureState) = React.useState(_ => Configure_keys)
  let (stepInView, setStepInView) = React.useState(_ => STRIPE_CONFIGURE)
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString
  let activeBusinessProfile =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getValueFromBusinessProfile

  let naviagteToHome = _ => {
    setDashboardPageState(_ => #HOME)
    RescriptReactRouter.replace("/home")
  }

  let handleNavigation = async (~forward: bool) => {
    if selectedConnector === STRIPE {
      if enums.paypalConnected.processorID->String.length === 0 {
        setSelectedConnector(_ => PAYPAL)
        setConnectorConfigureState(_ => Configure_keys)
        setInitialValues(_ => Dict.make()->Js.Json.object_)
        setStepInView(prev => {
          switch prev {
          | STRIPE_CONFIGURE => forward ? PAYPAL_CONFIGURE : STRIPE_CONFIGURE
          | PAYPAL_CONFIGURE => forward ? TEST_PAYMENT : STRIPE_CONFIGURE
          | TEST_PAYMENT => forward ? COMPLETED_STRIPE_PAYPAL : PAYPAL_CONFIGURE
          | COMPLETED_STRIPE_PAYPAL => forward ? COMPLETED_STRIPE_PAYPAL : TEST_PAYMENT
          }
        })
      }
    } else {
      setStepInView(_ => TEST_PAYMENT)
    }
  }

  let setPageState = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let enums =
        (await getEnumDetails(QuickStartUtils.quickStartEnumIntialArray))
        ->Js.Nullable.toOption
        ->Belt.Option.getWithDefault(Dict.make())
        ->Js.Json.object_
        ->QuickStartUtils.getTypedValueFromDict

      let currentPending = steps->Array.find(step => {
        step->enumToValueMapper(enums) === false
      })

      switch currentPending {
      | Some(step) => {
          if step === PAYPAL_CONFIGURE {
            setSelectedConnector(_ => PAYPAL)
          }
          setStepInView(_ => step)
        }
      | None => setStepInView(_ => COMPLETED_STRIPE_PAYPAL)
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect0(() => {
    setPageState()->ignore
    None
  })

  React.useEffect1(() => {
    let defaultJsonOnNewConnector =
      [("profile_id", activeBusinessProfile.profile_id->Js.Json.string)]
      ->Dict.fromArray
      ->Js.Json.object_
    setInitialValues(_ => defaultJsonOnNewConnector)
    None
  }, [activeBusinessProfile.profile_id, connectorName])

  <PageLoaderWrapper screenState sectionHeight="!h-screen !w-full">
    <div className="flex h-full bg-blue-background_blue">
      <HSSelfServeSidebar
        heading="Setup Stripe Plus Paypal"
        sidebarOptions={enumDetails->getSidebarOptionsForStripePayalIntegration(stepInView)}
      />
      <div className="flex-1 flex flex-col items-center justify-center ml-12">
        {switch stepInView {
        | STRIPE_CONFIGURE
        | PAYPAL_CONFIGURE =>
          switch connectorConfigureState {
          | Configure_keys =>
            <SetupConnector.ConfigureProcessor
              selectedConnector
              initialValues
              setInitialValues
              setConnectorConfigureState
              isBackButtonVisible=false
            />
          | Setup_payment_methods =>
            <StripePlusPaypalUIUtils.SelectPaymentMethods
              initialValues
              selectedConnector
              setInitialValues
              setConnectorConfigureState
              buttonState
              setButtonState
            />
          | Summary =>
            <QuickStartUIUtils.BaseComponent
              headerText={connectorName->LogicUtils.capitalizeString}
              customIcon={<GatewayIcon
                gateway={connectorName->String.toUpperCase} className="w-6 h-6 rounded-md"
              />}
              customCss="show-scrollbar"
              nextButton={<Button
                text="Continue & Proceed"
                buttonSize=Small
                buttonState
                customButtonStyle="rounded-md"
                buttonType={Primary}
                onClick={_ => handleNavigation(~forward={true})->ignore}
              />}>
              <ConnectorPreview.ConnectorSummaryGrid
                connectorInfo={initialValues
                ->LogicUtils.getDictFromJsonObject
                ->ConnectorTableUtils.getProcessorPayloadType}
                connector=connectorName
                setScreenState={_ => ()}
                isPayoutFlow=false
              />
            </QuickStartUIUtils.BaseComponent>
          | _ => React.null
          }

        | TEST_PAYMENT => <StripePlusPaypalUIUtils.TestPayment setStepInView />
        | COMPLETED_STRIPE_PAYPAL =>
          <div className="bg-white rounded h-40-rem">
            <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
              iconName="account-setup-completed"
              statusText="Setup Stripe+Paypal Sandbox Setup Completed"
              buttonText="Go To Home"
              buttonOnClick={naviagteToHome}
              customWidth="w-30-rem text-center"
            />
          </div>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}

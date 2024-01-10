open UIUtils
open HSwitchUtils
open HSLocalStorage
open HSwitchGlobalVars
open APIUtils

module FeatureFlagEnabledComponent = {
  @react.component
  let make = (~isEnabled, ~children) => {
    let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
    let updateRoute = () => {
      setDashboardPageState(_ => #HOME)
      RescriptReactRouter.replace("/home")
      React.null
    }
    <> {isEnabled ? children : updateRoute()} </>
  }
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod()
  let {
    showFeedbackModal,
    setShowFeedbackModal,
    dashboardPageState,
    setDashboardPageState,
    setQuickStartPageState,
  } = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {isProdIntentCompleted} = React.useContext(GlobalProvider.defaultContext)
  let fetchBusinessProfiles = MerchantAccountUtils.useFetchBusinessProfiles()
  let fetchMerchantAccountDetails = MerchantAccountUtils.useFetchMerchantDetails()
  let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()
  let enumDetails =
    HyperswitchAtom.enumVariantAtom
    ->Recoil.useRecoilValueFromAtom
    ->LogicUtils.safeParse
    ->QuickStartUtils.getTypedValueFromDict

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getEnumDetails = EnumVariantHook.useFetchEnumDetails()
  let verificationDays = getFromMerchantDetails("verification")->LogicUtils.getIntFromString(-1)
  let userRole = getFromUserDetails("user_role")
  let modeText = featureFlagDetails.isLiveMode ? "Live Mode" : "Test Mode"
  let titleComingSoonMessage = "Coming Soon!"
  let subtitleComingSoonMessage = "We are currently working on this page."
  let modeStyles = featureFlagDetails.isLiveMode
    ? "bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green"
    : "bg-orange-600/80 border-orange-500 text-grey-700"

  let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled =
    (merchantDetailsValue->MerchantAccountUtils.getMerchantDetails).recon_status === Active

  let hyperSwitchAppSidebars = SidebarValues.getHyperSwitchAppSidebars(
    ~isReconEnabled,
    ~featureFlagDetails,
    ~userRole,
    (),
  )

  let comingSoonPage =
    <DefaultLandingPage
      width="90vw"
      title={titleComingSoonMessage}
      subtitle={subtitleComingSoonMessage}
      height="100vh"
      overriddingStylesTitle="text-3xl font-semibold"
      overriddingStylesSubtitle="text-2xl font-semibold opacity-50"
    />

  sessionExpired := false

  let getAgreementEnum = async () => {
    open LogicUtils
    try {
      let url = #ProductionAgreement->ProdOnboardingUtils.getProdOnboardingUrl
      let response = await fetchDetails(url)

      let productionAgreementResponse =
        response
        ->getArrayFromJson([])
        ->Array.find(ele => {
          ele->getDictFromJsonObject->getBool("ProductionAgreement", false)
        })
        ->Option.getWithDefault(Js.Json.null)

      if productionAgreementResponse->getDictFromJsonObject->getBool("ProductionAgreement", false) {
        setDashboardPageState(_ => #PROD_ONBOARDING)
      } else {
        setDashboardPageState(_ => #AGREEMENT_SIGNATURE)
      }
    } catch {
    | _ =>
      setDashboardPageState(_ => #HOME)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let fetchInitialEnums = async () => {
    try {
      let response = await getEnumDetails(QuickStartUtils.quickStartEnumIntialArray)
      let responseValueDict =
        response->Js.Nullable.toOption->Belt.Option.getWithDefault(Dict.make())
      let pageStateToSet = responseValueDict->QuickStartUtils.getCurrentStep
      setQuickStartPageState(_ => pageStateToSet->QuickStartUtils.enumToVarinatMapper)
      responseValueDict
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }

  let setUpDashboard = async () => {
    try {
      let _ = await Window.connectorWasmInit()
      let _ = await fetchBusinessProfiles()
      let _ = await fetchConnectorListResponse()
      let _ = await fetchMerchantAccountDetails()

      if featureFlagDetails.quickStart {
        let _ = await fetchInitialEnums()
      }

      if featureFlagDetails.isLiveMode {
        getAgreementEnum()->ignore
      } else {
        setDashboardPageState(_ => #HOME)
      }

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ =>
      setDashboardPageState(_ => #HOME)
      setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect0(() => {
    setUpDashboard()->ignore
    None
  })

  let setPageState = (pageState: ProviderTypes.dashboardPageStateTypes) => {
    setDashboardPageState(_ => pageState)
    React.null
  }

  let determineStripePlusPayPal = () => {
    if enumDetails->checkStripePlusPayPal {
      RescriptReactRouter.replace("/home")
      React.null
    } else {
      setPageState(#STRIPE_PLUS_PAYPAL)
    }
  }

  let determineWooCommerce = () => {
    if enumDetails->checkWooCommerce {
      RescriptReactRouter.replace("/home")
      React.null
    } else {
      setPageState(#WOOCOMMERCE_FLOW)
    }
  }

  let determineQuickStartPageState = () => {
    if (
      isProdIntentCompleted &&
      enumDetails.integrationCompleted &&
      enumDetails.testPayment.payment_id->String.length > 0
    ) {
      RescriptReactRouter.replace("/home")
      React.null
    } else {
      setPageState(#QUICK_START)
    }
  }

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen">
    <div>
      {switch dashboardPageState {
      | #POST_LOGIN_QUES_NOT_DONE => <PostLoginScreen />
      | #AUTO_CONNECTOR_INTEGRATION => <HSwitchSetupAccount />
      | #INTEGRATION_DOC => <UserOnboarding />
      | #AGREEMENT_SIGNATURE => <HSwitchAgreementScreen />
      | #PROD_ONBOARDING => <ProdOnboardingLanding />
      | #QUICK_START => <ConfigureControlCenter />
      | #HOME =>
        <div className="relative">
          <div className={`h-screen flex flex-col`}>
            <div className="flex relative overflow-auto h-screen ">
              <Sidebar path={url.path} sidebars={hyperSwitchAppSidebars} />
              <div
                className="flex relative flex-col flex-1 overflow-hidden bg-hyperswitch_background dark:bg-black overflow-scroll md:overflow-x-hidden">
                <RenderIf condition={verificationDays > 0}>
                  <DelayedVerificationBanner verificationDays={verificationDays} />
                </RenderIf>
                // TODO : To be removed after new navbar design
                <div className="border-b shadow hyperswitch_box_shadow ">
                  <div className="w-full max-w-fixedPageWidth px-9">
                    <Navbar
                      headerActions={<div className="relative flex items-center gap-4 my-2 ">
                        <HSwitchGlobalSearchBar />
                        <RenderIf condition={featureFlagDetails.switchMerchant}>
                          <SwitchMerchant userRole={userRole} isAddMerchantEnabled=true />
                        </RenderIf>
                        <div
                          className={`px-4 py-2 rounded whitespace-nowrap text-fs-13 ${modeStyles} font-semibold`}>
                          {modeText->React.string}
                        </div>
                      </div>}
                    />
                  </div>
                </div>
                <div
                  className="w-full h-screen overflow-x-scroll xl:overflow-x-hidden overflow-y-scroll">
                  <div
                    className="p-6 md:px-16 md:pb-16 pt-[3rem] flex flex-col gap-10 max-w-fixedPageWidth">
                    <ErrorBoundary>
                      {switch url.path {
                      | list{"home"} =>
                        <FeatureFlagEnabledComponent isEnabled={featureFlagDetails.default}>
                          {featureFlagDetails.quickStart ? <HomeV2 /> : <Home />}
                        </FeatureFlagEnabledComponent>
                      | list{"fraud-risk-management", ...remainingPath} =>
                        <FeatureFlagEnabledComponent isEnabled={featureFlagDetails.frm}>
                          <EntityScaffold
                            entityName="risk-management"
                            remainingPath
                            renderList={() => <FRMSelect />}
                            renderNewForm={() => <FRMConfigure />}
                            renderShow={_ => <FRMConfigure />}
                          />
                        </FeatureFlagEnabledComponent>
                      | list{"connectors", ...remainingPath} =>
                        <EntityScaffold
                          entityName="Connectors"
                          remainingPath
                          renderList={() => <ConnectorList />}
                          renderNewForm={() => <ConnectorHome />}
                          renderShow={_ => <ConnectorHome />}
                        />
                      | list{"payoutconnectors", ...remainingPath} =>
                        <EntityScaffold
                          entityName="PayoutConnectors"
                          remainingPath
                          renderList={() => <ConnectorList isPayoutFlow=true />}
                          renderNewForm={() => <ConnectorHome isPayoutFlow=true />}
                          renderShow={_ => <ConnectorHome isPayoutFlow=true />}
                        />
                      | list{"payments", ...remainingPath} =>
                        <FilterContext key="payments" index="payments" disableSessionStorage=true>
                          <EntityScaffold
                            entityName="Payments"
                            remainingPath
                            access=ReadWrite
                            renderList={() => <Orders />}
                            renderShow={id => <ShowOrder id />}
                          />
                        </FilterContext>
                      | list{"refunds", ...remainingPath} =>
                        <FilterContext key="refunds" index="refunds" disableSessionStorage=true>
                          <EntityScaffold
                            entityName="Refunds"
                            remainingPath
                            access=ReadWrite
                            renderList={() => <Refund />}
                            renderShow={id => <ShowRefund id />}
                          />
                        </FilterContext>
                      | list{"disputes", ...remainingPath} =>
                        <EntityScaffold
                          entityName="Disputes"
                          remainingPath
                          access=ReadWrite
                          renderList={() => <Disputes />}
                          renderShow={id => <ShowDisputes id />}
                        />
                      | list{"customers", ...remainingPath} =>
                        <FeatureFlagEnabledComponent isEnabled=featureFlagDetails.customersModule>
                          <EntityScaffold
                            entityName="Customers"
                            remainingPath
                            access=ReadWrite
                            renderList={() => <Customers />}
                            renderShow={id => <ShowCustomers id />}
                          />
                        </FeatureFlagEnabledComponent>
                      | list{"routing", ...remainingPath} =>
                        <EntityScaffold
                          entityName="Routing"
                          remainingPath
                          renderList={() => <RoutingStack remainingPath />}
                          renderShow={routingType => <RoutingConfigure routingType />}
                        />
                      | list{"users", "invite-users"} => <InviteUsers />
                      | list{"users", ...remainingPath} =>
                        <EntityScaffold
                          entityName="UserManagement"
                          remainingPath
                          access=ReadWrite
                          renderList={() => <UserRoleEntry />}
                          renderShow={_ => <UserRoleShowData />}
                        />
                      | list{"analytics-payments"} =>
                        <FilterContext key="PaymentsAnalytics" index="PaymentsAnalytics">
                          <PaymentAnalytics />
                        </FilterContext>
                      | list{"analytics-refunds"} =>
                        <FilterContext key="PaymentsRefunds" index="PaymentsRefunds">
                          <RefundsAnalytics />
                        </FilterContext>
                      | list{"analytics-user-journey"} =>
                        <FeatureFlagEnabledComponent
                          isEnabled=featureFlagDetails.userJourneyAnalytics>
                          <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
                            <UserJourneyAnalytics />
                          </FilterContext>
                        </FeatureFlagEnabledComponent>
                      | list{"monitoring"} => comingSoonPage
                      | list{"developer-api-keys"} => <KeyManagement.KeysManagement />
                      | list{"developer-system-metrics"} =>
                        <UIUtils.RenderIf
                          condition={userRole->String.includes("internal_") &&
                            featureFlagDetails.systemMetrics}>
                          <FilterContext key="SystemMetrics" index="SystemMetrics">
                            <SystemMetricsAnalytics />
                          </FilterContext>
                        </UIUtils.RenderIf>
                      | list{"payment-settings", ...remainingPath} =>
                        <EntityScaffold
                          entityName="PaymentSettings"
                          remainingPath
                          renderList={() => <PaymentSettingsList />}
                          renderShow={profileId =>
                            <PaymentSettings webhookOnly=false showFormOnly=false />}
                        />
                      | list{"recon"} =>
                        <FeatureFlagEnabledComponent isEnabled=featureFlagDetails.recon>
                          <Recon />
                        </FeatureFlagEnabledComponent>
                      | list{"sdk"} =>
                        <FeatureFlagEnabledComponent isEnabled={!featureFlagDetails.isLiveMode}>
                          <SDKPage />
                        </FeatureFlagEnabledComponent>
                      | list{"3ds"} => <HSwitchThreeDS />
                      | list{"surcharge"} =>
                        <FeatureFlagEnabledComponent isEnabled={featureFlagDetails.surcharge}>
                          <Surcharge />
                        </FeatureFlagEnabledComponent>
                      | list{"account-settings"} =>
                        <FeatureFlagEnabledComponent isEnabled=featureFlagDetails.sampleData>
                          <HSwitchSettings />
                        </FeatureFlagEnabledComponent>
                      | list{"account-settings", "profile"} => <HSwitchProfileSettings />
                      | list{"business-details"} =>
                        <FeatureFlagEnabledComponent isEnabled=featureFlagDetails.default>
                          <BusinessDetails />
                        </FeatureFlagEnabledComponent>
                      | list{"business-profiles"} =>
                        <FeatureFlagEnabledComponent isEnabled=featureFlagDetails.businessProfile>
                          <BusinessProfile />
                        </FeatureFlagEnabledComponent>
                      | list{"quick-start"} => determineQuickStartPageState()
                      | list{"woocommerce"} => determineWooCommerce()
                      | list{"stripe-plus-paypal"} => determineStripePlusPayPal()

                      | _ =>
                        RescriptReactRouter.replace(`${hyperSwitchFEPrefix}/home`)
                        <Home />
                      }}
                    </ErrorBoundary>
                  </div>
                </div>
              </div>
            </div>
            <RenderIf condition={showFeedbackModal && featureFlagDetails.feedback}>
              <HSwitchFeedBackModal
                modalHeading="We'd love to hear from you!"
                showModal={showFeedbackModal}
                setShowModal={setShowFeedbackModal}
              />
            </RenderIf>
            <RenderIf
              condition={featureFlagDetails.productionAccess || featureFlagDetails.quickStart}>
              <ProdIntentForm />
            </RenderIf>
          </div>
        </div>
      | #WOOCOMMERCE_FLOW => <WooCommerce />
      | #DEFAULT =>
        <div className="h-screen flex justify-center items-center">
          <Loader />
        </div>
      | #STRIPE_PLUS_PAYPAL => <StripePlusPaypal />
      }}
    </div>
  </PageLoaderWrapper>
}

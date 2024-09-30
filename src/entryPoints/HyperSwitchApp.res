@react.component
let make = () => {
  open HSwitchUtils
  open GlobalVars
  open APIUtils
  open PermissionUtils
  open LogicUtils
  open HyperswitchAtom
  let pageViewEvent = MixpanelHook.usePageView()
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod()
  let {
    showFeedbackModal,
    setShowFeedbackModal,
    dashboardPageState,
    setDashboardPageState,
    setQuickStartPageState,
    isProdIntentCompleted,
  } = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let enumDetails =
    enumVariantAtom->Recoil.useRecoilValueFromAtom->safeParse->QuickStartUtils.getTypedValueFromDict
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userPermissionJson, setuserPermissionJson) = Recoil.useRecoilState(userPermissionAtom)
  let getEnumDetails = EnumVariantHook.useFetchEnumDetails()
  let {userInfo: {orgId, merchantId, profileId, roleId}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let modeText = featureFlagDetails.isLiveMode ? "Live Mode" : "Test Mode"
  let modeStyles = featureFlagDetails.isLiveMode
    ? "bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green"
    : "bg-orange-600/80 border-orange-500 text-grey-700"

  let isReconEnabled = React.useMemo(() => {
    merchantDetailsTypedValue.recon_status === Active
  }, [merchantDetailsTypedValue.merchant_id])

  let isLiveUsersCounterEnabled = featureFlagDetails.liveUsersCounter
  let hyperSwitchAppSidebars = SidebarValues.useGetSidebarValues(~isReconEnabled)
  sessionExpired := false
  let fetchInitialEnums = async () => {
    try {
      let response = await getEnumDetails(QuickStartUtils.quickStartEnumIntialArray)
      let responseValueDict = response->getValFromNullableValue(Dict.make())
      let pageStateToSet = responseValueDict->QuickStartUtils.getCurrentStep
      setQuickStartPageState(_ => pageStateToSet->QuickStartUtils.enumToVarinatMapper)
      responseValueDict
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let fetchPermissions = async () => {
    try {
      let url = getURL(
        ~entityName=USERS,
        ~userType=#GET_PERMISSIONS,
        ~methodType=Get,
        ~queryParamerters=Some(`groups=true`),
      )
      let response = await fetchDetails(url)
      let permissionsValue =
        response->getArrayFromJson([])->Array.map(ele => ele->JSON.Decode.string->Option.getOr(""))
      let permissionJson =
        permissionsValue->Array.map(ele => ele->mapStringToPermissionType)->getPermissionJson
      setuserPermissionJson(_ => permissionJson)
      permissionJson
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
  let (renderKey, setRenderkey) = React.useState(_ => "")

  let setUpDashboard = async () => {
    try {
      Window.connectorWasmInit()->ignore
      let _ = await fetchPermissions()
      if featureFlagDetails.quickStart {
        let _ = await fetchInitialEnums()
      }
      switch url.path->urlPath {
      | list{"unauthorized"} => RescriptReactRouter.push(appendDashboardPath(~url="/home"))
      | _ => ()
      }
      setDashboardPageState(_ => #HOME)
      setRenderkey(_ => profileId)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }
  let path = url.path->List.toArray->Array.joinWith("/")

  React.useEffect(() => {
    setUpDashboard()->ignore
    None
  }, [orgId, merchantId, profileId])

  React.useEffect(() => {
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }
    None
  }, (featureFlagDetails.mixpanel, path))

  let determineStripePlusPayPal = () => {
    enumDetails->checkStripePlusPayPal
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #STRIPE_PLUS_PAYPAL)

    React.null
  }

  let determineWooCommerce = () => {
    enumDetails->checkWooCommerce
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #WOOCOMMERCE_FLOW)

    React.null
  }

  let determineQuickStartPageState = () => {
    isProdIntentCompleted->Option.getOr(false) &&
    enumDetails.integrationCompleted &&
    !(enumDetails.testPayment.payment_id->isEmptyString)
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #QUICK_START)

    React.null
  }
  <>
    <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
      <div>
        {switch dashboardPageState {
        | #AUTO_CONNECTOR_INTEGRATION => <HSwitchSetupAccount />
        // INTEGRATION_DOC AND PROD_ONBOARDING Need to be removed
        | #INTEGRATION_DOC => <UserOnboarding />
        | #PROD_ONBOARDING => <ProdOnboardingLanding />
        | #QUICK_START => <ConfigureControlCenter />
        | #HOME =>
          <div className="relative" key={renderKey}>
            // TODO: Change the key to only profileId once the userInfo starts sending profileId
            <div className={`h-screen flex flex-col`}>
              <div className="flex relative overflow-auto h-screen ">
                <Sidebar path={url.path} sidebars={hyperSwitchAppSidebars} />
                <div
                  className="flex relative flex-col flex-1  bg-hyperswitch_background dark:bg-black overflow-scroll md:overflow-x-hidden">
                  <div className="border-b shadow hyperswitch_box_shadow ">
                    <div className="w-full max-w-fixedPageWidth px-9">
                      <Navbar
                        headerActions={<div className="relative flex items-center gap-4 my-2 ">
                          <GlobalSearchBar />
                          <RenderIf condition={isInternalUser}>
                            <SwitchMerchantForInternal />
                          </RenderIf>
                          <ProfileSwitch />
                          <div
                            className={`px-4 py-2 rounded whitespace-nowrap text-fs-13 ${modeStyles} font-semibold`}>
                            {modeText->React.string}
                          </div>
                        </div>}
                        headerLeftActions={switch Window.env.logoUrl {
                        | Some(url) => <img alt="image" src={`${url}`} />
                        | None => React.null
                        }}
                      />
                    </div>
                    {switch url.path->urlPath {
                    | list{"home"} =>
                      <RenderIf condition=isLiveUsersCounterEnabled>
                        <ActivePaymentsCounter />
                      </RenderIf>
                    | _ => React.null
                    }}
                  </div>
                  <div
                    className="w-full h-screen overflow-x-scroll xl:overflow-x-hidden overflow-y-scroll">
                    <div
                      className="p-6 md:px-16 md:pb-16 pt-[4rem] flex flex-col gap-10 max-w-fixedPageWidth">
                      <ErrorBoundary>
                        {switch url.path->urlPath {
                        | list{"home", ..._}
                        | list{"recon"}
                        | list{"upload-files"}
                        | list{"run-recon"}
                        | list{"recon-analytics"}
                        | list{"reports"}
                        | list{"config-settings"}
                        | list{"file-processor"}
                        | list{"sdk"} =>
                          <MerchantAccountContainer />
                        | list{"connectors", ..._}
                        | list{"payoutconnectors", ..._}
                        | list{"3ds-authenticators", ..._}
                        | list{"pm-authentication-processor", ..._}
                        | list{"tax-processor", ..._}
                        | list{"fraud-risk-management", ..._}
                        | list{"configure-pmts", ..._}
                        | list{"routing", ..._}
                        | list{"payoutrouting", ..._} =>
                          <ConnectorContainer />
                        | list{"business-details", ..._}
                        | list{"business-profiles", ..._}
                        | list{"payment-settings", ..._} =>
                          <BusinessProfileContainer />
                        | list{"payments", ..._}
                        | list{"refunds", ..._}
                        | list{"disputes", ..._}
                        | list{"payouts", ..._} =>
                          <TransactionContainer />
                        | list{"analytics-payments"}
                        | list{"performance-monitor"}
                        | list{"analytics-refunds"}
                        | list{"analytics-disputes"} =>
                          <AnalyticsContainser />
                        | list{"new-analytics-payment"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.newAnalytics}
                            permission=userPermissionJson.analyticsView>
                            <FilterContext key="NewAnalytics" index="NewAnalytics">
                              <NewAnalyticsContainer />
                            </FilterContext>
                          </AccessControl>
                        | list{"customers", ...remainingPath} =>
                          <AccessControl
                            permission={userPermissionJson.operationsView}
                            isEnabled={[#Organization, #Merchant]->checkUserEntity}>
                            <EntityScaffold
                              entityName="Customers"
                              remainingPath
                              access=Access
                              renderList={() => <Customers />}
                              renderShow={(id, _) => <ShowCustomers id />}
                            />
                          </AccessControl>
                        | list{"users", ..._} => <UserManagementContainer />
                        | list{"analytics-user-journey"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.userJourneyAnalytics &&
                            [#Organization, #Merchant]->checkUserEntity}
                            permission=userPermissionJson.analyticsView>
                            <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
                              <UserJourneyAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"analytics-authentication"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.authenticationAnalytics &&
                            [#Organization, #Merchant]->checkUserEntity}
                            permission=userPermissionJson.analyticsView>
                            <FilterContext
                              key="AuthenticationAnalytics" index="AuthenticationAnalytics">
                              <AuthenticationAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"developer-api-keys"} =>
                          <AccessControl
                            permission=userPermissionJson.merchantDetailsManage
                            isEnabled={!checkUserEntity([#Profile])}>
                            <KeyManagement.KeysManagement />
                          </AccessControl>
                        | list{"developer-system-metrics"} =>
                          <AccessControl
                            isEnabled={isInternalUser && featureFlagDetails.systemMetrics}
                            permission=userPermissionJson.analyticsView>
                            <FilterContext key="SystemMetrics" index="SystemMetrics">
                              <SystemMetricsAnalytics />
                            </FilterContext>
                          </AccessControl>

                        | list{"compliance"} =>
                          <AccessControl
                            isEnabled=featureFlagDetails.complianceCertificate permission=Access>
                            <Compliance />
                          </AccessControl>
                        | list{"3ds"} =>
                          <AccessControl permission=userPermissionJson.workflowsView>
                            <HSwitchThreeDS />
                          </AccessControl>
                        | list{"surcharge"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.surcharge}
                            permission=userPermissionJson.workflowsView>
                            <Surcharge />
                          </AccessControl>
                        | list{"account-settings"} =>
                          <AccessControl
                            isEnabled=featureFlagDetails.sampleData
                            permission=userPermissionJson.merchantDetailsManage>
                            <HSwitchSettings />
                          </AccessControl>
                        | list{"account-settings", "profile", ...remainingPath} =>
                          <EntityScaffold
                            entityName="profile setting"
                            remainingPath
                            renderList={() => <HSwitchProfileSettings />}
                            renderShow={(_, _) => <ModifyTwoFaSettings />}
                          />
                        | list{"quick-start"} => determineQuickStartPageState()
                        | list{"woocommerce"} => determineWooCommerce()
                        | list{"stripe-plus-paypal"} => determineStripePlusPayPal()
                        | list{"search"} => <SearchResultsPage />
                        | list{"payment-attempts"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission=userPermissionJson.operationsView>
                            <PaymentAttemptTable />
                          </AccessControl>
                        | list{"payment-intents"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission=userPermissionJson.operationsView>
                            <PaymentIntentTable />
                          </AccessControl>
                        | list{"refunds-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission=userPermissionJson.operationsView>
                            <RefundsTable />
                          </AccessControl>
                        | list{"dispute-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission=userPermissionJson.operationsView>
                            <DisputeTable />
                          </AccessControl>
                        | list{"unauthorized"} => <UnauthorizedPage />
                        | _ =>
                          RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
                          <MerchantAccountContainer />
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
              <RenderIf condition={!featureFlagDetails.isLiveMode || featureFlagDetails.quickStart}>
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
  </>
}

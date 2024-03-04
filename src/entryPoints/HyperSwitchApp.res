@react.component
let make = () => {
  open UIUtils
  open HSwitchUtils
  open HSwitchGlobalVars
  open APIUtils
  open PermissionUtils
  open LogicUtils
  open HyperswitchAtom
  open HSLocalStorage

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
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()
  let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()
  let enumDetails =
    enumVariantAtom->Recoil.useRecoilValueFromAtom->safeParse->QuickStartUtils.getTypedValueFromDict
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userPermissionJson, setuserPermissionJson) = Recoil.useRecoilState(userPermissionAtom)
  let (companyNameModal, setCompanyNameModal) = React.useState(_ => false)
  let getEnumDetails = EnumVariantHook.useFetchEnumDetails()
  let verificationDays = getFromMerchantDetails("verification")->getIntFromString(-1)
  let merchantId = getFromMerchantDetails("merchant_id")
  let userRole = getFromUserDetails("user_role")

  let modeText = featureFlagDetails.isLiveMode ? "Live Mode" : "Test Mode"
  let modeStyles = featureFlagDetails.isLiveMode
    ? "bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green"
    : "bg-orange-600/80 border-orange-500 text-grey-700"

  let merchantDetailsTypedValue = useMerchantDetailsValue()
  let isReconEnabled = merchantDetailsTypedValue.recon_status === Active

  let hyperSwitchAppSidebars = SidebarValues.useGetSidebarValues(~isReconEnabled)

  sessionExpired := false

  let getAgreementEnum = async () => {
    try {
      let url = #ProductionAgreement->ProdOnboardingUtils.getProdOnboardingUrl
      let response = await fetchDetails(url)

      let productionAgreementResponse =
        response
        ->getArrayFromJson([])
        ->Array.find(ele => {
          ele->getDictFromJsonObject->getBool("ProductionAgreement", false)
        })
        ->Option.getOr(JSON.Encode.null)

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
      let url = getURL(~entityName=USERS, ~userType=#GET_PERMISSIONS, ~methodType=Get, ())
      let response = await fetchDetails(`${url}?groups=true`)
      let permissionsValue =
        response->getArrayFromJson([])->Array.map(ele => ele->JSON.Decode.string->Option.getOr(""))
      let permissionJson =
        permissionsValue->Array.map(ele => ele->mapStringToPermissionType)->getPermissionJson
      setuserPermissionJson(._ => permissionJson)
      permissionJson
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let setUpDashboard = async () => {
    try {
      let _ = await fetchSwitchMerchantList()
      let _ = await Window.connectorWasmInit()
      let permissionJson = await fetchPermissions()

      if merchantId->isNonEmptyString {
        if (
          permissionJson.connectorsView === Access ||
          permissionJson.workflowsView === Access ||
          permissionJson.workflowsManage === Access
        ) {
          let _ = await fetchConnectorListResponse()
        }

        let _ = await fetchBusinessProfiles()
        let _ = await fetchMerchantAccountDetails()
      }
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

  React.useEffect1(() => {
    if merchantDetailsTypedValue.merchant_name->Option.isNone {
      setCompanyNameModal(_ => true)
    } else {
      setCompanyNameModal(_ => false)
    }
    None
  }, [merchantDetailsTypedValue.merchant_name])

  let determineStripePlusPayPal = () => {
    enumDetails->checkStripePlusPayPal
      ? RescriptReactRouter.replace("/home")
      : setDashboardPageState(_ => #STRIPE_PLUS_PAYPAL)

    React.null
  }

  let determineWooCommerce = () => {
    enumDetails->checkWooCommerce
      ? RescriptReactRouter.replace("/home")
      : setDashboardPageState(_ => #WOOCOMMERCE_FLOW)

    React.null
  }

  let determineQuickStartPageState = () => {
    isProdIntentCompleted->Option.getOr(false) &&
    enumDetails.integrationCompleted &&
    !(enumDetails.testPayment.payment_id->isEmptyString)
      ? RescriptReactRouter.replace("/home")
      : setDashboardPageState(_ => #QUICK_START)

    React.null
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
                    className="p-6 md:px-16 md:pb-16 pt-[4rem] flex flex-col gap-10 max-w-fixedPageWidth">
                    <ErrorBoundary>
                      {switch url.path {
                      | list{"home"} => featureFlagDetails.quickStart ? <HomeV2 /> : <Home />
                      | list{"fraud-risk-management", ...remainingPath} =>
                        <AccessControl
                          isEnabled={featureFlagDetails.frm}
                          permission=userPermissionJson.connectorsView>
                          <EntityScaffold
                            entityName="risk-management"
                            remainingPath
                            renderList={() => <FRMSelect />}
                            renderNewForm={() => <FRMConfigure />}
                            renderShow={_ => <FRMConfigure />}
                          />
                        </AccessControl>

                      | list{"connectors", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.connectorsView>
                          <EntityScaffold
                            entityName="Connectors"
                            remainingPath
                            renderList={() => <ConnectorList />}
                            renderNewForm={() => <ConnectorHome />}
                            renderShow={_ => <ConnectorHome />}
                          />
                        </AccessControl>

                      | list{"payoutconnectors", ...remainingPath} =>
                        <AccessControl
                          isEnabled={featureFlagDetails.payOut}
                          permission=userPermissionJson.connectorsView>
                          <EntityScaffold
                            entityName="PayoutConnectors"
                            remainingPath
                            renderList={() => <ConnectorList isPayoutFlow=true />}
                            renderNewForm={() => <ConnectorHome isPayoutFlow=true />}
                            renderShow={_ => <ConnectorHome isPayoutFlow=true />}
                          />
                        </AccessControl>

                      | list{"payments", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.operationsView>
                          <FilterContext key="payments" index="payments" disableSessionStorage=true>
                            <EntityScaffold
                              entityName="Payments"
                              remainingPath
                              access=Access
                              renderList={() => <Orders />}
                              renderShow={id => <ShowOrder id />}
                            />
                          </FilterContext>
                        </AccessControl>
                      | list{"refunds", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.operationsView>
                          <FilterContext key="refunds" index="refunds" disableSessionStorage=true>
                            <EntityScaffold
                              entityName="Refunds"
                              remainingPath
                              access=Access
                              renderList={() => <Refund />}
                              renderShow={id => <ShowRefund id />}
                            />
                          </FilterContext>
                        </AccessControl>
                      | list{"disputes", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.operationsView>
                          <EntityScaffold
                            entityName="Disputes"
                            remainingPath
                            access=Access
                            renderList={() => <Disputes />}
                            renderShow={id => <ShowDisputes id />}
                          />
                        </AccessControl>
                      | list{"customers", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.operationsView>
                          <EntityScaffold
                            entityName="Customers"
                            remainingPath
                            access=Access
                            renderList={() => <Customers />}
                            renderShow={id => <ShowCustomers id />}
                          />
                        </AccessControl>
                      | list{"routing", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.workflowsView>
                          <EntityScaffold
                            entityName="Routing"
                            remainingPath
                            renderList={() => <RoutingStack remainingPath />}
                            renderShow={routingType => <RoutingConfigure routingType />}
                          />
                        </AccessControl>
                      | list{"users", "invite-users"} =>
                        <AccessControl permission=userPermissionJson.usersManage>
                          <InviteUsers />
                        </AccessControl>
                      | list{"users", ...remainingPath} =>
                        <AccessControl permission=userPermissionJson.usersView>
                          <EntityScaffold
                            entityName="UserManagement"
                            remainingPath
                            renderList={_ => <UserRoleEntry />}
                            renderShow={_ => <ShowUserData />}
                          />
                        </AccessControl>
                      | list{"analytics-payments"} =>
                        <AccessControl permission=userPermissionJson.analyticsView>
                          <FilterContext key="PaymentsAnalytics" index="PaymentsAnalytics">
                            <PaymentAnalytics />
                          </FilterContext>
                        </AccessControl>
                      | list{"analytics-refunds"} =>
                        <AccessControl permission=userPermissionJson.analyticsView>
                          <FilterContext key="PaymentsRefunds" index="PaymentsRefunds">
                            <RefundsAnalytics />
                          </FilterContext>
                        </AccessControl>
                      | list{"analytics-user-journey"} =>
                        <AccessControl
                          isEnabled=featureFlagDetails.userJourneyAnalytics
                          permission=userPermissionJson.analyticsView>
                          <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
                            <UserJourneyAnalytics />
                          </FilterContext>
                        </AccessControl>
                      | list{"developer-api-keys"} =>
                        <AccessControl permission=userPermissionJson.merchantDetailsManage>
                          <KeyManagement.KeysManagement />
                        </AccessControl>
                      | list{"developer-system-metrics"} =>
                        <AccessControl
                          isEnabled={userRole->String.includes("internal_") &&
                            featureFlagDetails.systemMetrics}
                          permission=userPermissionJson.analyticsView>
                          <FilterContext key="SystemMetrics" index="SystemMetrics">
                            <SystemMetricsAnalytics />
                          </FilterContext>
                        </AccessControl>

                      // TODO : reevaluatet the conditions
                      | list{"payment-settings", ...remainingPath} =>
                        <EntityScaffold
                          entityName="PaymentSettings"
                          remainingPath
                          renderList={() => <PaymentSettingsList />}
                          renderShow={profileId =>
                            <PaymentSettings webhookOnly=false showFormOnly=false />}
                        />
                      | list{"recon"} =>
                        <AccessControl isEnabled=featureFlagDetails.recon permission=Access>
                          <Recon />
                        </AccessControl>
                      | list{"sdk"} =>
                        <AccessControl isEnabled={!featureFlagDetails.isLiveMode} permission=Access>
                          <SDKPage />
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
                      | list{"account-settings", "profile"} => <HSwitchProfileSettings />

                      // TODO : reevaluate the condition
                      | list{"business-details"} =>
                        <AccessControl isEnabled=featureFlagDetails.default permission={Access}>
                          <BusinessDetails />
                        </AccessControl>
                      | list{"business-profiles"} =>
                        <AccessControl
                          isEnabled=featureFlagDetails.businessProfile permission=Access>
                          <BusinessProfile />
                        </AccessControl>
                      | list{"quick-start"} => determineQuickStartPageState()
                      | list{"woocommerce"} => determineWooCommerce()
                      | list{"stripe-plus-paypal"} => determineStripePlusPayPal()
                      | list{"unauthorized"} => <UnauthorizedPage />
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
            <RenderIf
              condition={userPermissionJson.merchantDetailsManage === Access &&
                merchantDetailsTypedValue.merchant_name->Option.isNone}>
              <CompanyNameModal showModal=companyNameModal setShowModal=setCompanyNameModal />
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

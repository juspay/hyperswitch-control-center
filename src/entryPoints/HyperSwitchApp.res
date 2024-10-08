@react.component
let make = () => {
  open HSwitchUtils
  open GlobalVars
  open APIUtils

  open HyperswitchAtom
  let pageViewEvent = MixpanelHook.usePageView()
  let url = RescriptReactRouter.useUrl()

  let {
    showFeedbackModal,
    setShowFeedbackModal,
    dashboardPageState,
    setDashboardPageState,
  } = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let userPermissionMap = Recoil.useRecoilValueFromAtom(userPermissionAtomMapType)
  let {fetchUserPermissions, userHasAccess} = PermissionHooks.useUserPermissionHook()
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

  // let fetchPermissions = async () => {
  //   try {
  //     let url = getURL(
  //       ~entityName=USERS,
  //       ~userType=#GET_PERMISSIONS,
  //       ~methodType=Get,
  //       ~queryParamerters=Some(`groups=true`),
  //     )
  //     let response = await fetchDetails(url)
  //     let permissionsValue =
  //       response->getArrayFromJson([])->Array.map(ele => ele->JSON.Decode.string->Option.getOr(""))
  //     Js.log2(
  //       "permissionsValue",
  //       permissionsValue
  //       ->Array.map(ele => ele->mapStringToPermissionType)
  //       ->HyperSwitchEntryUtils.convertValueToMap,
  //     )
  //     setuserPermissionMap(_ => Some(
  //       permissionsValue
  //       ->Array.map(ele => ele->mapStringToPermissionType)
  //       ->HyperSwitchEntryUtils.convertValueToMap,
  //     ))
  //     let permissionJson =
  //       permissionsValue->Array.map(ele => ele->mapStringToPermissionType)->getPermissionJson
  //     setuserPermissionJson(_ => permissionJson)
  //     permissionJson
  //   } catch {
  //   | Exn.Error(e) => {
  //       let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
  //       Exn.raiseError(err)
  //     }
  //   }
  // }
  let (renderKey, setRenderkey) = React.useState(_ => "")

  let setUpDashboard = async () => {
    try {
      Window.connectorWasmInit()->ignore
      let _ = await fetchUserPermissions()
      switch url.path->urlPath {
      | list{"unauthorized"} => RescriptReactRouter.push(appendDashboardPath(~url="/home"))
      | _ => ()
      }
      setDashboardPageState(_ => #HOME)
      setRenderkey(_ => profileId)
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

  React.useEffect1(() => {
    if userPermissionMap->Option.isSome {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [userPermissionMap])

  <>
    <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
      <div>
        {switch dashboardPageState {
        | #AUTO_CONNECTOR_INTEGRATION => <HSwitchSetupAccount />
        // INTEGRATION_DOC Need to be removed
        | #INTEGRATION_DOC => <UserOnboarding />
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
                            permission={userHasAccess(~permission=AnalyticsView)}>
                            <FilterContext key="NewAnalytics" index="NewAnalytics">
                              <NewAnalyticsContainer />
                            </FilterContext>
                          </AccessControl>
                        | list{"customers", ...remainingPath} =>
                          <AccessControl
                            permission={userHasAccess(~permission=OperationsView)}
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
                            permission={userHasAccess(~permission=AnalyticsView)}>
                            <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
                              <UserJourneyAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"analytics-authentication"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.authenticationAnalytics &&
                            [#Organization, #Merchant]->checkUserEntity}
                            permission={userHasAccess(~permission=AnalyticsView)}>
                            <FilterContext
                              key="AuthenticationAnalytics" index="AuthenticationAnalytics">
                              <AuthenticationAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"developer-api-keys"} =>
                          <AccessControl
                            permission={userHasAccess(~permission=MerchantDetailsManage)}
                            isEnabled={!checkUserEntity([#Profile])}>
                            <KeyManagement.KeysManagement />
                          </AccessControl>
                        | list{"developer-system-metrics"} =>
                          <AccessControl
                            isEnabled={isInternalUser && featureFlagDetails.systemMetrics}
                            permission={userHasAccess(~permission=AnalyticsView)}>
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
                          <AccessControl permission={userHasAccess(~permission=WorkflowsView)}>
                            <HSwitchThreeDS />
                          </AccessControl>
                        | list{"surcharge"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.surcharge}
                            permission={userHasAccess(~permission=WorkflowsView)}>
                            <Surcharge />
                          </AccessControl>
                        | list{"account-settings"} =>
                          <AccessControl
                            isEnabled=featureFlagDetails.sampleData
                            permission={userHasAccess(~permission=MerchantDetailsManage)}>
                            <HSwitchSettings />
                          </AccessControl>
                        | list{"account-settings", "profile", ...remainingPath} =>
                          <EntityScaffold
                            entityName="profile setting"
                            remainingPath
                            renderList={() => <HSwitchProfileSettings />}
                            renderShow={(_, _) => <ModifyTwoFaSettings />}
                          />
                        | list{"search"} => <SearchResultsPage />
                        | list{"payment-attempts"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission={userHasAccess(~permission=OperationsView)}>
                            <PaymentAttemptTable />
                          </AccessControl>
                        | list{"payment-intents"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission={userHasAccess(~permission=OperationsView)}>
                            <PaymentIntentTable />
                          </AccessControl>
                        | list{"refunds-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission={userHasAccess(~permission=OperationsView)}>
                            <RefundsTable />
                          </AccessControl>
                        | list{"dispute-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            permission={userHasAccess(~permission=OperationsView)}>
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
        | #DEFAULT =>
          <div className="h-screen flex justify-center items-center">
            <Loader />
          </div>
        }}
      </div>
    </PageLoaderWrapper>
  </>
}

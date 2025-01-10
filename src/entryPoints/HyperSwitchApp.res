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
  let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)
  let {getThemesJson} = React.useContext(ThemeProvider.themeContext)
  let {devThemeFeature} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {
    fetchMerchantSpecificConfig,
    useIsFeatureEnabledForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {fetchUserGroupACL, userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()

  let {
    userInfo: {orgId, merchantId, profileId, roleId, themeId},
    checkUserEntity,
  } = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let modeText = featureFlagDetails.isLiveMode ? "Live Mode" : "Test Mode"
  let modeStyles = featureFlagDetails.isLiveMode
    ? "bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green"
    : "bg-orange-600/80 border-orange-500 text-grey-700"

  let isReconEnabled = React.useMemo(() => {
    merchantDetailsTypedValue.recon_status === Active
  }, [merchantDetailsTypedValue.merchant_id])

  let isLiveUsersCounterEnabled = featureFlagDetails.liveUsersCounter
  let underMaintenance = featureFlagDetails.underMaintenance
  let hyperSwitchAppSidebars = SidebarValues.useGetSidebarValues(~isReconEnabled)
  let reconSidebars = HSReconSidebarValues.useGetReconSideBar()
  sessionExpired := false

  let setUpDashboard = async () => {
    try {
      // NOTE: Treat groupACL map similar to screenstate
      setScreenState(_ => PageLoaderWrapper.Loading)
      setuserGroupACL(_ => None)
      Window.connectorWasmInit()->ignore
      let _ = await fetchMerchantSpecificConfig()
      let _ = await fetchUserGroupACL()
      let _ = await getThemesJson(themeId, JSON.Encode.null, devThemeFeature)
      switch url.path->urlPath {
      | list{"unauthorized"} => RescriptReactRouter.push(appendDashboardPath(~url="/home"))
      | _ => ()
      }
      setDashboardPageState(_ => #HOME)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to setup dashboard!"))
    }
  }
  let path = url.path->List.toArray->Array.joinWith("/")

  React.useEffect(() => {
    setUpDashboard()->ignore
    None
  }, [orgId, merchantId, profileId, themeId])

  React.useEffect(() => {
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }
    None
  }, (featureFlagDetails.mixpanel, path))

  React.useEffect1(() => {
    if userGroupACL->Option.isSome {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [userGroupACL])

  let ompDropdowns =
    <div className="flex items-center gap-4 mx-4">
      <RenderIf condition={!isInternalUser}>
        <MerchantSwitch />
        <p className="text-gray-400 text-fs-14"> {"/"->React.string} </p>
      </RenderIf>
      <ProfileSwitch />
    </div>
  <>
    <div>
      {switch dashboardPageState {
      | #AUTO_CONNECTOR_INTEGRATION => <HSwitchSetupAccount />
      // INTEGRATION_DOC Need to be removed
      | #INTEGRATION_DOC => <UserOnboarding />
      | #HOME =>
        <div className="relative">
          // TODO: Change the key to only profileId once the userInfo starts sending profileId
          <div className={`h-screen flex flex-col`}>
            <div className="flex relative overflow-auto h-screen ">
              <RenderIf condition={screenState === Success}>
                <Sidebar
                  path={url.path}
                  sidebars={hyperSwitchAppSidebars}
                  key={(screenState :> string)}
                  productSiebars={reconSidebars}
                />
              </RenderIf>
              <PageLoaderWrapper
                screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
                <div
                  className="flex relative flex-col flex-1  bg-hyperswitch_background dark:bg-black overflow-scroll md:overflow-x-hidden">
                  <div className="border-b shadow hyperswitch_box_shadow ">
                    <div className="w-full max-w-fixedPageWidth px-9">
                      <Navbar
                        headerActions={<div className="relative flex space-around gap-4 my-2 ">
                          <div className="flex gap-4">
                            <GlobalSearchBar />
                            <RenderIf condition={isInternalUser}>
                              <SwitchMerchantForInternal />
                            </RenderIf>
                            <div
                              className={`px-4 py-2 rounded whitespace-nowrap text-fs-13 ${modeStyles} font-semibold`}>
                              {modeText->React.string}
                            </div>
                          </div>
                        </div>}
                        headerLeftActions={switch Window.env.urlThemeConfig.logoUrl {
                        | Some(url) =>
                          <>
                            <img className="w-40" alt="image" src={`${url}`} />
                            {ompDropdowns}
                          </>
                        | None => ompDropdowns
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
                    //to be removed once maintenance is done
                    <RenderIf condition={underMaintenance}>
                      <HSwitchUtils.AlertBanner
                        warningText="Maintenance Alert: The Sandbox Dashboard will be unavailable from 12:30 PM to 1:30 PM IST for scheduled maintenance."
                        bannerType={Info}
                      />
                    </RenderIf>
                    <div
                      className="p-6 md:px-16 md:pb-16 pt-[4rem] flex flex-col gap-10 max-w-fixedPageWidth">
                      <ErrorBoundary>
                        {switch url.path->urlPath {
                        | list{"v2", "recon", ..._} => <HSReconApp />
                        | list{"home", ..._}
                        | list{"recon"}
                        | list{"upload-files"}
                        | list{"run-recon"}
                        | list{"recon-analytics"}
                        | list{"reports"}
                        | list{"config-settings"}
                        | list{"sdk"} =>
                          <MerchantAccountContainer setAppScreenState=setScreenState />
                        // Commented as not needed now
                        // list{"file-processor"}

                        | list{"connectors", ..._}
                        | list{"payoutconnectors", ..._}
                        | list{"3ds-authenticators", ..._}
                        | list{"pm-authentication-processor", ..._}
                        | list{"tax-processor", ..._}
                        | list{"fraud-risk-management", ..._}
                        | list{"configure-pmts", ..._}
                        | list{"routing", ..._}
                        | list{"payoutrouting", ..._}
                        | list{"payment-settings", ..._} =>
                          <ConnectorContainer />
                        | list{"business-details", ..._}
                        | list{"business-profiles", ..._} =>
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
                          <AnalyticsContainer />
                        | list{"new-analytics-payment"}
                        | list{"new-analytics-refund"}
                        | list{"new-analytics-smart-retry"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.newAnalytics &&
                            useIsFeatureEnabledForMerchant(merchantSpecificConfig.newAnalytics)}
                            authorization={userHasAccess(~groupAccess=AnalyticsView)}>
                            <FilterContext key="NewAnalytics" index="NewAnalytics">
                              <NewAnalyticsContainer />
                            </FilterContext>
                          </AccessControl>
                        | list{"customers", ...remainingPath} =>
                          <AccessControl
                            authorization={userHasAccess(~groupAccess=OperationsView)}
                            isEnabled={[#Tenant, #Organization, #Merchant]->checkUserEntity}>
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
                            [#Tenant, #Organization, #Merchant]->checkUserEntity}
                            authorization={userHasAccess(~groupAccess=AnalyticsView)}>
                            <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
                              <UserJourneyAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"analytics-authentication"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.authenticationAnalytics &&
                            [#Tenant, #Organization, #Merchant]->checkUserEntity}
                            authorization={userHasAccess(~groupAccess=AnalyticsView)}>
                            <FilterContext
                              key="AuthenticationAnalytics" index="AuthenticationAnalytics">
                              <AuthenticationAnalytics />
                            </FilterContext>
                          </AccessControl>
                        | list{"developer-api-keys"} =>
                          <AccessControl
                            // TODO: Remove `MerchantDetailsManage` permission in future
                            authorization={hasAnyGroupAccess(
                              userHasAccess(~groupAccess=MerchantDetailsManage),
                              userHasAccess(~groupAccess=AccountManage),
                            )}
                            isEnabled={!checkUserEntity([#Profile])}>
                            <KeyManagement.KeysManagement />
                          </AccessControl>
                        | list{"developer-system-metrics"} =>
                          <AccessControl
                            isEnabled={isInternalUser && featureFlagDetails.systemMetrics}
                            authorization={userHasAccess(~groupAccess=AnalyticsView)}>
                            <FilterContext key="SystemMetrics" index="SystemMetrics">
                              <SystemMetricsAnalytics />
                            </FilterContext>
                          </AccessControl>

                        | list{"compliance"} =>
                          <AccessControl
                            isEnabled=featureFlagDetails.complianceCertificate authorization=Access>
                            <Compliance />
                          </AccessControl>
                        | list{"3ds"} =>
                          <AccessControl authorization={userHasAccess(~groupAccess=WorkflowsView)}>
                            <HSwitchThreeDS />
                          </AccessControl>
                        | list{"surcharge"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.surcharge}
                            authorization={userHasAccess(~groupAccess=WorkflowsView)}>
                            <Surcharge />
                          </AccessControl>
                        | list{"account-settings"} =>
                          <AccessControl
                            isEnabled=featureFlagDetails.sampleData
                            // TODO: Remove `MerchantDetailsManage` permission in future
                            authorization={hasAnyGroupAccess(
                              userHasAccess(~groupAccess=MerchantDetailsManage),
                              userHasAccess(~groupAccess=AccountManage),
                            )}>
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
                            authorization={userHasAccess(~groupAccess=OperationsView)}>
                            <PaymentAttemptTable />
                          </AccessControl>
                        | list{"payment-intents"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            authorization={userHasAccess(~groupAccess=OperationsView)}>
                            <PaymentIntentTable />
                          </AccessControl>
                        | list{"refunds-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            authorization={userHasAccess(~groupAccess=OperationsView)}>
                            <RefundsTable />
                          </AccessControl>
                        | list{"dispute-global"} =>
                          <AccessControl
                            isEnabled={featureFlagDetails.globalSearch}
                            authorization={userHasAccess(~groupAccess=OperationsView)}>
                            <DisputeTable />
                          </AccessControl>
                        | list{"unauthorized"} => <UnauthorizedPage />
                        | _ =>
                          RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
                          <MerchantAccountContainer setAppScreenState=setScreenState />
                        }}
                      </ErrorBoundary>
                    </div>
                  </div>
                </div>
              </PageLoaderWrapper>
            </div>
            <RenderIf condition={showFeedbackModal && featureFlagDetails.feedback}>
              <HSwitchFeedBackModal
                modalHeading="We'd love to hear from you!"
                showModal={showFeedbackModal}
                setShowModal={setShowFeedbackModal}
              />
            </RenderIf>
            <RenderIf condition={!featureFlagDetails.isLiveMode}>
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
  </>
}

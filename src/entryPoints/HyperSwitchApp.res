@react.component
let make = () => {
  open HSwitchUtils
  open APIUtils
  open HyperswitchAtom
  open HyperswitchAppHelper

  let url = RescriptReactRouter.useUrl()
  let isDecisionEngineWorkspace = url.path->urlPath->DecisionEngineUtils.isWorkspacePath
  let {
    showFeedbackModal,
    setShowFeedbackModal,
    dashboardPageState,
    setDashboardPageState,
  } = React.useContext(GlobalProvider.defaultContext)

  let {activeProduct, setActiveProductValue} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (merchantDetailsTypedValue, setMerchantDetailsValue) = Recoil.useRecoilState(
    merchantDetailsValueAtom,
  )
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)
  let {getThemesJson} = React.useContext(ThemeProvider.themeContext)
  let {fetchMerchantSpecificConfig} = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {fetchUserGroupACL, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchMerchantList = MerchantListHook.useFetchMerchantList()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let fetchUserMerchantDetails = MerchantDetailsHook.useFetchUserMerchantDetails()
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let {getCommonSessionDetails, getResolvedUserInfo} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {roleId} = getResolvedUserInfo()
  let {orgId, merchantId, profileId, version} = getCommonSessionDetails()

  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let {logoURL} = React.useContext(ThemeProvider.themeContext)
  let maintenanceAlert = featureFlagDetails.maintenanceAlert
  // Shown on the default home and on the active product's landing page (ProductUtils.getProductUrl)
  let showMaintenanceAlert = {
    let productLandingPath =
      ProductUtils.getProductUrl(~productType=activeProduct)
      ->String.split("/")
      ->Array.filter(LogicUtils.isNonEmptyString)
      ->List.fromArray
      ->urlPath
    let currentPath = url.path->urlPath
    maintenanceAlert->LogicUtils.isNonEmptyString &&
      switch currentPath {
      | list{"v2", "home"} | list{"v2", "recovery"} => true
      | _ => currentPath == productLandingPath
      }
  }
  DecisionEngineHooks.useSyncDecisionEngineCutover()
  let hyperSwitchAppSidebars = SidebarHooks.useGetSidebarValuesForCurrentActive()
  let productSidebars = ProductsSidebarValues.useGetProductSideBarValues(~activeProduct)

  sessionExpired := false
  let themeId = HyperSwitchEntryUtils.getThemeIdfromStore()
  let applyTheme = async () => {
    try {
      let _ = await getThemesJson(~themesID=themeId)
    } catch {
    | _ => ()
    }
  }

  let setUpDashboard = async () => {
    try {
      // NOTE: Treat groupACL map similar to screenstate
      setScreenState(_ => PageLoaderWrapper.Loading)
      setuserGroupACL(_ => None)
      // Reset so a switch to a merchant without account access doesn't keep the previous keys
      setMerchantDetailsValue(_ =>
        JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails
      )
      setActiveProductValue(UnknownProduct)
      Window.connectorWasmInit()->ignore
      // Initiate all independent api requests concurrently for performance improvement
      let merchantDetailsFetch = fetchUserMerchantDetails(~version)
      let merchantConfigFetch = fetchMerchantSpecificConfig()
      let merchantListFetch = if !isInternalUser {
        fetchMerchantList()
      } else {
        Promise.resolve()
      }
      let userGroupACLFetch = fetchUserGroupACL()
      // The full merchant account needs the account resource, so wait for the ACL
      // and only fetch it for roles that hold it; everyone else keeps the defaults
      let merchantAccountFetch = async () => {
        let {resources} = await userGroupACLFetch
        switch resources->Map.get(UserManagementTypes.Account) {
        | Some(CommonAuthTypes.Access) =>
          let _ = await fetchMerchantAccountDetails(~version)
        | _ => ()
        }
      }
      let (productType, _, _, _, _) = await Promise.all5((
        merchantDetailsFetch,
        merchantConfigFetch,
        merchantListFetch,
        userGroupACLFetch,
        merchantAccountFetch(),
      ))
      setActiveProductValue(productType)
      setShowSideBar(_ => true)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to setup dashboard!"))
    }
  }

  React.useEffect(() => {
    setUpDashboard()->ignore
    None
  }, [orgId, merchantId, profileId])

  React.useEffect(() => {
    applyTheme()->ignore
    None
  }, [themeId])

  React.useEffect(() => {
    if userGroupACL->Option.isSome {
      setDashboardPageState(_ => #HOME)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [userGroupACL])
  let pageViewEvent = MixpanelHook.usePageView()
  let path = url.path->List.toArray->Array.joinWith("/")

  React.useEffect(() => {
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }
    None
  }, (featureFlagDetails.mixpanel, path))

  let leftCustomClass = switch activeProduct {
  | Orchestration(V1) => ""
  | _ => "-left-180-px"
  }

  let showGlobalSearchBar = switch merchantDetailsTypedValue.product_type {
  | Orchestration(V1) => featureFlagDetails.globalSearch
  | _ => false
  }

  let showReconEngineStatus = switch activeProduct {
  | Recon(V1) => featureFlagDetails.devReconEngineV1
  | _ => false
  }

  <>
    <div>
      {switch dashboardPageState {
      | #HOME =>
        <div className="relative">
          // TODO: Change the key to only profileId once the userInfo starts sending profileId
          <div className={`h-screen flex flex-col`}>
            <div className="flex relative  h-screen ">
              <RenderIf condition={screenState === Success}>
                <Sidebar
                  path=url.path sidebars={hyperSwitchAppSidebars} productSiebars=productSidebars
                />
              </RenderIf>
              <PageLoaderWrapper
                screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
                <div
                  className="flex relative flex-col flex-1 bg-hyperswitch_background dark:bg-black overflow-scroll md:overflow-x-hidden">
                  <div className="w-full max-w-fixedPageWidth md:px-12 px-5 pt-3">
                    <Navbar
                      headerActions={<div className="relative flex space-around gap-4 my-2 ">
                        <div className="flex gap-4 items-center">
                          <RenderIf condition={showReconEngineStatus}>
                            <ReconEngineStatusIndicator />
                          </RenderIf>
                          <RenderIf condition={showGlobalSearchBar}>
                            <GlobalSearchBar />
                          </RenderIf>
                          <RenderIf condition={isInternalUser}>
                            <SwitchMerchantForInternal />
                          </RenderIf>
                          <RenderIf condition={featureFlagDetails.devLaunchSage}>
                            <LaunchSageButton />
                          </RenderIf>
                        </div>
                      </div>}
                      headerLeftActions={
                        let logoElement = switch logoURL {
                        | Some(url) if url->LogicUtils.isNonEmptyString =>
                          <img className="h-6 w-auto object-contain" alt="image" src=url />
                        | _ => React.null
                        }
                        <div className="flex md:gap-4 gap-2 items-center">
                          {logoElement}
                          <ProfileSwitch />
                          <LiveMode />
                        </div>
                      }
                      midUiActions={<TestMode />}
                      midUiActionsCustomClass={`top-0 relative flex justify-center ${leftCustomClass}`}
                    />
                  </div>
                  <div
                    className="w-full h-screen overflow-x-scroll xl:overflow-x-hidden overflow-y-scroll">
                    <WorkflowSideDrawer />
                    <div
                      className={isDecisionEngineWorkspace
                        ? "flex flex-col min-h-full"
                        : "p-6 md:px-12 md:py-8 flex flex-col gap-8 max-w-fixedPageWidth min-h-full"}>
                      <RenderIf condition={showMaintenanceAlert}>
                        <div className="w-full">
                          <AlertV2Binding
                            alertType=Primary
                            slot={{
                              slot: <Icon
                                name="nd-toast-info" size=20 className="text-nd_primary_blue-450"
                              />,
                            }}
                            description=maintenanceAlert
                          />
                        </div>
                      </RenderIf>
                      <ErrorBoundary>
                        {switch (activeProduct, url.path->urlPath) {
                        // /* DEFAULT HOME */
                        | (_, list{"v2", "home"}) => <DefaultHome />

                        | (_, list{"organization-chart"}) => <OrganisationChart />
                        | (_, list{"theme", ...remainingPath}) => <ThemeLanding remainingPath />
                        | (_, list{"users", ..._})
                          if featureFlagDetails.devModularityV2 && featureFlagDetails.devUsers =>
                          <AccessControl
                            isEnabled={version == V1}
                            authorization={userHasAccess(~groupAccess=UsersView)}>
                            <UserManagementContainer />
                          </AccessControl>
                        | (_, list{"account-settings", "profile", ...remainingPath}) =>
                          <EntityScaffold
                            entityName="profile setting"
                            remainingPath
                            renderList={() => <HSwitchProfileSettings />}
                            renderShow={(_, _) => <ModifyTwoFaSettings />}
                          />
                        | (_, list{"unauthorized"}) =>
                          <UnauthorizedPage message="You don't have access to this module." />

                        | (OnBoarding(_), _) => <DefaultOnboardingPage />
                        /* RECON V1 PRODUCT */

                        | (Recon(V1), _) => <ReconEngineApp />

                        /* RECON V2 PRODUCT */

                        | (Recon(V2), _) => <ReconApp />

                        /* RECOVERY PRODUCT */
                        | (Recovery, _) => <RevenueRecoveryApp />
                        /* VAULT PRODUCT */
                        | (Vault, _) => <VaultApp />
                        /* HYPERSENSE PRODUCT */
                        | (CostObservability, _) => <HypersenseApp />
                        | (DynamicRouting, _) => <IntelligentRoutingApp />
                        | (Orchestration(V2), _) => <OrchestrationV2App />
                        | (Orchestration(V1), _) => <OrchestrationApp setScreenState />
                        | (UnknownProduct, _) => React.null
                        }}
                      </ErrorBoundary>
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
                <RenderIf condition={!featureFlagDetails.isLiveMode}>
                  <ProdIntentForm />
                </RenderIf>
              </PageLoaderWrapper>
            </div>
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

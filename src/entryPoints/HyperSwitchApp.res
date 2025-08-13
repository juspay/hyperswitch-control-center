@react.component
let make = () => {
  open HSwitchUtils
  open GlobalVars
  open APIUtils
  open Typography
  open HyperswitchAtom
  open HyperswitchAppHelper

  let url = RescriptReactRouter.useUrl()
  let {
    showFeedbackModal,
    setShowFeedbackModal,
    dashboardPageState,
    setDashboardPageState,
  } = React.useContext(GlobalProvider.defaultContext)

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {activeProduct, setActiveProductValue} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)
  let {getThemesJson} = React.useContext(ThemeProvider.themeContext)
  let {fetchMerchantSpecificConfig} = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {fetchUserGroupACL, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let {userInfo: {orgId, merchantId, profileId, roleId, version}} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let {logoURL} = React.useContext(ThemeProvider.themeContext)
  let isReconEnabled = React.useMemo(() => {
    merchantDetailsTypedValue.recon_status === Active
  }, [merchantDetailsTypedValue.merchant_id])
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let maintenanceAlert = featureFlagDetails.maintenanceAlert
  let hyperSwitchAppSidebars = SidebarValues.useGetSidebarValuesForCurrentActive(~isReconEnabled)
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
  // set the product url based on the product type
  let setupProductUrl = (~productType: ProductTypes.productTypes) => {
    let currentUrl = GlobalVars.extractModulePath(
      ~path=url.path,
      ~query=url.search,
      ~end=url.path->List.toArray->Array.length,
    )
    let productUrl = ProductUtils.getProductUrl(~productType, ~url=currentUrl, ~isLiveMode)
    RescriptReactRouter.replace(productUrl)
    switch url.path->urlPath {
    | list{"unauthorized"} => RescriptReactRouter.push(appendDashboardPath(~url="/unauthorized"))
    | _ => ()
    }
  }

  let setUpDashboard = async () => {
    try {
      // NOTE: Treat groupACL map similar to screenstate
      setScreenState(_ => PageLoaderWrapper.Loading)
      setuserGroupACL(_ => None)
      Window.connectorWasmInit()->ignore
      let merchantResponse = await fetchMerchantAccountDetails(~version)
      let _ = await fetchMerchantSpecificConfig()
      let _ = await fetchUserGroupACL()
      setActiveProductValue(merchantResponse.product_type)
      setShowSideBar(_ => true)
      setupProductUrl(~productType=merchantResponse.product_type)
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
  | Orchestration(V1) => true
  | _ => false
  }

  let onAskPulseClick = () => {
    mixpanelEvent(~eventName="ask_pulse_clicked")
    RescriptReactRouter.push(appendDashboardPath(~url="/chat-bot"))
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
                  path={url.path}
                  sidebars={hyperSwitchAppSidebars}
                  key={(screenState :> string)}
                  productSiebars=productSidebars
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
                          <RenderIf condition={showGlobalSearchBar}>
                            <GlobalSearchBar />
                          </RenderIf>
                          <RenderIf condition={isInternalUser}>
                            <SwitchMerchantForInternal />
                          </RenderIf>
                          <RenderIf
                            condition={featureFlagDetails.devAiChatBot &&
                            userHasAccess(~groupAccess=MerchantDetailsView) == Access &&
                            merchantDetailsTypedValue.product_type == Orchestration(V1)}>
                            <div
                              onClick={_ => onAskPulseClick()}
                              className="flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer  transition-all duration-200 shadow-sm relative hover:scale-105"
                              style={ReactDOM.Style.make(
                                ~background="linear-gradient(90deg, transparent 0%, #3b82f6 25%, transparent 50%, #3b82f6 75%, transparent 100%)",
                                ~backgroundSize="200% 100%",
                                ~animation="sparkleBorder 5s linear infinite",
                                ~borderRadius="15px",
                                ~padding="1px",
                                (),
                              )}>
                              <div
                                className="flex items-center gap-2 px-3 py-2 bg-nd_gray-100 dark:bg-gray-900 rounded-xl">
                                <Icon name="stars" size=20 customIconColor="text-blue-500" />
                                <span className={`${body.md.semibold} text-blue-500`}>
                                  {"Ask Pulse"->React.string}
                                </span>
                              </div>
                              <style>
                                {React.string(
                                  "@keyframes sparkleBorder { 0% { background-position: 0% 0%; } 100% { background-position: 200% 0%; } }",
                                )}
                              </style>
                            </div>
                          </RenderIf>
                        </div>
                      </div>}
                      headerLeftActions={switch logoURL {
                      | Some(url) if url->LogicUtils.isNonEmptyString =>
                        <div className="flex md:gap-4 gap-2 items-center">
                          <img className="h-8 w-auto object-contain" alt="image" src={url} />
                          <ProfileSwitch />
                          <LiveMode />
                        </div>
                      | _ =>
                        <div className="flex md:gap-4 gap-2 items-center">
                          <ProfileSwitch />
                          <LiveMode />
                        </div>
                      }}
                      midUiActions={<TestMode />}
                      midUiActionsCustomClass={`top-0 relative flex justify-center ${leftCustomClass}`}
                    />
                  </div>
                  <div
                    className="w-full h-screen overflow-x-scroll xl:overflow-x-hidden overflow-y-scroll">
                    <RenderIf condition={maintenanceAlert->LogicUtils.isNonEmptyString}>
                      <HSwitchUtils.AlertBanner
                        bannerContent={<p> {maintenanceAlert->React.string} </p>} bannerType={Info}
                      />
                    </RenderIf>
                    <WorkflowSideDrawer />
                    <div
                      className="p-6 md:px-12 md:py-8 flex flex-col gap-10 max-w-fixedPageWidth min-h-full">
                      <ErrorBoundary>
                        {switch (merchantDetailsTypedValue.product_type, url.path->urlPath) {
                        /* DEFAULT HOME */
                        | (_, list{"v2", "home"}) => <DefaultHome />

                        | (_, list{"organization-chart"}) => <OrganisationChart />

                        | (_, list{"v2", "onboarding", ..._})
                        | (_, list{"v1", "onboarding", ..._}) =>
                          <DefaultOnboardingPage />

                        | (_, list{"account-settings", "profile", ...remainingPath}) =>
                          <EntityScaffold
                            entityName="profile setting"
                            remainingPath
                            renderList={() => <HSwitchProfileSettings />}
                            renderShow={(_, _) => <ModifyTwoFaSettings />}
                          />

                        | (_, list{"unauthorized"}) =>
                          <UnauthorizedPage message="You don't have access to this module." />

                        /* RECON V1 PRODUCT */

                        | (Recon(V1), list{"v1", "recon-engine", ..._}) => <ReconEngineApp />

                        /* RECON V2 PRODUCT */

                        | (Recon(V2), list{"v2", "recon", ..._}) => <ReconApp />

                        /* RECOVERY PRODUCT */
                        | (Recovery, list{"v2", "recovery", ..._}) => <RevenueRecoveryApp />

                        /* VAULT PRODUCT */
                        | (Vault, list{"v2", "vault", ..._}) => <VaultApp />

                        /* HYPERSENSE PRODUCT */
                        | (CostObservability, list{"v2", "cost-observability", ..._}) =>
                          <HypersenseApp />

                        /* INTELLIGENT ROUTING PRODUCT */
                        | (DynamicRouting, list{"v2", "dynamic-routing", ..._}) =>
                          <IntelligentRoutingApp />

                        /* ORCHESTRATOR V2 PRODUCT */
                        | (Orchestration(V2), list{"v2", "orchestration", ..._}) =>
                          <OrchestrationV2App />

                        /* ORCHESTRATOR PRODUCT */
                        | (Orchestration(V1), _) => <OrchestrationApp setScreenState />

                        | _ =>
                          <UnauthorizedPage
                            productType=merchantDetailsTypedValue.product_type
                            message="You don't have access to this module."
                          />
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

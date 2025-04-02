module NavbarHeaderLeftComponent = {
  @react.component
  let make = () => {
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let modebg = featureFlagDetails.isLiveMode ? "bg-hyperswitch_green" : "bg-orange-500 "
    let modeText = featureFlagDetails.isLiveMode ? "Live Mode" : "Test Mode"

    <div className="flex md:gap-4 gap-2 items-center">
      {switch Window.env.urlThemeConfig.logoUrl {
      | Some(url) => <img className="h-8 w-auto object-contain" alt="image" src={`${url}`} />
      | None => React.null
      }}
      <ProfileSwitch />
      <div
        className={`flex flex-row items-center px-2 py-3 gap-2 whitespace-nowrap cursor-default justify-between h-8 bg-white border rounded-lg  text-sm text-nd_gray-500 border-nd_gray-300`}>
        <span className="relative flex h-2 w-2">
          <span
            className={`animate-ping absolute inline-flex h-full w-full rounded-full ${modebg} opacity-75`}
          />
          <span className={`relative inline-flex rounded-full h-2 w-2  ${modebg}`} />
        </span>
        <span className="font-semibold"> {modeText->React.string} </span>
      </div>
    </div>
  }
}

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
  let {activeProduct, setActiveProductValue} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)
  let {getThemesJson} = React.useContext(ThemeProvider.themeContext)
  let {devThemeFeature} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {fetchMerchantSpecificConfig} = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {fetchUserGroupACL} = GroupACLHooks.useUserGroupACLHook()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let {userInfo: {orgId, merchantId, profileId, roleId, themeId, version}} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let isReconEnabled = React.useMemo(() => {
    merchantDetailsTypedValue.recon_status === Active
  }, [merchantDetailsTypedValue.merchant_id])
  let maintainenceAlert = featureFlagDetails.maintainenceAlert
  let hyperSwitchAppSidebars = SidebarValues.useGetSidebarValuesForCurrentActive(~isReconEnabled)
  let productSidebars = ProductsSidebarValues.useGetProductSideBarValues(~activeProduct)
  sessionExpired := false

  let applyTheme = async () => {
    try {
      if devThemeFeature || themeId->LogicUtils.isNonEmptyString {
        let _ = await getThemesJson(themeId, JSON.Encode.null, devThemeFeature)
      }
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
    let productUrl = ProductUtils.getProductUrl(~productType, ~url=currentUrl)
    RescriptReactRouter.replace(productUrl)
    switch url.path->urlPath {
    | list{"unauthorized"} => RescriptReactRouter.push(appendDashboardPath(~url="/home"))
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
  let path = url.path->List.toArray->Array.joinWith("/")

  React.useEffect(() => {
    setUpDashboard()->ignore
    None
  }, [orgId, merchantId, profileId, themeId])

  React.useEffect(() => {
    applyTheme()->ignore
    None
  }, (themeId, devThemeFeature))

  React.useEffect(() => {
    if featureFlagDetails.mixpanel {
      pageViewEvent(~path)->ignore
    }
    None
  }, (featureFlagDetails.mixpanel, path))

  React.useEffect(() => {
    if userGroupACL->Option.isSome {
      setDashboardPageState(_ => #HOME)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, userGroupACL)

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
                productSiebars=productSidebars
              />
            </RenderIf>
            <PageLoaderWrapper
              screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
              <div
                className="flex relative flex-col flex-1  bg-hyperswitch_background dark:bg-black overflow-scroll md:overflow-x-hidden">
                <div className="w-full max-w-fixedPageWidth md:px-12 px-5 pt-3">
                  <Navbar
                    headerActions={<div className="relative flex space-around gap-4 my-2 ">
                      <div className="flex gap-4 items-center">
                        <GlobalSearchBar />
                        <RenderIf condition={isInternalUser}>
                          <SwitchMerchantForInternal />
                        </RenderIf>
                      </div>
                    </div>}
                    headerLeftActions={<NavbarHeaderLeftComponent />}
                  />
                </div>
                <div
                  className="w-full h-screen overflow-x-scroll xl:overflow-x-hidden overflow-y-scroll">
                  <RenderIf condition={maintainenceAlert->LogicUtils.isNonEmptyString}>
                    <HSwitchUtils.AlertBanner bannerText={maintainenceAlert} bannerType={Info} />
                  </RenderIf>
                  <div
                    className="p-6 md:px-12 md:py-8 flex flex-col gap-10 max-w-fixedPageWidth min-h-full">
                    <ErrorBoundary>
                      {switch url.path->urlPath {
                      /* DEFAULT HOME */
                      | list{"v2", "home"} => <DefaultHome />

                      /* RECON PRODUCT */
                      | list{"v2", "recon", ..._} => <ReconApp />

                      /* RECOVERY PRODUCT */
                      | list{"v2", "recovery", ..._} => <RevenueRecoveryApp />

                      /* VAULT PRODUCT */
                      | list{"v2", "vault", ..._} => <VaultApp />

                      /* HYPERSENSE PRODUCT */
                      | list{"v2", "cost-observability", ..._} => <HypersenseApp />

                      /* INTELLIGENT ROUTING PRODUCT */
                      | list{"v2", "dynamic-routing", ..._} => <IntelligentRoutingApp />

                      | list{"unauthorized"} => <UnauthorizedPage />

                      /* ORCHESTRATOR PRODUCT */
                      | _ => <OrchestratorApp setScreenState />
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
}

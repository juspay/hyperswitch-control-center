@react.component
let make = () => {
  open HSwitchUtils
  open GlobalVars
  open APIUtils
  open PermissionUtils
  open LogicUtils
  open HyperswitchAtom
  let getURL = useGetURL()
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
  let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let setuserPermissionJson = Recoil.useSetRecoilState(userPermissionAtom)
  let getEnumDetails = EnumVariantHook.useFetchEnumDetails()
  let {userInfo: {orgId, merchantId, profileId}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
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
      let _ = await fetchSwitchMerchantList()
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

  React.useEffect(() => {
    setUpDashboard()->ignore
    None
  }, [orgId, merchantId, profileId])

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
                          <RenderIf condition={checkUserEntity([#Internal])}>
                            <SwitchMerchantForInternal />
                          </RenderIf>
                          <RenderIf condition={!checkUserEntity([#Internal])}>
                            <ProfileSwitch />
                          </RenderIf>
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
                      <RootRouter />
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

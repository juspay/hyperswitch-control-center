let h3Leading2Style = HSwitchUtils.getTextClass((H3, Leading_2))

@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
  let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)
  let (key, setKey) = React.useState(_ => "")
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (initialValuesForCheckoutForm, setInitialValuesForCheckoutForm) = React.useState(_ =>
    businessProfileRecoilVal->SDKPaymentUtils.initialValueForForm
  )
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  React.useEffect(() => {
    let paymentIntentOptional = filtersFromUrl->Dict.get("payment_intent_client_secret")
    if paymentIntentOptional->Option.isSome {
      setIsSDKOpen(_ => true)
    }
    None
  }, [filtersFromUrl])

  React.useEffect(() => {
    setInitialValuesForCheckoutForm(_ =>
      businessProfileRecoilVal->SDKPaymentUtils.initialValueForForm
    )
    None
  }, [businessProfileRecoilVal.profile_id])

  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if userHasAccess(~groupAccess=ConnectorsView) === Access {
        if !featureFlagDetails.isLiveMode {
          let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
          let _ = await fetchConnectorListResponse()
        }
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectoreContainer()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = [
    {
      title: "Checkout Details",
      renderContent: () =>
        <CheckoutDetails initialValuesForCheckoutForm setInitialValuesForCheckoutForm />,
    },
    {
      title: "Theme Customization",
      renderContent: () => <ThemeCustomization />,
    },
  ]

  <PageLoaderWrapper screenState={screenState}>
    <PageUtils.PageHeading title="Setup Checkout" customHeadingStyle="my-5" />
    <div className="flex">
      <Tabs
        initialIndex={tabIndex}
        tabs
        onTitleClick={tabId => setTabIndex(_ => tabId)}
        disableIndicationArrow=true
        showBorder=true
        includeMargin=false
        lightThemeColor="black"
        textStyle="text-blue-600"
        selectTabBottomBorderColor="bg-blue-600"
      />
      <div className="mt-5 ml-10">
        <PageUtils.PageHeading
          title="Preview"
          customTitleStyle="!font-medium !text-xl !text-nd_gray-600"
          customHeadingStyle="mb-20"
        />
        <SDKPayment isLoading=true />
      </div>
    </div>
  </PageLoaderWrapper>
}

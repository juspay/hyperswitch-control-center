let h3Leading2Style = HSwitchUtils.getTextClass((H3, Leading_2))

@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
  let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)
  let (key, setKey) = React.useState(_ => "")
  let (clientSecret, setClientSecret) = React.useState(_ => "")
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (initialValues, setInitialValues) = React.useState(_ =>
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
    Js.log2("paymentIntentOptional", paymentIntentOptional)
    Js.log2("filtersFromUrl", filtersFromUrl)
    if paymentIntentOptional->Option.isSome {
      setIsSDKOpen(_ => true)
    }
    None
  }, filtersFromUrl)

  React.useEffect(() => {
    if clientSecret !== "" {
      setIsSDKOpen(_ => true)
    }
    None
  }, [clientSecret])

  React.useEffect(() => {
    setInitialValues(_ => businessProfileRecoilVal->SDKPaymentUtils.initialValueForForm)
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
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getClientSecret = async (~typedValues) => {
    try {
      open LogicUtils
      let url = `${Window.env.apiBaseUrl}/payments`
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Post)
      let clientSecret = response->getDictFromJsonObject->getOptionString("client_secret")
      Js.log3("clientSecret", response, clientSecret)
      // setPaymentId(_ => response->getDictFromJsonObject->getOptionString("payment_id"))
      setClientSecret(_ => clientSecret->Option.getOr(""))
    } catch {
    | _ => ()
    }
  }

  let onSubmit = (values, _) => {
    let dict = values->LogicUtils.getDictFromJsonObject
    let typedValues = values->SDKPaymentUtils.getTypedValueForPayment
    let a = getClientSecret(~typedValues)
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))
    Nullable.null->Promise.resolve
  }

  let tabs: array<Tabs.tab> = [
    {
      title: "Checkout Details",
      renderContent: () => <CheckoutDetails initialValues />,
    },
    {
      title: "Theme Customization",
      renderContent: () => <ThemeCustomization />,
    },
  ]

  <PageLoaderWrapper screenState={screenState}>
    <PageUtils.PageHeading title="Setup Checkout" customHeadingStyle="my-5" />
    <div className="flex">
      <Form formClass="mt-5" initialValues={initialValues->Identity.genericTypeToJson} onSubmit>
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
      </Form>
      <div className="flex justify-center w-full max-w-md mx-auto p-4">
        <div>
          <PageUtils.PageHeading
            title="Preview"
            customTitleStyle="!font-medium !text-xl !text-nd_gray-600"
            customHeadingStyle="mb-20"
          />
          <SDKPayment isLoading={!isSDKOpen} clientSecretKey={clientSecret} initialValues />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}

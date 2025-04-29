// Default theme configuration
let defaultJson = {
  "theme": "default",
  "locale": "en-gb",
  "layout": "tabs",
  "labels": "above",
  "primary_color": "#000000",
}->Identity.genericTypeToJson

@react.component
let make = () => {
  open HyperswitchAtom
  open ReactHyperJs
  let returnUrl = {`${GlobalVars.getHostUrlWithBasePath}/sdk`}
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)
  let (keyForReRenderingSDK, setKeyForReRenderingSDK) = React.useState(_ => "")
  let (clientSecret, setClientSecret) = React.useState(_ => None)
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let (paymentResponse, setPaymentResponse) = React.useState(_ => JSON.Encode.null)
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(businessProfileFromIdAtom)
  let (initialValuesForCheckoutForm, setInitialValuesForCheckoutForm) = React.useState(_ =>
    SDKPaymentUtils.initialValueForForm(businessProfileRecoilVal)
  )

  let (themeInitialValues, setThemeInitialValues) = React.useState(_ => defaultJson)

  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)

  React.useEffect(() => {
    if clientSecret->Option.getOr("") !== "" {
      setIsSDKOpen(_ => true)
    }
    None
  }, [clientSecret])

  React.useEffect(() => {
    setInitialValuesForCheckoutForm(_ =>
      businessProfileRecoilVal->SDKPaymentUtils.initialValueForForm
    )
    None
  }, [businessProfileRecoilVal.profile_id])

  React.useEffect(() => {
    let setUpConnectorContainer = async () => {
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
    setUpConnectorContainer()->ignore
    None
  }, [])

  let getClientSecret = async (~typedValues) => {
    try {
      let url = `${Window.env.apiBaseUrl}/payments`
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Post)
      setPaymentResponse(_ => response)
      let clientSecretValue =
        response
        ->LogicUtils.getDictFromJsonObject
        ->LogicUtils.getOptionString("client_secret")

      setClientSecret(_ => clientSecretValue)
    } catch {
    | _ => ()
    }
  }

  let onSubmit = (values, _) => {
    setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
    let typedValues = values->SDKPaymentUtils.getTypedValueForPayment
    let _ = getClientSecret(~typedValues)
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))
    Nullable.null->Promise.resolve
  }

  let tabs: array<Tabs.tab> = [
    {
      title: "Checkout Details",
      renderContent: () => <CheckoutDetails initialValuesForCheckoutForm onSubmit />,
    },
    {
      title: "Theme Customization",
      renderContent: () =>
        <ThemeCustomization themeInitialValues setThemeInitialValues setKeyForReRenderingSDK />,
    },
  ]

  <PageLoaderWrapper screenState={screenState}>
    <PageUtils.PageHeading title="Setup Checkout" customHeadingStyle="my-5" />
    <div className="flex">
      <div className="w-1/2 flex flex-col gap-6">
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
        <TestCredentials />
      </div>
      <div className="w-full mt-5 ml-10 max-h-[80vh] overflow-auto">
        <PageUtils.PageHeading
          title="Preview" customTitleStyle="!font-medium !text-xl !text-nd_gray-600"
        />
        <SDKPayment
          key={keyForReRenderingSDK}
          isSDKOpen
          clientSecret
          themeInitialValues
          paymentResponse
          paymentStatus
          setPaymentStatus
          setErrorMessage
          returnUrl
        />
        <RenderIf condition={errorMessage != ""}>
          <div className="text-red-500"> {errorMessage->React.string} </div>
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}

@react.component
let make = () => {
  open ReactHyperJs
  open SDKPaymentUtils

  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let {
    keyForReRenderingSDK,
    setKeyForReRenderingSDK,
    setPaymentStatus,
    setPaymentResult,
    showBillingAddress,
    isGuestMode,
    setInitialValuesForCheckoutForm,
    setCheckIsSDKOpen,
  } = React.useContext(SDKProvider.defaultContext)

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)

  React.useEffect(() => {
    setInitialValuesForCheckoutForm(_ => initialValueForForm(businessProfileRecoilVal))

    None
  }, [businessProfileRecoilVal.profile_id])

  let onSubmit = (values, _) => {
    setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
    setInitialValuesForCheckoutForm(_ =>
      getTypedPaymentData(values, ~showBillingAddress, ~isGuestMode)
    )
    let typedValues = getTypedPaymentData(
      values,
      ~onlyEssential=true,
      ~showBillingAddress,
      ~isGuestMode,
    )
    let _ = getClientSecret(~typedValues, ~setCheckIsSDKOpen, ~setPaymentResult, ~updateDetails)
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))

    // To re-render the SDK back again after the payment is completed
    setPaymentStatus(_ => INCOMPLETE)

    Nullable.null->Promise.resolve
  }

  let getURL = APIUtils.useGetURL()
  let getClientSecret = async (~typedValues) => {
    try {
      let url = getURL(~entityName=V1(SDK_PAYMENT), ~methodType=Post)
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Fetch.Post)
      response
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let tabs: array<Tabs.tab> = [
    {
      title: "Checkout Details",
      renderContent: () => <CheckoutDetails onSubmit />,
    },
    {
      title: "Theme Customization",
      renderContent: () => <ThemeCustomization />,
    },
  ]

  <>
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
        <SDKPayment key={keyForReRenderingSDK} />
      </div>
    </div>
  </>
}

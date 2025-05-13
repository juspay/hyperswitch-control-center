@react.component
let make = () => {
  open ReactHyperJs
  open SDKPaymentUtils

  let getClientSecret = ClientSecretHook.useClientSecret()

  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let {
    keyForReRenderingSDK,
    setKeyForReRenderingSDK,
    setPaymentStatus,
    showBillingAddress,
    isGuestMode,
    setInitialValuesForCheckoutForm,
  } = React.useContext(SDKProvider.defaultContext)

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

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

    // Use the hook directly
    let _ = getClientSecret(typedValues)

    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))

    // To re-render the SDK back again after the payment is completed
    setPaymentStatus(_ => INCOMPLETE)

    Nullable.null->Promise.resolve
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

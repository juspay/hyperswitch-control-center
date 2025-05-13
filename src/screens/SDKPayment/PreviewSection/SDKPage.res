@react.component
let make = () => {
  open SDKPaymentUtils
  let getURL = APIUtils.useGetURL()
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let (clientSecretStatus, setClientSecretStatus) = React.useState(_ =>
    SDKPaymentTypes.IntialPreview
  )

  let {keyForReRenderingSDK, setPaymentResult, setInitialValuesForCheckoutForm} = React.useContext(
    SDKProvider.defaultContext,
  )

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

  React.useEffect(() => {
    setInitialValuesForCheckoutForm(_ => initialValueForForm(businessProfileRecoilVal))

    None
  }, [businessProfileRecoilVal.profile_id])
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)

  let getClientSecret = async (~typedValues) => {
    try {
      setClientSecretStatus(_ => Loading)
      let url = getURL(~entityName=V1(SDK_PAYMENT), ~methodType=Post)
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Fetch.Post)
      setPaymentResult(_ => response)

      setClientSecretStatus(_ => Success)
    } catch {
    | _ => setClientSecretStatus(_ => Error)
    }
  }

  let tabs: array<Tabs.tab> = [
    {
      title: "Checkout Details",
      renderContent: () => <CheckoutDetails getClientSecret />,
    },
    {
      title: "Theme Customization",
      renderContent: () => <ThemeCustomization getClientSecret />,
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
        <SDKPayment key={keyForReRenderingSDK} clientSecretStatus />
      </div>
    </div>
  </>
}

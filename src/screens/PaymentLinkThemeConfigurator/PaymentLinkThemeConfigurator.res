@react.component
let make = () => {
  open PaymentLinkThemeConfiguratorTypes
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let (currentStep, setCurrentStep) = React.useState(() => Checkout)
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )
  let {setPaymentResult, setInitialValuesForCheckoutForm, setClientSecretStatus} = React.useContext(
    SDKProvider.defaultContext,
  )

  let subtitle = switch currentStep {
  | Checkout => "Step 1: Configure details for your payment link"
  | Configurator => "Step 2: Configure & Preview"
  }

  React.useEffect(() => {
    if businessProfileRecoilVal.profile_id !== "" {
      let initialValues = SDKPaymentUtils.initialValueForForm(
        ~customCustomerId="hyperswitch_payment_link",
        businessProfileRecoilVal,
      )
      setInitialValuesForCheckoutForm(_ => initialValues)
    }
    None
  }, [businessProfileRecoilVal.profile_id])

  let getClientSecret = async (~typedValues: SDKPaymentTypes.paymentType) => {
    try {
      setClientSecretStatus(_ => Loading)
      let url = getURL(~entityName=V1(SDK_PAYMENT), ~methodType=Post)
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Fetch.Post)
      setPaymentResult(_ => response)
      setClientSecretStatus(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        setClientSecretStatus(_ => Error)
        Exn.raiseError(err)
      }
    }
  }

  let onShowPreview = () => {
    setCurrentStep(_ => Configurator)
  }

  let onRestartClick = () => {
    setCurrentStep(_ => Checkout)
  }

  <div className="flex flex-col gap-8">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Payment Link Theme Configuration" subTitle={subtitle} />
      <RenderIf condition={currentStep == Configurator}>
        <Button text="Restart Flow" onClick={_ => onRestartClick()} />
      </RenderIf>
    </div>
    {switch currentStep {
    | Checkout =>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <CheckoutDetails getClientSecret onShowPreview customNavigationPath="/payment-link-theme" />
      </div>
    | Configurator => <PaymentLinkThemeConfiguratorTool />
    }}
  </div>
}

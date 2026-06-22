@react.component
let make = () => {
  open PaymentLinkThemeConfiguratorTypes
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let (currentStep, setCurrentStep) = React.useState(() => Checkout)
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {setPaymentResult, setInitialValuesForCheckoutForm} = React.useContext(
    SDKProvider.defaultContext,
  )
  let paymentConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )

  let subtitle = switch currentStep {
  | Checkout => "Edit details for your payment link"
  | Configurator => "Configure and Preview payment link theme"
  }

  React.useEffect(() => {
    if businessProfileRecoilVal.profile_id->LogicUtils.isNonEmptyString {
      let initialValues = SDKPaymentUtils.initialValueForForm(
        ~customCustomerId="hyperswitch_payment_link",
        ~profileId=businessProfileRecoilVal.profile_id,
      )
      setInitialValuesForCheckoutForm(_ => initialValues)
    }
    None
  }, [businessProfileRecoilVal.profile_id])

  let getClientSecret = async (~typedValues: SDKPaymentTypes.paymentType) => {
    try {
      let url = getURL(~entityName=V1(SDK_PAYMENT), ~methodType=Post)
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Fetch.Post)
      setPaymentResult(_ => response)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    }
  }

  <div className="flex flex-col gap-8">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Payment Link Theme Configuration" subTitle={subtitle} />
      <RenderIf condition={currentStep == Configurator}>
        <Button text="Edit checkout details" onClick={_ => setCurrentStep(_ => Checkout)} />
      </RenderIf>
    </div>
    {switch currentStep {
    | Checkout =>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div>
          <RenderIf condition={paymentConnectorList->Array.length == 0}>
            <div className="mb-4">
              <AlertV2Binding
                alertType=Warning
                description="Please configure at least one Payment Connector to proceed."
              />
            </div>
          </RenderIf>
          <RenderIf condition={paymentConnectorList->Array.length > 0}>
            <div className="mb-4">
              <AlertV2Binding
                alertType=Primary
                description="Please note that on clicking Configure Payment Link button, a payment intent will be created with the below Customer ID. This will reflect in Payments list page."
              />
            </div>
          </RenderIf>
          <CheckoutDetails
            getClientSecret
            onSubmitClick={_ => setCurrentStep(_ => Configurator)}
            navigationPath="/payment-link-theme"
            submitButtonText="Configure Payment Link"
          />
        </div>
      </div>
    | Configurator => <PaymentLinkThemeConfiguratorTool />
    }}
  </div>
}

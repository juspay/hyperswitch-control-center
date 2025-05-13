@react.component
let make = () => {
  open FormRenderer
  open SDKPaymentUtils
  open SDKPaymentHelper

  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)

  let {
    sdkThemeInitialValues,
    setSdkThemeInitialValues,
    setKeyForReRenderingSDK,
    paymentResult,
    setPaymentResult,
    setCheckIsSDKOpen,
    initialValuesForCheckoutForm,
    showBillingAddress,
    isGuestMode,
  } = React.useContext(SDKProvider.defaultContext)
  let clientSecret =
    paymentResult->LogicUtils.getDictFromJsonObject->LogicUtils.getOptionString("client_secret")

  let onSubmit = (values, _) => {
    if clientSecret->Option.isNone {
      let typedValues = getTypedPaymentData(
        {initialValuesForCheckoutForm->Identity.genericTypeToJson},
        ~onlyEssential=true,
        ~showBillingAddress,
        ~isGuestMode,
      )
      let _ = getClientSecret(~typedValues, ~setCheckIsSDKOpen, ~setPaymentResult, ~updateDetails)
    }
    setSdkThemeInitialValues(_ => values)
    setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
    Nullable.null->Promise.resolve
  }

  let paymentConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )

  <Form formClass="mt-5" initialValues=sdkThemeInitialValues onSubmit>
    <FieldRenderer field=selectThemeField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLocaleField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLayoutField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLabelsField fieldWrapperClass="!w-full" />
    <FieldRenderer field={enterPrimaryColorValue("#006DF9")} fieldWrapperClass="!w-full" />
    <div className="flex items-center mt-4 text-nd_primary_blue-500 text-sm font-medium">
      <Icon name="blue-info" className="mt-1" />
      <a
        className="cursor-pointer"
        target="_blank"
        href={"https://docs.hyperswitch.io/explore-hyperswitch/merchant-controls/integration-guide/web/customization"}>
        {"Learn More About Customization"->React.string}
      </a>
    </div>
    <SubmitButton
      text="Show preview"
      disabledParamter={paymentConnectorList->Array.length === 0}
      customSumbitButtonStyle="!mt-5"
    />
  </Form>
}

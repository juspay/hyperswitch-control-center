@react.component
let make = (~getClientSecret) => {
  open FormRenderer
  open SDKPaymentUtils
  open SDKPaymentHelper

  let {
    sdkThemeInitialValues,
    setSdkThemeInitialValues,
    setKeyForReRenderingSDK,
    initialValuesForCheckoutForm,
    showBillingAddress,
    isGuestMode,
  } = React.useContext(SDKProvider.defaultContext)
  let showToast = ToastState.useShowToast()
  let {globalUIConfig: {font: {textColor: {primaryNormal}}}} = React.useContext(
    ThemeProvider.themeContext,
  )

  let onSubmit = async (values, _) => {
    try {
      let typedValues = getTypedPaymentData(
        {initialValuesForCheckoutForm->Identity.genericTypeToJson},
        ~onlyEssential=true,
        ~showBillingAddress,
        ~isGuestMode,
      )
      let _ = await getClientSecret(~typedValues)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
    }
    setSdkThemeInitialValues(_ => values)
    setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
    Nullable.null
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
    <div className={`flex items-center mt-4 ${primaryNormal} text-sm font-medium`}>
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
      customSumbitButtonStyle="!mt-5 !w-full"
    />
  </Form>
}

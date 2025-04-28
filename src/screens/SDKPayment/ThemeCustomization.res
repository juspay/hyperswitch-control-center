@react.component
let make = (~themeInitialValues, ~setThemeInitialValues, ~setKeyForReRenderingSDK) => {
  open FormRenderer
  open SDKPaymentUtils

  let onSubmit = (values, _) => {
    setThemeInitialValues(_ => values)
    setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
    Nullable.null->Promise.resolve
  }

  let paymentConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )

  <Form formClass="mt-5" initialValues=themeInitialValues onSubmit>
    <FieldRenderer field=selectThemeField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLocaleField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLayoutField fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectLabelsField fieldWrapperClass="!w-full" />
    <FieldRenderer field={enterPrimaryColorValue("#38c95f")} fieldWrapperClass="!w-full" />
    <div className="flex items-center mt-4 text-nd_primary_blue-500 text-sm font-medium">
      <Icon name="blue-info" className="mt-1" />
      <span className="cursor-pointer" onClick={_ => Console.log("New Page Link")}>
        {"Learn More About Customization"->React.string}
      </span>
    </div>
    <SubmitButton
      text="Show preview"
      disabledParamter={paymentConnectorList->Array.length === 0}
      customSumbitButtonStyle="!mt-5"
    />
    <FormValuesSpy />
  </Form>
}

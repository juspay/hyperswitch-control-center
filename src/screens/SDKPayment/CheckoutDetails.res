@react.component
let make = (~initialValuesForCheckoutForm, ~setInitialValuesForCheckoutForm) => {
  open FormRenderer
  open SDKPaymentUtils
  open APIUtils

  let updateDetails = useUpdateMethod(~showErrorToast=false)

  let (showModal, setShowModal) = React.useState(_ => false)

  let getClientSecret = async (~typedValues) => {
    try {
      open LogicUtils
      let url = `${Window.env.apiBaseUrl}/payments`
      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Post)
      let clientSecret = response->getDictFromJsonObject->getOptionString("client_secret")
      Js.log3("clientSecret", response, clientSecret)
      // setPaymentId(_ => response->getDictFromJsonObject->getOptionString("payment_id"))
      // setClientSecret(_ => clientSecret)
    } catch {
    | _ => ()
    }
  }

  let onSubmit = (values, _) => {
    Js.log2("values", values)
    let typedValues = values->getTypedValueForPayment
    let a = getClientSecret(~typedValues)
    Js.log2("Champ typedValues", typedValues)
    Js.log2("Champ values", values)
    // RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))
    Nullable.null->Promise.resolve
  }

  let paymentConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )

  <Form
    formClass="mt-5"
    initialValues={initialValuesForCheckoutForm->Identity.genericTypeToJson}
    onSubmit>
    <FieldRenderer field=selectEnterIntegrationType fieldWrapperClass="!w-full" />
    <FieldRenderer field=enterCustomerId fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectCurrencyField fieldWrapperClass="!w-full" />
    <FieldRenderer
      field={enterAmountField(initialValuesForCheckoutForm)} fieldWrapperClass="!w-full"
    />
    <div className="mt-4">
      <span
        className="text-nd_primary_blue-500 text-sm font-medium cursor-pointer"
        onClick={_ => setShowModal(_ => true)}>
        {"Edit Checkout Details"->React.string}
      </span>
    </div>
    <RenderIf condition={showModal}>
      <EditCheckoutDetails showModal setShowModal />
    </RenderIf>
    <SubmitButton
      text="Show preview"
      disabledParamter={initialValuesForCheckoutForm.profile_id->LogicUtils.isEmptyString ||
        paymentConnectorList->Array.length === 0}
      customSumbitButtonStyle="!mt-5"
    />
    <FormValuesSpy />
  </Form>
}

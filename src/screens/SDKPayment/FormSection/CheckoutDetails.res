@react.component
let make = (~getClientSecret) => {
  open FormRenderer
  open SDKPaymentHelper
  open SDKPaymentUtils
  let {
    isGuestMode,
    setIsGuestMode,
    initialValuesForCheckoutForm,
    setKeyForReRenderingSDK,
    setInitialValuesForCheckoutForm,
    showBillingAddress,
    setPaymentStatus,
  } = React.useContext(SDKProvider.defaultContext)
  let (showModal, setShowModal) = React.useState(() => false)
  let showToast = ToastState.useShowToast()
  let paymentConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )
  let onSubmit = async (values, _) => {
    try {
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
      let _ = await getClientSecret(~typedValues)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))
      // To re-render the SDK back again after the payment is completed
      setPaymentStatus(_ => INCOMPLETE)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
    }
    Nullable.null
  }

  <Form
    formClass="mt-5"
    initialValues={initialValuesForCheckoutForm->Identity.genericTypeToJson}
    onSubmit>
    <FieldRenderer
      field={enterCustomerId(~isGuestMode, ~setIsGuestMode)} fieldWrapperClass="!w-full"
    />
    <RenderIf condition={!isGuestMode}>
      <FieldRenderer field=selectShowSavedCardField fieldWrapperClass="!w-full" />
    </RenderIf>
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
    <RenderIf condition=showModal>
      <EditCheckoutDetails showModal setShowModal />
    </RenderIf>
    <SubmitButton
      text="Show preview"
      disabledParamter={initialValuesForCheckoutForm.profile_id->LogicUtils.isEmptyString ||
        paymentConnectorList->Array.length == 0}
      customSumbitButtonStyle="!mt-5"
    />
  </Form>
}

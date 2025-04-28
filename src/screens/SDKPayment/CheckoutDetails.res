@react.component
let make = (~initialValues) => {
  open FormRenderer
  open SDKPaymentUtils

  let (showModal, setShowModal) = React.useState(_ => false)

  let paymentConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )

  <>
    <FieldRenderer field=selectEnterIntegrationType fieldWrapperClass="!w-full" />
    <FieldRenderer field=enterCustomerId fieldWrapperClass="!w-full" />
    <FieldRenderer field=selectCurrencyField fieldWrapperClass="!w-full" />
    <FieldRenderer field={enterAmountField(initialValues)} fieldWrapperClass="!w-full" />
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
      disabledParamter={initialValues.profile_id->LogicUtils.isEmptyString ||
        paymentConnectorList->Array.length === 0}
      customSumbitButtonStyle="!mt-5"
    />
    <FormValuesSpy />
  </>
}

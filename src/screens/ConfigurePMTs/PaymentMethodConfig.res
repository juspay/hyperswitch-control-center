@react.component
let make = (
  ~paymentMethodConfig: PaymentMethodConfigTypes.paymentMethodConfiguration,
  ~config: string,
) => {
  // open LogicUtils

  let (showPaymentMthdConfigModal, setShowPaymentMthdConfigModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ =>
    Dict.make()->ConnectorListMapper.getProcessorPayloadType
  )

  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom

  let encodeAdvanceConfig = (advanceConfig: option<ConnectorTypes.advancedConfigurationList>) => {
    switch advanceConfig {
    | Some(config) =>
      [
        ("type", JSON.Encode.string(config.type_)),
        ("list", JSON.Encode.array(config.list->Array.map(Js.Json.string))),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object
    | None => None->Option.map(JSON.Encode.object)->Option.getOr(Js.Json.null)
    }
  }
  let encodePaymentMethodConfig = (paymentMethodConfig: ConnectorTypes.paymentMethodConfigType) => {
    [
      ("payment_method_type", JSON.Encode.string(paymentMethodConfig.payment_method_type)),
      (
        "card_networks",
        JSON.Encode.array(paymentMethodConfig.card_networks->Array.map(Js.Json.string)),
      ),
      ("accepted_currencies", paymentMethodConfig.accepted_currencies->encodeAdvanceConfig),
      ("accepted_countries", paymentMethodConfig.accepted_countries->encodeAdvanceConfig),
      (
        "maximum_amount",
        paymentMethodConfig.maximum_amount->Option.map(JSON.Encode.int)->Option.getOr(Js.Json.null),
      ),
      (
        "minimum_amount",
        paymentMethodConfig.minimum_amount->Option.map(JSON.Encode.int)->Option.getOr(Js.Json.null),
      ),
      (
        "recurring_enabled",
        paymentMethodConfig.recurring_enabled
        ->Option.map(JSON.Encode.bool)
        ->Option.getOr(Js.Json.null),
      ),
      (
        "installment_payment_enabled",
        paymentMethodConfig.installment_payment_enabled
        ->Option.map(JSON.Encode.bool)
        ->Option.getOr(Js.Json.null),
      ),
      (
        "payment_experience",
        paymentMethodConfig.payment_experience
        ->Option.map(JSON.Encode.string)
        ->Option.getOr(Js.Json.null),
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }
  let encodePaymentMethodEnabled = (
    paymentMethodRecord: ConnectorTypes.paymentMethodEnabledType,
  ): Js.Json.t => {
    let paymentMethodConfig =
      paymentMethodRecord.payment_method_types
      ->Array.map(encodePaymentMethodConfig)
      ->JSON.Encode.array
    [
      ("payment_method", JSON.Encode.string(paymentMethodRecord.payment_method)),
      ("payment_method_types", paymentMethodConfig),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

  let encodeMyRecord = (myTypedValue: ConnectorTypes.connectorPayload): Js.Json.t => {
    let paymentMethodEnabled =
      myTypedValue.payment_methods_enabled->Array.map(encodePaymentMethodEnabled)->JSON.Encode.array
    Js.log(paymentMethodEnabled)
    let dict =
      [
        ("connector_type", JSON.Encode.string(myTypedValue.connector_type)),
        ("payment_methods_enabled", paymentMethodEnabled),
      ]->Dict.fromArray
    dict->JSON.Encode.object
  }

  let getProcessorDetails = async () => {
    let data =
      connectorList
      ->Array.filter(item =>
        item.merchant_connector_id === paymentMethodConfig.merchant_connector_id
      )
      ->Array.get(0)
      ->Option.getOr(Dict.make()->ConnectorListMapper.getProcessorPayloadType)
    let _ = data->encodeMyRecord
    setInitialValues(_ => data)
    setShowPaymentMthdConfigModal(_ => true)
  }

  <div>
    <Modal
      showModal={showPaymentMthdConfigModal}
      showModalHeadingIconName={paymentMethodConfig.connector_name->String.toUpperCase}
      customIcon={Some(
        <GatewayIcon
          gateway={paymentMethodConfig.connector_name->String.toUpperCase} className="w-12 h-12"
        />,
      )}
      modalHeadingDescriptionElement={<div
        className="text-md font-medium leading-7 opacity-50 mt-1 w-full">
        {"Configure PMTs"->React.string}
      </div>}
      paddingClass=""
      modalHeading={paymentMethodConfig.payment_method->String.toUpperCase}
      setShowModal={setShowPaymentMthdConfigModal}
      //   showCloseIcon=false
      modalHeadingDescription="Start by creating your business name"
      modalClass="w-full max-w-lg m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
      <Form
        key="merchant_name-validation"
        initialValues={Dict.make()->JSON.Encode.object}
        // onSubmit
        // validate={values => values->validateForm}
      >
        <div className="flex flex-col gap-6 h-full w-full">
          <div> {"form"->React.string} </div>
          //   <FormRenderer.DesktopRow>
          //     <FormRenderer.FieldRenderer
          //       fieldWrapperClass="w-full"
          //       field={businessName}
          //       labelClass="!text-black font-medium !-ml-[0.5px]"
          //     />
          //   </FormRenderer.DesktopRow>
          //   <div className="flex justify-end w-full pr-5 pb-3">
          //     <FormRenderer.SubmitButton
          //       text="Start Exploring" buttonSize={Small} disabledParamter=isDisabled
          //     />
          //   </div>
        </div>
      </Form>
    </Modal>
    <div onClick={_ => getProcessorDetails()->ignore}> {config->React.string} </div>
  </div>
}

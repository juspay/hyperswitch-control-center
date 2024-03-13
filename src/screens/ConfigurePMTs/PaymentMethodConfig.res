let inputField = (
  ~name,
  ~label,
  ~placeholder,
  ~isRequired,
  ~disabled,
  ~description,
  ~toolTipPosition: ToolTip.toolTipPosition=ToolTip.Right,
  (),
) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~description,
    ~toolTipPosition,
    ~customInput=InputFields.textInput(~isDisabled=disabled, ()),
    ~placeholder,
    ~isRequired,
    (),
  )

module PmtConfigInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    let enabledList = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToArrayOfString
        if value->Array.length <= 0 {
          valueField.onChange(
            None
            ->Option.map(JSON.Encode.object)
            ->Option.getOr(Js.Json.null)
            ->Identity.anyTypeToReactEvent,
          )
        } else {
          enabledList.onChange(value->Identity.anyTypeToReactEvent)
        }
      },
      onFocus: _ev => (),
      value: enabledList.value,
      checked: true,
    }
    <SelectBox.BaseDropdown
      allowMultiSelect=true
      buttonText="Select Value"
      input
      options={["US", "GB", "IN"]->SelectBox.makeOptions}
      hideMultiSelectButtons=true
      showSelectionAsChips={false}
    />
  }
}

let renderValueInp = (_keyType, fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <PmtConfigInp fieldsArray />
}
let valueInput = id => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderValueInp(""),
    ~inputFields=[
      makeInputFieldInfo(~name=`${id}.accepted_countries.list`, ()),
      makeInputFieldInfo(~name=`${id}.accepted_countries`, ()),
    ],
    (),
  )
}

@react.component
let make = (
  ~paymentMethodConfig: PaymentMethodConfigTypes.paymentMethodConfiguration,
  ~config: string,
) => {
  open FormRenderer
  let (showPaymentMthdConfigModal, setShowPaymentMthdConfigModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom

  let getProcessorDetails = async () => {
    let data =
      connectorList
      ->Array.filter(item =>
        item.merchant_connector_id === paymentMethodConfig.merchant_connector_id
      )
      ->Array.get(0)
      ->Option.getOr(Dict.make()->ConnectorListMapper.getProcessorPayloadType)
    let encodeConnectorPayload = data->PaymentMethodConfigUtils.encodeConnectorPayload
    setInitialValues(_ => encodeConnectorPayload)
    Js.log2(paymentMethodConfig, "paymentMethodConfig")
    setShowPaymentMthdConfigModal(_ => true)
  }
  let id = `payment_methods_enabled[${paymentMethodConfig.payment_method_index->Int.toString}].payment_method_types[${paymentMethodConfig.payment_method_types_index->Int.toString}]`
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
      modalHeadingDescription="Start by creating your business name"
      modalClass="w-full max-w-lg m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
      <Form
        key="merchant_name-validation"
        initialValues
        // onSubmit
        // validate={values => values->validateForm}
      >
        <div className="flex flex-col gap-6 h-full w-full">
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={inputField(
              ~name=`payment_methods_enabled[${paymentMethodConfig.payment_method_index->Int.toString}].payment_method_types[${paymentMethodConfig.payment_method_types_index->Int.toString}].maximum_amount`,
              ~label="lable",
              ~isRequired=false,
              ~placeholder="placeholder",
              ~disabled=false,
              ~description="",
              (),
            )}
          />
          <FieldRenderer field={valueInput(id)} />
        </div>
        <FormValuesSpy />
      </Form>
    </Modal>
    <div onClick={_ => getProcessorDetails()->ignore}> {config->React.string} </div>
  </div>
}

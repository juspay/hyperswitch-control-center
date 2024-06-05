let default = {
  "google_pay": {
    "merchant_info": {
      "merchant_id": "",
      "merchant_name": "",
    },
    "allowed_payment_methods": [
      {
        "type": "CARD",
        "parameters": {
          "allowed_auth_methods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowed_card_networks": ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"],
        },
        "tokenization_specification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "stripe",
          },
        },
      },
    ],
  },
}

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
        valueField.onChange(default->Identity.anyTypeToReactEvent)
        enabledList.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ev => (),
      value: enabledList.value,
      checked: true,
    }
    <TextInput input placeholder="tetx" />
  }
}

let renderValueInp = (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <PmtConfigInp fieldsArray />
}

let valueInput = () => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label=`Label`,
    ~comboCustomInput=renderValueInp,
    ~inputFields=[
      makeInputFieldInfo(~name=`metadata.google_pay.merchant_info.merchant_id`, ()),
      makeInputFieldInfo(~name=`metadata`, ()),
    ],
    (),
  )
}

@react.component
let make = () => {
  Js.log(default["google_pay"])
  <>
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black" field={valueInput()}
    />
  </>
}

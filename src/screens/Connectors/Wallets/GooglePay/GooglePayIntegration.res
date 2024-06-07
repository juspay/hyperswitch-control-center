module PmtConfigInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    let enabledList = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: (ev: ReactEvent.Form.t) => {
        let value = {ev->ReactEvent.Form.target}["value"]
        enabledList.onChange(value->Identity.anyTypeToReactEvent)
        let dict = [("stripe_publishableKey", value)]->Dict.fromArray
        let updated = GooglePayUtils.googlePay(dict, "stripe")
        valueField.onChange(updated->Identity.anyTypeToReactEvent)
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
  open GooglePayUtils
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label=`Label`,
    ~comboCustomInput=renderValueInp,
    ~inputFields=[
      makeInputFieldInfo(~name=`${googlePayNameMapper("stripe_publishableKey")}`, ()),
      makeInputFieldInfo(~name=`metadata.google_pay`, ()),
    ],
    (),
  )
}

@react.component
let make = () => {
  <>
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black" field={valueInput()}
    />
  </>
}

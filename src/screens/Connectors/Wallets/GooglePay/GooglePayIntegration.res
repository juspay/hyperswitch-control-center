module PmtConfigInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    let enabledList = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      // onChange: ev => {
      //   let value = ev->Identity.formReactEventToArrayOfString
      //   Js.log2(value, "value")
      //   // valueField.onChange(default->Identity.anyTypeToReactEvent)
      // enabledList.onChange(value->Identity.anyTypeToReactEvent)
      // },
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        Js.log(value)
        enabledList.onChange(value->Identity.anyTypeToReactEvent)
        Js.log(enabledList.value)
        // let dict = [("stripe_version", enabledList.value)]->Dict.fromArray
        // let updated = GooglePayUtils.googlePay(dict, "stripe")
        // Js.log2(updated, "updated")
        // valueField.onChange(updated->Identity.anyTypeToReactEvent)
        // Js.log(value)
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

// let test = () => {
//   let apiName = FormRenderer.makeFieldInfo(
//     ~label="Name",
//     ~name="name",
//     ~placeholder="Name",
//     ~customInput=InputFields.textInput(),
//     ~isRequired=true,
//     (),
//   )
//   apiName
// }

@react.component
let make = () => {
  <>
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black" field={valueInput()}
    />
  </>
}

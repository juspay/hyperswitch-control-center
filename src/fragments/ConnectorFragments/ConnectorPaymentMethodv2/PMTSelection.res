module PMT = {
  @react.component
  let make = (
    ~pmtData: ConnectorTypes.paymentMethodConfigType,
    ~pm,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
  ) => {
    open LogicUtils

    let pmInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledInp = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtInp = (fieldsArray[3]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtArrayValue = pmtArrayInp.value->ConnectorUtils.getPaymentMethodMapper
    let pmEnabledValue =
      pmEnabledInp.value->getArrayDataFromJson(ConnectorListMapper.getPaymentMethodsEnabled)
    let isPMTEnabled = pmtInp.value->getDictFromJsonObject->Dict.keysToArray->Array.length > 0
    let (isSelected, setIsSelected) = React.useState(() => isPMTEnabled)
    React.useEffect(() => {
      if isPMTEnabled {
        setIsSelected(_ => true)
      } else {
        setIsSelected(_ => false)
      }
      Js.log(pmInp.value)
      None
    }, [isPMTEnabled])

    let removeMethods = () => {
      let updatedPmtArray = pmtArrayValue->Array.filter(ele =>
        if pmtData.payment_method_type == "credit" || pmtData.payment_method_type == "debit" {
          ele.payment_method_type != pmtData.payment_method_type ||
            ele.card_networks->Array.get(0)->Option.getOr("") !=
              pmtData.card_networks->Array.get(0)->Option.getOr("")
        } else {
          ele.payment_method_type != pmtData.payment_method_type
        }
      )
      if updatedPmtArray->Array.length == 0 {
        let updatedPmArray = pmEnabledValue->Array.filter(ele => ele.payment_method != pm)

        if updatedPmArray->Array.length == 0 {
          pmEnabledInp.onChange([]->Identity.anyTypeToReactEvent)
        } else {
          pmEnabledInp.onChange(updatedPmArray->Identity.anyTypeToReactEvent)
        }
      } else {
        pmtArrayInp.onChange(updatedPmtArray->Identity.anyTypeToReactEvent)
      }
    }

    let update = isSelected => {
      if !isSelected {
        removeMethods()
      } else {
        pmInp.onChange(pm->Identity.anyTypeToReactEvent)
        pmtInp.onChange(pmtData->Identity.anyTypeToReactEvent)
      }
      setIsSelected(_ => isSelected)
    }

    <CheckBoxIcon isSelected={isSelected} setIsSelected={isSelected => update(isSelected)} />
  }
}

let renderValueInp = (~pmtData, ~pm) => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <PMT pmtData pm fieldsArray />
}

let valueInput = (~pmtData, ~pmIndex, ~pmtIndex, ~pm) => {
  open FormRenderer

  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderValueInp(~pmtData, ~pm),
    ~inputFields=[
      makeInputFieldInfo(~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method`),
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method_types`,
      ),
      makeInputFieldInfo(~name=`payment_methods_enabled`),
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method_types[${pmtIndex}]`,
      ),
    ],
    (),
  )
}

module PMT = {
  @react.component
  let make = (
    ~pmtData: ConnectorTypes.paymentMethodConfigType,
    ~pm,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~connector,
  ) => {
    open LogicUtils
    open ConnectorPaymentMethodV3Utils
    let pmInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledInp = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtInp = (fieldsArray[3]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtArrayValue = pmtArrayInp.value->ConnectorUtils.getPaymentMethodMapper
    let pmEnabledValue =
      pmEnabledInp.value->getArrayDataFromJson(ConnectorListMapper.getPaymentMethodsEnabled)
    let pmtInpValue = pmtInp.value->getDictFromJsonObject->itemProviderMapper

    let removeMethods = () => {
      let updatedPmtArray = pmtArrayValue->Array.filter(ele =>
        if (
          pmtData.payment_method_type->getPaymentMethodTypeFromString == Credit ||
            pmtData.payment_method_type->getPaymentMethodTypeFromString == Debit
        ) {
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
      } else if !isMetaDataRequired(pmtData.payment_method_type, connector) {
        pmInp.onChange(pm->Identity.anyTypeToReactEvent)
        pmtInp.onChange(pmtData->Identity.anyTypeToReactEvent)
      }
    }

    <CheckBoxIcon
      isSelected={pmtInpValue.payment_method_type == pmtData.payment_method_type}
      setIsSelected={isSelected => update(isSelected)}
    />
  }
}

let renderValueInp = (~pmtData, ~pm, ~connector) => (
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <PMT pmtData pm fieldsArray connector />
}

let valueInput = (~pmtData, ~pmIndex, ~pmtIndex, ~pm, ~connector) => {
  open FormRenderer

  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderValueInp(~pmtData, ~pm, ~connector),
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

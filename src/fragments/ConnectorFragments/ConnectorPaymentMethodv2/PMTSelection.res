module PMT = {
  @react.component
  let make = (
    ~pmtData: ConnectorTypes.paymentMethodConfigTypeV2,
    ~pm,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~connector,
    ~formValues: ConnectorTypes.connectorPayloadV2,
  ) => {
    open ConnectorPaymentMethodV2Utils
    let pmInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledInp = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmtInp = (fieldsArray[3]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let pmEnabledValue = formValues.payment_methods_enabled

    let pmtArrayValue = (
      pmEnabledValue
      ->Array.find(ele => ele.payment_method_type == pm)
      ->Option.getOr({payment_method_type: "", payment_method_subtypes: []})
    ).payment_method_subtypes
    let pmtValue = pmtArrayValue->Array.find(val => {
      if (
        pmtData.payment_method_subtype->getPMTFromString == Credit ||
          pmtData.payment_method_subtype->getPMTFromString == Debit
      ) {
        val.payment_method_subtype == pmtData.payment_method_subtype &&
          val.card_networks->Array.get(0)->Option.getOr("") ==
            pmtData.card_networks->Array.get(0)->Option.getOr("")
      } else {
        val.payment_method_subtype == pmtData.payment_method_subtype
      }
    })

    let removeMethods = () => {
      let updatedPmtArray = pmtArrayValue->Array.filter(ele =>
        if (
          pmtData.payment_method_subtype->getPMTFromString == Credit ||
            pmtData.payment_method_subtype->getPMTFromString == Debit
        ) {
          ele.payment_method_subtype != pmtData.payment_method_subtype ||
            ele.card_networks->Array.get(0)->Option.getOr("") !=
              pmtData.card_networks->Array.get(0)->Option.getOr("")
        } else {
          ele.payment_method_subtype != pmtData.payment_method_subtype
        }
      )
      if updatedPmtArray->Array.length == 0 {
        let updatedPmArray = pmEnabledValue->Array.filter(ele => ele.payment_method_type != pm)

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
      } else if !isMetaDataRequired(pmtData.payment_method_subtype, connector) {
        pmInp.onChange(pm->Identity.anyTypeToReactEvent)
        pmtInp.onChange(pmtData->Identity.anyTypeToReactEvent)
      }
    }

    <CheckBoxIcon
      isSelected={pmtValue->Option.isSome} setIsSelected={isSelected => update(isSelected)}
    />
  }
}

let renderValueInp = (~pmtData, ~pm, ~connector, ~formValues) => (
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <PMT pmtData pm fieldsArray connector formValues />
}

let valueInput = (~pmtData, ~pmIndex, ~pmtIndex, ~pm, ~connector, ~formValues) => {
  open FormRenderer

  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderValueInp(~pmtData, ~pm, ~connector, ~formValues),
    ~inputFields=[
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method_type`,
      ),
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method_subtypes`,
      ),
      makeInputFieldInfo(~name=`payment_methods_enabled`),
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex->Int.toString}].payment_method_subtypes[${pmtIndex}]`,
      ),
    ],
    (),
  )
}

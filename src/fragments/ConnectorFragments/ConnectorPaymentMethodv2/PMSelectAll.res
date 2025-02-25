module PMSelectAll = {
  @react.component
  let make = (
    ~availablePM: array<ConnectorTypes.paymentMethodConfigType>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~pm,
    ~pmt,
  ) => {
    open LogicUtils
    open ConnectorPaymentMethodV3Utils
    let pmEnabledInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledValue =
      pmEnabledInp.value->getArrayDataFromJson(ConnectorInterfaceUtils.getPaymentMethodsEnabled)
    let pmArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let (isSelectedAll, setIsSelectedAll) = React.useState(() => false)
    let removeAllPM = () => {
      if pm->getPMFromString == Card && pmt->getPMTFromString == Credit {
        let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
        let updatePMTData = switch pmtData {
        | Some(data) =>
          data.payment_method_types->Array.filter(ele =>
            ele.payment_method_type->getPMTFromString != Credit
          )

        | None => []
        }
        let updatedData =
          [
            ("payment_method", pm->JSON.Encode.string),
            ("payment_method_types", updatePMTData->Identity.genericTypeToJson),
          ]
          ->Dict.fromArray
          ->Identity.anyTypeToReactEvent
        pmArrayInp.onChange(updatedData)
      } else if pm->getPMFromString == Card && pmt->getPMTFromString == Debit {
        let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
        let updatePMTData = switch pmtData {
        | Some(data) =>
          data.payment_method_types->Array.filter(ele =>
            ele.payment_method_type->getPMTFromString != Debit
          )

        | None => []
        }
        let updatedData =
          [
            ("payment_method", pm->JSON.Encode.string),
            ("payment_method_types", updatePMTData->Identity.genericTypeToJson),
          ]
          ->Dict.fromArray
          ->Identity.anyTypeToReactEvent

        pmArrayInp.onChange(updatedData)
      } else {
        let updatedData = pmEnabledValue->Array.filter(ele => ele.payment_method != pm)

        pmEnabledInp.onChange(updatedData->Identity.anyTypeToReactEvent)
      }
    }
    let selectAllPM = () => {
      let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
      /*
      On "Select All" for credit:  
      - Keep existing debit selections.  
      - Add all credit payment methods.  
      - Reason: Credit and debit are inside card PM.
 */

      let updateData = if pm->getPMFromString == Card && pmt->getPMTFromString == Credit {
        let filterData = switch pmtData {
        | Some(data) =>
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type->getPMTFromString != Credit)
          ->Array.concat(availablePM)
        | None => availablePM
        }
        filterData
      } else if pm->getPMFromString == Card && pmt->getPMTFromString == Debit {
        let filterData = switch pmtData {
        | Some(data) =>
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type->getPMTFromString != Debit)
          ->Array.concat(availablePM)
        | None => availablePM
        }
        filterData
      } else {
        availablePM
      }

      let updatedData =
        [
          ("payment_method", pm->JSON.Encode.string),
          ("payment_method_types", updateData->Identity.genericTypeToJson),
        ]
        ->Dict.fromArray
        ->Identity.anyTypeToReactEvent
      pmArrayInp.onChange(updatedData)
    }
    let onClickSelectAll = isSelectedAll => {
      if isSelectedAll {
        selectAllPM()
      } else {
        removeAllPM()
      }
      setIsSelectedAll(_ => isSelectedAll)
    }

    React.useEffect(() => {
      let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
      let isPMEnabled = switch pmtData {
      | Some(data) =>
        if pm->getPMFromString == Card && pmt->getPMTFromString == Credit {
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type->getPMTFromString == Credit)
          ->Array.length == availablePM->Array.length
        } else if pm->getPMFromString == Card && pmt->getPMTFromString == Debit {
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type->getPMTFromString == Debit)
          ->Array.length == availablePM->Array.length
        } else {
          data.payment_method_types->Array.length == availablePM->Array.length
        }
      | None => false
      }
      setIsSelectedAll(_ => isPMEnabled)
      None
    }, [])
    <div className="flex gap-2 items-center">
      <p className="font-normal"> {"Select All"->React.string} </p>
      <BoolInput.BaseComponent
        isSelected={isSelectedAll}
        setIsSelected={isSelectedAll => onClickSelectAll(isSelectedAll)}
        isDisabled={false}
        boolCustomClass="rounded-lg"
      />
    </div>
  }
}

let renderSelectAllValueInp = (~availablePM, ~pm, ~pmt) => (
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <PMSelectAll availablePM fieldsArray pm pmt />
}

let selectAllValueInput = (~availablePM, ~pmIndex, ~pm, ~pmt) => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderSelectAllValueInp(~availablePM, ~pm, ~pmt),
    ~inputFields=[
      makeInputFieldInfo(~name=`payment_methods_enabled`),
      makeInputFieldInfo(~name=`payment_methods_enabled[${pmIndex}]`),
    ],
    (),
  )
}

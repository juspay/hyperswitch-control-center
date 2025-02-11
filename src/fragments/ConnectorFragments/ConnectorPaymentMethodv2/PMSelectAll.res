module PMSelectAll = {
  @react.component
  let make = (
    ~availablePM: array<ConnectorTypes.paymentMethodConfigType>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~pm,
    ~pmt,
  ) => {
    open LogicUtils
    let pmEnabledInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledValue =
      pmEnabledInp.value->getArrayDataFromJson(ConnectorListMapper.getPaymentMethodsEnabled)
    let pmArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let (isSelectedAll, setIsSelectedAll) = React.useState(() => false)
    let removeAllPM = () => {
      if pm == "card" && pmt == "credit" {
        let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
        let d = switch pmtData {
        | Some(data) =>
          data.payment_method_types->Array.filter(ele => ele.payment_method_type != "credit")

        | None => []
        }
        let updatedData =
          [
            ("payment_method", pm->JSON.Encode.string),
            ("payment_method_types", d->Identity.genericTypeToJson),
          ]
          ->Dict.fromArray
          ->Identity.anyTypeToReactEvent
        pmArrayInp.onChange(updatedData)
      } else if pm == "card" && pmt == "debit" {
        let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
        let d = switch pmtData {
        | Some(data) =>
          data.payment_method_types->Array.filter(ele => ele.payment_method_type != "debit")

        | None => []
        }
        let updatedData =
          [
            ("payment_method", pm->JSON.Encode.string),
            ("payment_method_types", d->Identity.genericTypeToJson),
          ]
          ->Dict.fromArray
          ->Identity.anyTypeToReactEvent

        pmArrayInp.onChange(updatedData)
      } else {
        let d = pmEnabledValue->Array.filter(ele => ele.payment_method != pm)

        pmEnabledInp.onChange(d->Identity.anyTypeToReactEvent)
      }
    }
    let selectAllPM = () => {
      let pmtData = pmEnabledValue->Array.find(ele => ele.payment_method == pm)
      let updateData = if pm == "card" && pmt == "credit" {
        let filterData = switch pmtData {
        | Some(data) =>
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type != "credit")
          ->Array.concat(availablePM)
        | None => []
        }
        filterData
      } else if pm == "card" && pmt == "debit" {
        let filterData = switch pmtData {
        | Some(data) =>
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type != "credit")
          ->Array.concat(availablePM)
        | None => []
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
        if pm == "card" && pmt == "credit" {
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type == "credit")
          ->Array.length == availablePM->Array.length
        } else if pm == "card" && pmt == "debit" {
          data.payment_method_types
          ->Array.filter(ele => ele.payment_method_type == "debit")
          ->Array.length == availablePM->Array.length
        } else {
          data.payment_method_types->Array.length == availablePM->Array.length
        }
      | None => false
      }
      // Js.log("LOG")
      setIsSelectedAll(_ => isPMEnabled)
      None
    }, [])
    <>
      <p className="font-normal"> {"Select All"->React.string} </p>
      <BoolInput.BaseComponent
        isSelected={isSelectedAll}
        setIsSelected={isSelectedAll => onClickSelectAll(isSelectedAll)}
        isDisabled={false}
        boolCustomClass="rounded-lg"
      />
    </>
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

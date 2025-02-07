module Pmt = {
  @react.component
  let make = (
    ~pmt: ConnectorTypes.paymentMethodConfigType,
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
      None
    }, [isPMTEnabled])

    let removeMethods = () => {
      let updatedPmtArray =
        pmtArrayValue->Array.filter(ele => ele.payment_method_type != pmt.payment_method_type)
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
        pmtInp.onChange(pmt->Identity.anyTypeToReactEvent)
      }
      setIsSelected(_ => isSelected)
    }

    <CheckBoxIcon isSelected={isSelected} setIsSelected={isSelected => update(isSelected)} />
  }
}

let renderValueInp = (~pmt, ~pm) => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <Pmt pmt pm fieldsArray />
}

let valueInput = (~pmt, ~pmIndex, ~pmtIndex, ~pm) => {
  open FormRenderer

  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderValueInp(~pmt, ~pm),
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
module SelectAll = {
  @react.component
  let make = (
    ~availablePM: array<ConnectorTypes.paymentMethodConfigType>,
    ~initalValue: ConnectorTypes.connectorPayload,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~pm,
  ) => {
    open LogicUtils

    let pmEnabledInp = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let pmEnabledValue =
      pmEnabledInp.value->getArrayDataFromJson(ConnectorListMapper.getPaymentMethodsEnabled)
    let pmArrayInp = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let (isSelectedAll, setIsSelectedAll) = React.useState(() => false)
    let removeAllPM = () => {
      let updatedPmArray = pmEnabledValue->Array.filter(ele => ele.payment_method != pm)

      if updatedPmArray->Array.length == 0 {
        pmEnabledInp.onChange([]->Identity.anyTypeToReactEvent)
      } else {
        pmEnabledInp.onChange(updatedPmArray->Identity.anyTypeToReactEvent)
      }
    }
    let selectAllPM = () => {
      let pmtData = switch initalValue.payment_methods_enabled->Array.find(ele =>
        ele.payment_method == pm
      ) {
      | Some(data) =>
        switch data.payment_method_types->Array.find(ele =>
          ele.payment_method_type == ele.payment_method_type
        ) {
        | Some(d) =>
          availablePM
          ->Array.filter(ele => ele.payment_method_type != d.payment_method_type)
          ->Array.concat([d])

        | None => availablePM
        }

      | _ => availablePM
      }

      let updatedData =
        [
          ("payment_method", pm->JSON.Encode.string),
          ("payment_method_types", pmtData->Identity.genericTypeToJson),
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
    <>
      <p className="font-normal"> {"Select All"->React.string} </p>
      <BoolInput.BaseComponent
        isSelected={isSelectedAll}
        setIsSelected={isSelectedAll => onClickSelectAll(isSelectedAll)}
        // setIsSelected={isSelectedAll => onClickSelectAll(isSelectedAll)}
        isDisabled={false}
        boolCustomClass="rounded-lg"
      />
    </>
  }
}

let renderSelectAllValueInp = (~availablePM, ~initalValue, ~pm) => (
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <SelectAll availablePM initalValue fieldsArray pm />
}

let selectAllValueInput = (~availablePM, ~initalValue, ~pmIndex, ~pm) => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label=``,
    ~comboCustomInput=renderSelectAllValueInp(~availablePM, ~initalValue, ~pm),
    ~inputFields=[
      makeInputFieldInfo(~name=`payment_methods_enabled`),
      makeInputFieldInfo(~name=`payment_methods_enabled[${pmIndex}]`),
    ],
    (),
  )
}

@react.component
let make = (~initialValues, ~setInitialValues) => {
  open LogicUtils
  open FormRenderer
  open ConnectorPaymentMethodV2Utils
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let pmts = React.useMemo(() => {
    try {
      Window.getConnectorConfig(connector)->getDictFromJsonObject
    } catch {
    | _ => Dict.make()
    }
  }, [connector])

  let keys = React.useMemo(() => {
    pmts
    ->Dict.keysToArray
    ->Array.filter(val => !Array.includes(ConnectorUtils.configKeysToIgnore, val))
  }, [connector])
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initalValue = React.useMemo(() => {
    initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  }, [initialValues])
  let connData =
    formState.values->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  <div className="flex flex-col gap-6 col-span-3">
    <div className="max-w-3xl flex flex-col gap-8">
      {keys
      ->Array.mapWithIndex((wasmKey, ind) => {
        let wasmPm = if (
          wasmKey->ConnectorUtils.getPaymentMethodTypeFromString == Credit ||
            wasmKey->ConnectorUtils.getPaymentMethodTypeFromString == Debit
        ) {
          "card"
        } else {
          wasmKey
        }
        let isPMEnabled =
          connData.payment_methods_enabled->Array.findIndex(ele => ele.payment_method == wasmPm)
        let pmIndex =
          isPMEnabled == -1
            ? connData.payment_methods_enabled->Array.length > 0
                ? connData.payment_methods_enabled->Array.length
                : 0
            : isPMEnabled

        let wasmPmValues =
          pmts
          ->getArrayFromDict(wasmKey, [])
          ->getPaymentMethodMapper(wasmKey)
        // Js.log2(wasmPmValues, "wasmPmValues")
        <div
          key={ind->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
          <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
            <div className="flex gap-2.5 items-center">
              <div className="p-2 bg-white border rounded-md">
                <Icon name={wasmPm->pmIcon} />
              </div>
              <p className="font-semibold">
                {wasmKey->LogicUtils.capitalizeString->React.string}
              </p>
            </div>
            <div className="flex gap-2 items-center">
              <AddDataAttributes
                attributes=[
                  ("data-testid", wasmKey->String.concat("_")->String.concat("select_all")),
                ]>
                <FieldRenderer
                  field={selectAllValueInput(
                    ~availablePM=wasmPmValues,
                    ~initalValue,
                    ~pmIndex=pmIndex->Int.toString,
                    ~pm=wasmPm,
                  )}
                />
              </AddDataAttributes>
            </div>
          </div>
          <div className="flex gap-8 p-6 flex-wrap">
            {wasmPmValues
            ->Array.mapWithIndex((ele, i) => {
              let pmtIndex = if connData.payment_methods_enabled->Array.length > 0 {
                let t = connData.payment_methods_enabled->Array.get(pmIndex)

                let index = switch t {
                | Some(k) => {
                    let isPMTEnabled = k.payment_method_types->Array.findIndex(
                      val => {
                        if (
                          val.payment_method_type->ConnectorUtils.getPaymentMethodTypeFromString ==
                            Credit ||
                            val.payment_method_type->ConnectorUtils.getPaymentMethodTypeFromString ==
                              Debit
                        ) {
                          val.card_networks->Array.some(
                            networks => {
                              ele.card_networks->Array.includes(networks)
                            },
                          )
                        } else {
                          val.payment_method_type == ele.payment_method_type
                        }
                      },
                    )

                    isPMTEnabled == -1 ? k.payment_method_types->Array.length : isPMTEnabled
                  }
                | None => 0
                }
                index == -1 ? 0 : index
              } else {
                0
              }
              let pmtData = switch initalValue.payment_methods_enabled->Array.find(
                ele => ele.payment_method == wasmPm,
              ) {
              | Some(data) =>
                data.payment_method_types
                ->Array.find(ele => ele.payment_method_type == ele.payment_method_type)
                ->Option.getOr(ele)
              | None => ele
              }

              <AddDataAttributes
                attributes=[
                  (
                    "data-testid",
                    `${wasmPm
                      ->String.concat("_")
                      ->String.concat(ele.payment_method_type)
                      ->String.toLowerCase}`,
                  ),
                ]>
                <div key={i->Int.toString} className={"flex items-center gap-1.5"}>
                  <FieldRenderer
                    field={valueInput(
                      ~pmt=pmtData,
                      ~pmIndex,
                      ~pmtIndex=pmtIndex->Int.toString,
                      ~pm=wasmPm,
                    )}
                  />
                  <p className={`cursor-pointer`}>
                    {React.string({ele.payment_method_type}->snakeToTitle)}
                  </p>
                </div>
              </AddDataAttributes>
            })
            ->React.array}
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}

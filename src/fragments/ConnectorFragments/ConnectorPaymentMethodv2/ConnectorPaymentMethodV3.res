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

    <>
      <CheckBoxIcon isSelected={isSelected} setIsSelected={isSelected => update(isSelected)} />
    </>
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
      makeInputFieldInfo(~name=`payment_methods_enabled[${pmIndex}].payment_method`),
      makeInputFieldInfo(~name=`payment_methods_enabled[${pmIndex}].payment_method_types`),
      makeInputFieldInfo(~name=`payment_methods_enabled`),
      makeInputFieldInfo(
        ~name=`payment_methods_enabled[${pmIndex}].payment_method_types[${pmtIndex}]`,
      ),
    ],
    (),
  )
}

@react.component
let make = (~initialValues, ~setInitialValues) => {
  open ConnectorUtils
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
    ->Array.filter(val => !Array.includes(configKeysToIgnore, val))
  }, [connector])
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let connData =
    formState.values->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  <div className="flex flex-col gap-6 col-span-3">
    <div className="max-w-3xl flex flex-col gap-8">
      {keys
      ->Array.mapWithIndex((wasmPm, ind) => {
        let isPMEnabled =
          connData.payment_methods_enabled->Array.findIndex(ele => ele.payment_method == wasmPm)
        let pmIndex =
          isPMEnabled == -1
            ? connData.payment_methods_enabled->Array.length > 0
                ? connData.payment_methods_enabled->Array.length
                : 0
            : isPMEnabled

        let wasmPmValues =
          pmts->getArrayFromDict(wasmPm, [])->JSON.Encode.array->getPaymentMethodMapper
        <div
          key={ind->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
          <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
            <div className="flex gap-2.5 items-center">
              <div className="p-2 bg-white border rounded-md">
                <Icon name={wasmPm->pmIcon} />
              </div>
              <p className="font-semibold"> {wasmPm->LogicUtils.capitalizeString->React.string} </p>
            </div>
            // <div className="flex gap-2 items-center">
            //   <AddDataAttributes
            //     attributes=[
            //       ("data-testid", wasmPm->String.concat("_")->String.concat("select_all")),
            //     ]>
            //     <p className="font-normal"> {"Select All"->React.string} </p>
            //     <BoolInput.BaseComponent
            //       isSelected={false}
            //       setIsSelected={_ => ()}
            //       isDisabled={false}
            //       boolCustomClass="rounded-lg"
            //     />
            //   </AddDataAttributes>
            // </div>
          </div>
          <div className="flex gap-8 p-6 flex-wrap">
            {wasmPmValues
            ->Array.mapWithIndex((ele, i) => {
              let defaultPmtValue =
                getPaymentMethodTypeDict(
                  ~pm=wasmPm,
                  ~pmt=ele.payment_method_type,
                  ~pe=ele.payment_experience,
                )->itemProviderMapper

              let pmtIndex = if connData.payment_methods_enabled->Array.length > 0 {
                let t = connData.payment_methods_enabled->Array.get(pmIndex)
                let index = switch t {
                | Some(k) =>
                  let isPMTEnabled =
                    k.payment_method_types->Array.findIndex(
                      val => val.payment_method_type == ele.payment_method_type,
                    )

                  isPMTEnabled == -1 ? k.payment_method_types->Array.length : isPMTEnabled
                | None => 0
                }
                index == -1 ? 0 : index
              } else {
                0
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
                      ~pmt=defaultPmtValue,
                      ~pmIndex=pmIndex->Int.toString,
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

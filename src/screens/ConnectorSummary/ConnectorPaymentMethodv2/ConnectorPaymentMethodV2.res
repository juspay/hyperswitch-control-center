@react.component
let make = (~initialValues, ~setInitialValues) => {
  open ConnectorUtils
  open LogicUtils
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

  let connData = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let isPMSelected = (~pm, ~pmt) => {
    let selctPM = getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)
    isPMTSelectedUtils(~selctPM, ~pm, ~pmt)
  }
  let removePM = (~pm, ~pmt) => {
    connData.payment_methods_enabled = removePMTUtil(
      ~pmEnabled=connData.payment_methods_enabled,
      ~pm,
      ~pmt,
    )
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let _ =
      updatedValues->Dict.set(
        "payment_methods_enabled",
        connData.payment_methods_enabled->Identity.genericTypeToJson,
      )
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
  }

  let addPM = (~pm, ~pmt) => {
    let newPaymentMenthodType = getPaymentMethodTypeDict(~pm, ~pmt)
    let data = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
    if getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)->Array.length > 0 {
      let _ = data.payment_methods_enabled->Array.forEach(methods => {
        if methods.payment_method->String.toLowerCase === pm->String.toLowerCase {
          methods.payment_method_types->Array.push(
            newPaymentMenthodType->ConnectorListMapper.getPaymentMethodTypes,
          )
        }
      })
    } else {
      let newPaymentMethod =
        [
          ("payment_method", pm->JSON.Encode.string),
          ("payment_method_types", [newPaymentMenthodType->JSON.Encode.object]->JSON.Encode.array),
        ]
        ->Dict.fromArray
        ->ConnectorListMapper.getPaymentMethodsEnabled
      let _ = data.payment_methods_enabled->Array.push(newPaymentMethod)
    }
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let _ =
      updatedValues->Dict.set(
        "payment_methods_enabled",
        data.payment_methods_enabled->Identity.genericTypeToJson,
      )
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
  }

  let isAllPMChecked = (~pm) => {
    let provider = pmts->getArrayFromDict(pm, [])
    let methods = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
    let selectedMethod = getSelectedPM(~pmEnabled=methods.payment_methods_enabled, ~pm)
    selectedMethod->Array.length == provider->Array.length
  }

  let removeAllPM = (~pm) => {
    let data = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
    data.payment_methods_enabled = removeEnabledPM(~pmEnabled=data.payment_methods_enabled, ~pm)
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let _ =
      updatedValues->Dict.set(
        "payment_methods_enabled",
        data.payment_methods_enabled->Identity.genericTypeToJson,
      )
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
  }

  let selectAllPM = (~pm) => {
    if isAllPMChecked(~pm) {
      removeAllPM(~pm)
    } else {
      let provider = pmts->getArrayFromDict(pm, [])
      let dict = Dict.make()
      dict->Dict.set(
        "payment_methods_enabled",
        connData.payment_methods_enabled->Identity.genericTypeToJson,
      )
      provider->Array.forEach(pmt => {
        let label = pmt->getDictFromJsonObject->getString("payment_method_type", "")
        let newPaymentMenthodType = getPaymentMethodTypeDict(~pm, ~pmt=label)
        let data = dict->ConnectorListMapper.getProcessorPayloadType
        if !isPMSelected(~pm, ~pmt=label) {
          let newPaymentMethod =
            [
              ("payment_method", pm->JSON.Encode.string),
              (
                "payment_method_types",
                [newPaymentMenthodType->JSON.Encode.object]->JSON.Encode.array,
              ),
            ]
            ->Dict.fromArray
            ->ConnectorListMapper.getPaymentMethodsEnabled
          let _ = data.payment_methods_enabled->Array.push(newPaymentMethod)
        }
        let _ =
          dict->Dict.set(
            "payment_methods_enabled",
            data.payment_methods_enabled->Identity.genericTypeToJson,
          )
      })
      let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
      let _ =
        updatedValues->Dict.set(
          "payment_methods_enabled",
          dict->getArrayFromDict("payment_methods_enabled", [])->Identity.genericTypeToJson,
        )
      setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
    }
  }

  let onClick = (~pm, ~pmt) => {
    if isPMSelected(~pm, ~pmt) {
      removePM(~pm, ~pmt)
    } else {
      addPM(~pm, ~pmt)
    }
  }

  <>
    <div className="grid grid-cols-4 flex-1 p-2 md:p-10">
      <div className="flex flex-col gap-6 col-span-3">
        <HSwitchUtils.AlertBanner
          bannerText="Please verify if the payment methods are turned on at the processor end as well."
          bannerType=Warning
        />
        {keys
        ->Array.mapWithIndex((pm, i) => {
          let provider = pmts->getArrayFromDict(pm, [])
          switch pm->getPaymentMethodTypeFromString {
          | Credit | Debit =>
            <div key={i->Int.toString}>
              <p> {pm->React.string} </p>
              <div className="flex gap-2 items-center">
                <BoolInput.BaseComponent
                  isSelected={isAllPMChecked(~pm)}
                  setIsSelected={_ => selectAllPM(~pm)}
                  isDisabled={false}
                  boolCustomClass="rounded-lg"
                />
                <p> {"Select all"->React.string} </p>
              </div>
              <div className="flex flex-col gap-4 border rounded-md p-6">
                {provider
                ->Array.mapWithIndex((pmt, index) => {
                  let lable = pmt->getDictFromJsonObject->getString("payment_method_type", "")
                  <div
                    key={index->Int.toString}
                    onClick={_ => onClick(~pm, ~pmt=lable)}
                    className={`grid  "grid-cols-4"} gap-4`}>
                    <CheckBoxIcon isSelected={isPMSelected(~pm, ~pmt=lable)} />
                    <p className={` cursor-pointer`}> {React.string({lable}->snakeToTitle)} </p>
                  </div>
                })
                ->React.array}
              </div>
            </div>
          | _ =>
            <div key={i->Int.toString}>
              <div className={`grid  "grid-cols-4"} gap-4`}>
                <p> {pm->React.string} </p>
                <div className="flex gap-2 items-center">
                  <BoolInput.BaseComponent
                    isSelected={isAllPMChecked(~pm)}
                    setIsSelected={_ => selectAllPM(~pm)}
                    isDisabled={false}
                    boolCustomClass="rounded-lg"
                  />
                  <p> {"Select all"->React.string} </p>
                </div>
                <div className="flex flex-col gap-4 border rounded-md p-6">
                  {provider
                  ->Array.mapWithIndex((pmt, index) => {
                    let lable =
                      pmt
                      ->getDictFromJsonObject
                      ->getString("payment_method_type", "")
                    <div
                      key={index->Int.toString}
                      onClick={_ => onClick(~pm, ~pmt=lable)}
                      className={`grid  "grid-cols-4"} gap-4`}>
                      <CheckBoxIcon isSelected={isPMSelected(~pm, ~pmt=lable)} />
                      <p className={` cursor-pointer`}> {React.string({lable}->snakeToTitle)} </p>
                    </div>
                  })
                  ->React.array}
                </div>
              </div>
            </div>
          }
        })
        ->React.array}
      </div>
    </div>
  </>
}

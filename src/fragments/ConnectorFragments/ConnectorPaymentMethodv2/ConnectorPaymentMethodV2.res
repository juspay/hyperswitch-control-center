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

  let isPMESelect = (~pme, ~pm, ~pmt) => {
    let selctPM = getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)
    isPMTSelectedUtils(
      ~selctPM,
      ~pm,
      ~pmt,
      ~connector=connector->getConnectorNameTypeFromString,
      ~pme,
    )
  }
  let isPMSelected = (~pm, ~pmt, ~pme) => {
    let selctPM = getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)
    isPMTSelectedUtils(
      ~selctPM,
      ~pm,
      ~pmt,
      ~connector=connector->getConnectorNameTypeFromString,
      ~pme,
    )
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

  let checkPaymentMethodTypeAndExperience = (
    obj: ConnectorTypes.paymentMethodConfigType,
    pme: option<string>,
    pm: string,
  ) => {
    obj.payment_method_type == pm && obj.payment_experience == pme
  }
  // let df = pmts->JSON.Encode.object->ConnectorUtils.getPaymentMethodMapper
  // Js.log(pmts)

  let addPM = (~pm, ~pmt, ~pme=None) => {
    Js.log(pme)
    let newPaymentMenthodType = getPaymentMethodTypeDict(~pm, ~pmt, ~pe=pme)
    let data = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
    let dc =
      pmts
      ->getArrayFromDict("pay_later", [])
      ->JSON.Encode.array
      ->ConnectorUtils.getPaymentMethodMapper

    let provider = dc->Array.some(obj => checkPaymentMethodTypeAndExperience(obj, pme, pm))
    Js.log2(provider, pme)

    // standardProviders->Array.some(obj => checkPaymentMethodTypeAndExperience(obj, method))
    // switch (
    //   pmt->getPaymentMethodTypeFromString,
    //   pm->getPaymentMethodFromString,
    //   connector->getConnectorNameTypeFromString,
    // ) {
    // | (Klarna, PayLater, Processors(KLARNA)) => Js.log("")
    // }

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
    switch pm->getPaymentMethodTypeFromString {
    | Credit | Debit =>
      getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)->Array.length ==
        provider->Array.length
    | _ =>
      switch getSelectedPM(~pmEnabled=connData.payment_methods_enabled, ~pm)->Array.get(0) {
      | Some(val) => val.payment_method_types->Array.length == provider->Array.length
      | None => false
      }
    }
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
        if !isPMSelected(~pm, ~pmt=label, ~pme=None) {
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

  let onClick = (~pm, ~pmt, ~pme=None) => {
    if isPMSelected(~pm, ~pmt, ~pme) {
      removePM(~pm, ~pmt)
    } else {
      addPM(~pm, ~pmt, ~pme)
    }
  }

  <div className="flex flex-col gap-6 col-span-3">
    // <HSwitchUtils.AlertBanner
    //   bannerText="Please verify if the payment methods are turned on at the processor end as well."
    //   bannerType=Warning
    // />
    <div className="max-w-3xl flex flex-col gap-8">
      {keys
      ->Array.mapWithIndex((pm, i) => {
        let provider = pmts->getArrayFromDict(pm, [])
        switch pm->getPaymentMethodTypeFromString {
        | Credit | Debit =>
          <div
            key={i->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
            <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
              <div className="flex gap-2.5 items-center">
                <div className="p-2 bg-white border rounded-md">
                  <Icon name={pm->pmIcon} />
                </div>
                <p className="font-semibold"> {pm->LogicUtils.capitalizeString->React.string} </p>
              </div>
              <div className="flex gap-2 items-center">
                <AddDataAttributes
                  attributes=[("data-testid", pm->String.concat("_")->String.concat("select_all"))]>
                  <p className="font-normal"> {"Select All"->React.string} </p>
                  <BoolInput.BaseComponent
                    isSelected={isAllPMChecked(~pm)}
                    setIsSelected={_ => selectAllPM(~pm)}
                    isDisabled={false}
                    boolCustomClass="rounded-lg"
                  />
                </AddDataAttributes>
              </div>
            </div>
            <div className="flex gap-8 p-6 flex-wrap">
              {provider
              ->Array.mapWithIndex((pmt, index) => {
                let lable = pmt->getDictFromJsonObject->getString("payment_method_type", "")
                <AddDataAttributes
                  attributes=[
                    (
                      "data-testid",
                      `${pm
                        ->String.concat("_")
                        ->String.concat(lable)
                        ->String.toLowerCase}`,
                    ),
                  ]>
                  <div
                    key={index->Int.toString}
                    onClick={_ => onClick(~pm, ~pmt=lable)}
                    className={"flex items-center gap-1.5"}>
                    <CheckBoxIcon isSelected={isPMSelected(~pm, ~pmt=lable, ~pme=None)} />
                    <p className={`cursor-pointer`}> {React.string({lable}->snakeToTitle)} </p>
                  </div>
                </AddDataAttributes>
              })
              ->React.array}
            </div>
          </div>
        | _ =>
          <div
            key={i->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
            <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
              <div className="flex gap-2.5 items-center">
                <div className="p-2 bg-white border rounded-md">
                  <Icon name={pm->pmIcon} />
                </div>
                <p className="font-semibold"> {pm->LogicUtils.snakeToTitle->React.string} </p>
              </div>
              <RenderIf condition={enableSelectAll(~pm=pm->getPaymentMethodFromString)}>
                <AddDataAttributes
                  attributes=[("data-testid", pm->String.concat("_")->String.concat("select_all"))]>
                  <div className="flex gap-2 items-center">
                    <p className="font-normal"> {"Select all"->React.string} </p>
                    <BoolInput.BaseComponent
                      isSelected={isAllPMChecked(~pm)}
                      setIsSelected={_ => selectAllPM(~pm)}
                      isDisabled={false}
                      boolCustomClass="rounded-lg"
                    />
                  </div>
                </AddDataAttributes>
              </RenderIf>
            </div>
            <RenderIf
              condition={pm->getPaymentMethodFromString === Wallet &&
                {
                  switch connector->getConnectorNameTypeFromString {
                  | Processors(ZEN) => true
                  | _ => false
                  }
                }}>
              <div className="border rounded p-2 bg-jp-gray-100 flex gap-4">
                <Icon name="outage_icon" size=15 />
                {"Zen doesn't support Googlepay and Applepay in sandbox."->React.string}
              </div>
            </RenderIf>
            <div className="flex gap-8  p-6 flex-wrap">
              {provider
              ->Array.mapWithIndex((pmt, index) => {
                let lable =
                  pmt
                  ->getDictFromJsonObject
                  ->getString("payment_method_type", "")
                <AddDataAttributes
                  attributes=[
                    (
                      "data-testid",
                      `${pm
                        ->String.concat("_")
                        ->String.concat(lable)
                        ->String.toLowerCase}`,
                    ),
                  ]>
                  <div
                    key={index->Int.toString}
                    onClick={_ =>
                      onClick(
                        ~pm,
                        ~pmt=lable,
                        ~pme=pmt
                        ->getDictFromJsonObject
                        ->getOptionString("payment_experience"),
                      )}
                    className={`flex items-center gap-1.5`}>
                    {switch connector->getConnectorNameTypeFromString {
                    | Processors(KLARNA) =>
                      <RenderIf
                        condition={!(
                          pmt
                          ->getDictFromJsonObject
                          ->getString("payment_experience", "") === "redirect_to_url" &&
                            connData.metadata
                            ->getDictFromJsonObject
                            ->getString("klarna_region", "") !== "Europe"
                        )}>
                        <CheckBoxIcon
                          isSelected={isPMSelected(
                            ~pm,
                            ~pmt=lable,
                            ~pme=pmt
                            ->getDictFromJsonObject
                            ->getOptionString("payment_experience"),
                          )}
                        />
                      </RenderIf>
                    | _ => <CheckBoxIcon isSelected={isPMSelected(~pm, ~pmt=lable, ~pme=None)} />
                    }}
                    {switch (
                      lable->getPaymentMethodTypeFromString,
                      pm->getPaymentMethodFromString,
                      connector->getConnectorNameTypeFromString,
                    ) {
                    | (PayPal, Wallet, Processors(PAYPAL)) =>
                      <p className={` cursor-pointer`}>
                        {pmt
                        ->getDictFromJsonObject
                        ->getString("payment_experience", "") === "redirect_to_url"
                          ? "PayPal Redirect"->React.string
                          : "PayPal SDK"->React.string}
                      </p>
                    | (Klarna, PayLater, Processors(KLARNA)) =>
                      <RenderIf
                        condition={!(
                          pmt
                          ->getDictFromJsonObject
                          ->getString("payment_experience", "") === "redirect_to_url" &&
                            connData.metadata
                            ->getDictFromJsonObject
                            ->getString("klarna_region", "") !== "Europe"
                        )}>
                        <p className={` cursor-pointer`}>
                          {pmt
                          ->getDictFromJsonObject
                          ->getString("payment_experience", "") === "redirect_to_url"
                            ? "Klarna Checkout"->React.string
                            : "Klarna SDK"->React.string}
                        </p>
                      </RenderIf>

                    | (OpenBankingPIS, _, _) =>
                      <p className={` cursor-pointer`}> {"Open Banking PIS"->React.string} </p>

                    | _ =>
                      <p className={` cursor-pointer`}> {React.string({lable}->snakeToTitle)} </p>
                    }}

                    // <p className={` cursor-pointer`}> {React.string({lable}->snakeToTitle)} </p>
                  </div>
                </AddDataAttributes>
              })
              ->React.array}
            </div>
          </div>
        }
      })
      ->React.array}
    </div>
  </div>
}

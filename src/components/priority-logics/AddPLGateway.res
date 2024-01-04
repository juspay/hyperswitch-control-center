type gateway = PriorityLogicUtils.gateway

module GatewayView = {
  @react.component
  let make = (~gateways: array<gateway>) => {
    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        <AddDataAttributes attributes=[("data-plc-text", ruleGateway.gateway_name)]>
          <div
            key={Belt.Int.toString(index)}
            className="my-2 h-6 md:h-8 flex items-center rounded-md  border border-jp-gray-500 dark:border-jp-gray-960 font-medium
                            text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 
                            dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1">
            {React.string(ruleGateway.gateway_name)}
            {if ruleGateway.distribution !== 100 {
              <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
                {React.string(ruleGateway.distribution->string_of_int ++ "%")}
              </span>
            } else {
              React.null
            }}
          </div>
        </AddDataAttributes>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (
  ~id,
  ~gatewayOptions,
  ~isFirst=false,
  ~isExpanded=false,
  ~showPriorityIcon=true,
  ~showDistributionIcon=true,
  ~showFallbackIcon=true,
  ~dropDownButtonText="Add Gateways",
  ~connectorList=?,
) => {
  let gateWaysInput = ReactFinalForm.useField(`${id}`).input

  let isDistribute =
    id === "algorithm.data" ||
      !(
        gateWaysInput.value
        ->LogicUtils.getArrayFromJson([])
        ->Array.some(ele =>
          ele->LogicUtils.getDictFromJsonObject->LogicUtils.getFloat("distribution", 0.0) === 100.0
        )
      )

  let selectedOptions =
    gateWaysInput.value
    ->Js.Json.decodeArray
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(item =>
      item
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(dict => {
        let obj: gateway = {
          gateway_name: dict->LogicUtils.getString("gateway_name", ""),
          distribution: dict->LogicUtils.getInt("distribution", 100),
          disableFallback: dict->LogicUtils.getBool("disableFallback", false),
        }
        Some(obj)
      })
    )

  let getDisableFallback = item => {
    selectedOptions
    ->Array.find(str => str.gateway_name === item)
    ->Belt.Option.mapWithDefault(false, item => item.disableFallback)
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "gateways",
    onBlur: _ev => (),
    onChange: ev => {
      let newSelectedOptions = ev->Identity.formReactEventToArrayOfString
      if newSelectedOptions->Array.length === 0 {
        gateWaysInput.onChange([]->Identity.anyTypeToReactEvent)
      } else {
        let sharePercent = isDistribute ? 100 / newSelectedOptions->Array.length : 100
        let gatewaysArr = newSelectedOptions->Array.mapWithIndex((item, i) => {
          let sharePercent = if i === newSelectedOptions->Array.length - 1 && isDistribute {
            100 - sharePercent * i
          } else {
            sharePercent
          }
          let obj: gateway = {
            gateway_name: item,
            distribution: sharePercent,
            disableFallback: getDisableFallback(item),
          }
          obj
        })
        gateWaysInput.onChange(gatewaysArr->Identity.anyTypeToReactEvent)
      }
    },
    onFocus: _ev => (),
    value: selectedOptions->Array.map(i => i.gateway_name->Js.Json.string)->Js.Json.array,
    checked: true,
  }

  let onClickFallback = newFallbackValue => {
    if isDistribute {
      selectedOptions
      ->Array.map(item => {...item, disableFallback: newFallbackValue})
      ->Identity.anyTypeToReactEvent
      ->gateWaysInput.onChange
    }
  }
  React.useEffect1(_ => {
    if selectedOptions->Array.length < 2 {
      onClickFallback(false)
    }
    None
  }, [selectedOptions->Array.length])

  let updatePercentage = (item: gateway, value) => {
    if value < 100 {
      let newList = selectedOptions->Array.map(option => {
        if option.gateway_name === item.gateway_name {
          {...option, distribution: value}
        } else {
          option
        }
      })
      gateWaysInput.onChange(newList->Identity.anyTypeToReactEvent)
    }
  }

  let removeItem = index => {
    input.onChange(
      selectedOptions
      ->Array.map(i => i.gateway_name)
      ->Array.filterWithIndex((_, i) => i !== index)
      ->Identity.anyTypeToReactEvent,
    )
  }

  let gatewayName = name => {
    let res =
      connectorList
      ->Belt.Option.getWithDefault([Dict.make()->ConnectorTableUtils.getProcessorPayloadType])
      ->ConnectorTableUtils.getConnectorNameViaId(name)
    res.connector_label
  }

  if isExpanded {
    <div className="flex flex-row ml-2">
      {if !isFirst {
        <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
      } else {
        React.null
      }}
      <div className="flex flex-col gap-6 mt-6 mb-4 pt-0.5">
        <div className="flex flex-wrap gap-4">
          <AddDataAttributes attributes=[("data-gateway-dropdown", "AddGateways")]>
            <div className="flex">
              <SelectBox.BaseDropdown
                allowMultiSelect=true
                buttonText=dropDownButtonText
                buttonType=Button.SecondaryFilled
                hideMultiSelectButtons=true
                customButtonStyle="bg-white dark:bg-jp-gray-darkgray_background"
                input
                options={gatewayOptions}
                fixedDropDownDirection=SelectBox.TopRight
                searchable=true
                defaultLeftIcon={FontAwesome("plus")}
                maxHeight="max-h-full sm:max-h-64"
              />
              <span className="text-lg text-red-500 ml-1"> {React.string("*")} </span>
            </div>
          </AddDataAttributes>
          {selectedOptions
          ->Array.mapWithIndex((item, i) => {
            let key = string_of_int(i + 1)
            <AddDataAttributes key attributes=[("data-gateway-button", item.gateway_name)]>
              {<div className="flex flex-row">
                <div
                  className="w-min flex flex-row items-center justify-around gap-2 h-10 rounded-md  border border-jp-gray-500 dark:border-jp-gray-960
               text-jp-gray-900 text-opacity-75 hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme
               dark:hover:text-opacity-75 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 bg-gradient-to-b
               from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-jp-gray-text_darktheme
               dark:text-opacity-50 focus:outline-none px-1 ">
                  <AddDataAttributes attributes=[("data-gateway-count", key)]>
                    <NewThemeUtils.Badge number={i + 1} />
                  </AddDataAttributes>
                  <div> {item.gateway_name->gatewayName->React.string} </div>
                  <Icon
                    name="close"
                    size=10
                    className="mr-2 cursor-pointer "
                    onClick={ev => {
                      ev->ReactEvent.Mouse.stopPropagation
                      removeItem(i)
                    }}
                  />
                  {if isDistribute && selectedOptions->Array.length > 0 {
                    <>
                      <input
                        className="w-10 text-right outline-none bg-white dark:bg-jp-gray-970 px-1 border border-jp-gray-300 dark:border-jp-gray-850 rounded-md"
                        name=key
                        onChange={ev => {
                          let val = ReactEvent.Form.target(ev)["value"]
                          updatePercentage(
                            item,
                            val->Belt.Int.fromString->Belt.Option.getWithDefault(0),
                          )
                        }}
                        value={item.distribution->Belt.Int.toString}
                        type_="text"
                        inputMode="text"
                      />
                      <div> {React.string("%")} </div>
                    </>
                  } else {
                    React.null
                  }}
                </div>
              </div>}
            </AddDataAttributes>
          })
          ->React.array}
        </div>
        {if selectedOptions->Array.length > 0 {
          <div
            className="flex flex-col md:flex-row md:items-center gap-4 md:gap-3 lg:gap-4 lg:ml-6">
            {if selectedOptions->Array.length > 1 && showFallbackIcon {
              <AddDataAttributes attributes=[("data-gateway-checkbox", "DisableFallback")]>
                <div
                  className={`flex flex-row items-center gap-4 md:gap-1 lg:gap-2 
              ${isDistribute ? "" : "cursor-not-allowed"}`}>
                  <div> {React.string("Disable Fallback")} </div>
                </div>
              </AddDataAttributes>
            } else {
              React.null
            }}
          </div>
        } else {
          React.null
        }}
      </div>
    </div>
  } else {
    <GatewayView gateways=selectedOptions />
  }
}

external arrToReactEvent: array<string> => ReactEvent.Form.t = "%identity"
external toReactEvent: 'a => ReactEvent.Form.t = "%identity"
external formEventToStrArr: ReactEvent.Form.t => array<string> = "%identity"
external formEventToStr: ReactEvent.Form.t => string = "%identity"
type gateway = PriorityLogicUtils.gateway

module GatewayView = {
  @react.component
  let make = (~gateways: array<gateway>, ~isEnforceGatewayPriority) => {
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
      {if isEnforceGatewayPriority {
        <div className="flex flex-row gap-1 ml-5 items-center ">
          <CheckBoxIcon
            isSelected=isEnforceGatewayPriority setIsSelected={_ => ()} isDisabled=false
          />
          <div> {React.string("Enforce Gateway Priority")} </div>
        </div>
      } else {
        React.null
      }}
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
  let gateWaysInput = ReactFinalForm.useField(`${id}.gateways`).input
  let enforceGatewayPriorityInput = ReactFinalForm.useField(`${id}.isEnforceGatewayPriority`).input
  let isDistributeInput = ReactFinalForm.useField(`${id}.isDistribute`).input

  let gatewaysJsonArr = gateWaysInput.value->Js.Json.decodeArray->Belt.Option.getWithDefault([])
  let isDistribute =
    id === "json.volumeBasedDistribution" ||
    isDistributeInput.value->LogicUtils.getBoolFromJson(false) ||
    !(
      gateWaysInput.value
      ->LogicUtils.getArrayFromJson([])
      ->Js.Array2.some(ele =>
        ele->LogicUtils.getDictFromJsonObject->LogicUtils.getFloat("distribution", 0.0) === 100.0
      )
    )

  let isEnforceGatewayPriority =
    enforceGatewayPriorityInput.value->Js.Json.decodeBoolean->Belt.Option.getWithDefault(false)
  let isDisableFallback =
    gatewaysJsonArr->Js.Array2.some(json =>
      json
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(Js.Dict.get(_, "disableFallback"))
      ->Belt.Option.flatMap(Js.Json.decodeBoolean)
      ->Belt.Option.getWithDefault(false)
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
    ->Js.Array2.find(str => str.gateway_name === item)
    ->Belt.Option.mapWithDefault(false, item => item.disableFallback)
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "gateways",
    onBlur: _ev => (),
    onChange: ev => {
      let newSelectedOptions = ev->formEventToStrArr
      if newSelectedOptions->Js.Array2.length === 0 {
        gateWaysInput.onChange([]->toReactEvent)
      } else {
        let sharePercent = isDistribute ? 100 / newSelectedOptions->Js.Array2.length : 100
        let gatewaysArr = newSelectedOptions->Array.mapWithIndex((item, i) => {
          let sharePercent = if i === newSelectedOptions->Js.Array2.length - 1 && isDistribute {
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
        gateWaysInput.onChange(gatewaysArr->toReactEvent)
      }
    },
    onFocus: _ev => (),
    value: selectedOptions->Js.Array2.map(i => i.gateway_name->Js.Json.string)->Js.Json.array,
    checked: true,
  }

  let onClickDistribute = newDistributeValue => {
    if id !== "json.volumeBasedDistribution" {
      let sharePercent = newDistributeValue ? 100 / selectedOptions->Js.Array2.length : 100
      let gatewaysArr = selectedOptions->Array.mapWithIndex((item, i) => {
        let sharePercent = if i === selectedOptions->Js.Array2.length - 1 && newDistributeValue {
          100 - sharePercent * i
        } else {
          sharePercent
        }
        {
          ...item,
          distribution: sharePercent,
          disableFallback: newDistributeValue ? item.disableFallback : false,
        }
      })
      gateWaysInput.onChange(gatewaysArr->toReactEvent)
    }
  }

  let onClickFallback = newFallbackValue => {
    if isDistribute {
      selectedOptions
      ->Js.Array2.map(item => {...item, disableFallback: newFallbackValue})
      ->toReactEvent
      ->gateWaysInput.onChange
    }
  }
  React.useEffect1(_ => {
    if selectedOptions->Js.Array2.length < 2 {
      onClickFallback(false)
    }
    None
  }, [selectedOptions->Js.Array2.length])

  let updatePercentage = (item: gateway, value) => {
    if value < 100 {
      let newList = selectedOptions->Js.Array2.map(option => {
        if option.gateway_name === item.gateway_name {
          {...option, distribution: value}
        } else {
          option
        }
      })
      gateWaysInput.onChange(newList->toReactEvent)
    }
  }

  let updateFallback = (index, value) => {
    let newList = selectedOptions->Array.mapWithIndex((option, i) => {
      if i === index {
        {...option, disableFallback: value}
      } else {
        option
      }
    })
    gateWaysInput.onChange(newList->toReactEvent)
  }

  let removeItem = index => {
    input.onChange(
      selectedOptions
      ->Js.Array2.map(i => i.gateway_name)
      ->Array.filterWithIndex((_, i) => i !== index)
      ->toReactEvent,
    )
  }

  let gatewayName = name => {
    let res =
      connectorList
      ->Belt.Option.getWithDefault([Js.Dict.empty()->ConnectorTableUtils.getProcessorPayloadType])
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
                  {if isDisableFallback {
                    <CheckBoxIcon
                      isSelected=item.disableFallback
                      setIsSelected={v => updateFallback(i, v)}
                      isDisabled=false
                    />
                  } else {
                    React.null
                  }}
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
                  {if isDistribute && selectedOptions->Js.Array2.length > 0 {
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
        {if selectedOptions->Js.Array2.length > 0 {
          <div
            className="flex flex-col md:flex-row md:items-center gap-4 md:gap-3 lg:gap-4 lg:ml-6">
            {<>
              {if showPriorityIcon {
                <AddDataAttributes attributes=[("data-gateway-checkbox", "EnforceGatewayPriority")]>
                  <div className="flex flex-row items-center gap-4 md:gap-1 lg:gap-2">
                    <CheckBoxIcon
                      isSelected=isEnforceGatewayPriority
                      setIsSelected={v => {
                        enforceGatewayPriorityInput.onChange(v->toReactEvent)
                      }}
                      isDisabled=false
                    />
                    <div> {React.string("Enforce Gateway Priority")} </div>
                  </div>
                </AddDataAttributes>
              } else {
                React.null
              }}
              {if showDistributionIcon {
                <AddDataAttributes attributes=[("data-gateway-checkbox", "Distribute")]>
                  <div
                    className={`flex flex-row items-center gap-4 md:gap-1 lg:gap-2 
              ${id === "json.volumeBasedDistribution" ? "cursor-not-allowed" : ""}`}>
                    <CheckBoxIcon
                      isSelected=isDistribute
                      setIsSelected={v => {
                        isDistributeInput.onChange(v->toReactEvent)
                        onClickDistribute(v)
                      }}
                      isDisabled=false
                    />
                    <div> {React.string("Distribute")} </div>
                  </div>
                </AddDataAttributes>
              } else {
                React.null
              }}
            </>}
            {if selectedOptions->Js.Array2.length > 1 && showFallbackIcon {
              <AddDataAttributes attributes=[("data-gateway-checkbox", "DisableFallback")]>
                <div
                  className={`flex flex-row items-center gap-4 md:gap-1 lg:gap-2 
              ${isDistribute ? "" : "cursor-not-allowed"}`}>
                  <CheckBoxIcon
                    isSelected=isDisableFallback setIsSelected=onClickFallback isDisabled=false
                  />
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
    <GatewayView gateways=selectedOptions isEnforceGatewayPriority />
  }
}

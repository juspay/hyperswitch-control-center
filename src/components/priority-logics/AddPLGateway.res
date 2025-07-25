type gateway = RoutingTypes.volumeSplitConnectorSelectionData

module GatewayView = {
  @react.component
  let make = (~gateways: array<gateway>) => {
    let url = RescriptReactRouter.useUrl()
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)

    let connectorType: ConnectorTypes.connectorTypeVariants = switch url->RoutingUtils.urlToVariantMapper {
    | PayoutRouting => ConnectorTypes.PayoutProcessor
    | _ => ConnectorTypes.PaymentProcessor
    }
    let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=connectorType)

    let getGatewayName = merchantConnectorId => {
      (
        connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
          merchantConnectorId,
          ~version=V1,
        )
      ).connector_label
    }

    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        <div
          key={Int.toString(index)}
          className={`my-2 h-6 md:h-8 flex items-center rounded-md  border border-jp-gray-500 dark:border-jp-gray-960 font-medium
                            ${textColor.primaryNormal} hover:${textColor.primaryNormal} bg-gradient-to-b from-jp-gray-250 to-jp-gray-200
                            dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1`}>
          {React.string(ruleGateway.connector.merchant_connector_id->getGatewayName)}
          <RenderIf condition={ruleGateway.split !== 0}>
            <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
              {React.string(ruleGateway.split->Int.toString ++ "%")}
            </span>
          </RenderIf>
        </div>
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
  ~connectorList,
) => {
  let gateWaysInput = ReactFinalForm.useField(`${id}`).input

  let gateWayName = merchantConnectorID => {
    connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
      merchantConnectorID,
      ~version=V1,
    )
  }

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
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Belt.Array.keepMap(item =>
      item
      ->JSON.Decode.object
      ->Option.flatMap(dict => {
        let connectorDict = dict->LogicUtils.getDictfromDict("connector")
        let obj: gateway = {
          connector: {
            connector: connectorDict->LogicUtils.getString("connector", ""),
            merchant_connector_id: connectorDict->LogicUtils.getString("merchant_connector_id", ""),
          },
          split: dict->LogicUtils.getInt("split", 100),
        }
        Some(obj)
      })
    )

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "gateways",
    onBlur: _ => (),
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
            connector: {
              connector: gateWayName(item).connector_name,
              merchant_connector_id: item,
            },
            split: sharePercent,
          }
          obj
        })
        gateWaysInput.onChange(gatewaysArr->Identity.anyTypeToReactEvent)
      }
    },
    onFocus: _ => (),
    value: selectedOptions
    ->Array.map(selectedOption =>
      selectedOption.connector.merchant_connector_id->JSON.Encode.string
    )
    ->JSON.Encode.array,
    checked: true,
  }

  let updatePercentage = (item: gateway, value) => {
    if value < 100 {
      let newList = selectedOptions->Array.map(option => {
        if option.connector.connector === item.connector.connector {
          {...option, split: value}
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
      ->Array.map(selectedOption => selectedOption.connector.merchant_connector_id)
      ->Array.filterWithIndex((_, i) => i !== index)
      ->Identity.anyTypeToReactEvent,
    )
  }

  if isExpanded {
    <div className="flex flex-row ml-2">
      <RenderIf condition={!isFirst}>
        <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
      </RenderIf>
      <div className="flex flex-col gap-6 mt-6 mb-4 pt-0.5">
        <div className="flex flex-wrap gap-4">
          <div className="flex">
            <SelectBox.BaseDropdown
              allowMultiSelect=true
              buttonText=dropDownButtonText
              buttonType=Button.SecondaryFilled
              hideMultiSelectButtons=true
              customButtonStyle="bg-white dark:bg-jp-gray-darkgray_background !w-full"
              input
              options={gatewayOptions}
              fixedDropDownDirection=SelectBox.TopRight
              searchable=true
              defaultLeftIcon={FontAwesome("plus")}
              maxHeight="max-h-full sm:max-h-64"
            />
            <span className="text-lg text-red-500 ml-1"> {React.string("*")} </span>
          </div>
          {selectedOptions
          ->Array.mapWithIndex((item, i) => {
            let key = Int.toString(i + 1)

            {
              <div className="flex flex-row" key>
                <div
                  className="w-min flex flex-row items-center justify-around gap-2 h-10 rounded-md  border border-jp-gray-500 dark:border-jp-gray-960
               text-jp-gray-900  hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme
               dark:hover:text-opacity-75  text-opacity-50 hover:text-jp-gray-900 bg-gradient-to-b
               from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 
               dark:text-opacity-50 focus:outline-none px-1 ">
                  <NewThemeUtils.Badge number={i + 1} />
                  <div>
                    {gateWayName(
                      item.connector.merchant_connector_id,
                    ).connector_label->React.string}
                  </div>
                  <Icon
                    name="close"
                    size=10
                    className="mr-2 cursor-pointer "
                    onClick={ev => {
                      ev->ReactEvent.Mouse.stopPropagation
                      removeItem(i)
                    }}
                  />
                  <RenderIf condition={isDistribute && selectedOptions->Array.length > 0}>
                    {<>
                      <input
                        className="w-10 text-right outline-none bg-white dark:bg-jp-gray-970 px-1 border border-jp-gray-300 dark:border-jp-gray-850 rounded-md"
                        name=key
                        onChange={ev => {
                          let val = ReactEvent.Form.target(ev)["value"]
                          updatePercentage(item, val->Int.fromString->Option.getOr(0))
                        }}
                        value={item.split->Int.toString}
                        type_="text"
                        inputMode="text"
                      />
                      <div> {React.string("%")} </div>
                    </>}
                  </RenderIf>
                </div>
              </div>
            }
          })
          ->React.array}
        </div>
      </div>
    </div>
  } else {
    <GatewayView gateways=selectedOptions />
  }
}

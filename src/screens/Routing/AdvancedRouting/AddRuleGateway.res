external anyToEnum: 'a => RoutingTypes.connectorSelectionData = "%identity"

@react.component
let make = (~id, ~gatewayOptions, ~isFirst=false, ~isExpanded) => {
  let url = RescriptReactRouter.useUrl()
  let gateWaysInput = ReactFinalForm.useField(`${id}.connectorSelection.data`).input
  let gateWaysType = ReactFinalForm.useField(`${id}.connectorSelection.type`).input
  let isDistributeInput = ReactFinalForm.useField(`${id}.isDistribute`).input
  let isDistribute = isDistributeInput.value->LogicUtils.getBoolFromJson(false)

  let connectorType: ConnectorTypes.connectorTypeVariants = switch url->RoutingUtils.urlToVariantMapper {
  | PayoutRouting => ConnectorTypes.PayoutProcessor
  | _ => ConnectorTypes.PaymentProcessor
  }
  let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=connectorType)

  React.useEffect(() => {
    let typeString = if isDistribute {
      "volume_split"
    } else {
      "priority"
    }
    gateWaysType.onChange(typeString->Identity.anyTypeToReactEvent)
    None
  }, [isDistributeInput.value])

  let selectedOptions = React.useMemo(() => {
    gateWaysInput.value
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Belt.Array.keepMap(item => {
      Some(AdvancedRoutingUtils.connectorSelectionDataMapperFromJson(item))
    })
  }, [gateWaysInput])

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "gateways",
    onBlur: _ => (),
    onChange: ev => {
      let newSelectedOptions = ev->Identity.formReactEventToArrayOfString

      if newSelectedOptions->Array.length === 0 {
        gateWaysInput.onChange([]->Identity.anyTypeToReactEvent)
      } else {
        let gatewaysArr = newSelectedOptions->Array.map(item => {
          open RoutingTypes

          let sharePercent = isDistribute ? 100 / newSelectedOptions->Array.length : 100
          if isDistribute {
            {
              connector: {
                connector: (
                  connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                    item,
                    ~version=V1,
                  )
                ).connector_name,
                merchant_connector_id: item,
              },
              split: sharePercent,
            }->Identity.genericTypeToJson
          } else {
            {
              connector: (
                connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                  item,
                  ~version=V1,
                )
              ).connector_name,
              merchant_connector_id: item,
            }->Identity.genericTypeToJson
          }
        })
        gateWaysInput.onChange(gatewaysArr->Identity.anyTypeToReactEvent)
      }
    },
    onFocus: _ => (),
    value: selectedOptions
    ->Array.map(option =>
      AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData(
        option,
      ).merchant_connector_id->JSON.Encode.string
    )
    ->JSON.Encode.array,
    checked: true,
  }

  let onClickDistribute = newDistributeValue => {
    open RoutingTypes

    let sharePercent = newDistributeValue ? 100 / selectedOptions->Array.length : 100
    let gatewaysArr = selectedOptions->Array.mapWithIndex((item, i) => {
      let sharePercent = if i === selectedOptions->Array.length - 1 && newDistributeValue {
        100 - sharePercent * i
      } else {
        sharePercent
      }
      switch item {
      | PriorityObject(obj) =>
        {
          connector: {
            connector: (
              connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                obj.merchant_connector_id,
                ~version=V1,
              )
            ).connector_name,
            merchant_connector_id: obj.merchant_connector_id,
          },
          split: sharePercent,
        }->Identity.genericTypeToJson

      | VolumeObject(obj) => obj.connector->Identity.genericTypeToJson
      }
    })
    gateWaysInput.onChange(gatewaysArr->Identity.anyTypeToReactEvent)
  }

  let updatePercentage = (item: RoutingTypes.connectorSelectionData, value) => {
    open RoutingTypes
    let slectedConnector = switch item {
    | PriorityObject(obj) => obj.connector
    | VolumeObject(obj) =>
      AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData(
        VolumeObject(obj),
      ).merchant_connector_id
    }
    if value < 100 {
      let newList = selectedOptions->Array.map(option => {
        switch option {
        | PriorityObject(obj) => obj.connector->Identity.genericTypeToJson
        | VolumeObject(obj) =>
          {
            ...obj,
            split: slectedConnector ===
              AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData(
                VolumeObject(obj),
              ).merchant_connector_id
              ? value
              : obj.split,
          }->Identity.genericTypeToJson
        }
      })
      gateWaysInput.onChange(newList->Identity.anyTypeToReactEvent)
    }
  }

  let removeItem = index => {
    input.onChange(
      selectedOptions
      ->Array.map(i =>
        AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData(i).merchant_connector_id
      )
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
              buttonText="Add Processors"
              buttonType=Button.SecondaryFilled
              hideMultiSelectButtons=true
              customButtonStyle="!bg-white !w-full"
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
            <div key className="flex flex-row">
              <div
                className="w-min flex flex-row items-center justify-around gap-2 rounded-lg border border-jp-gray-500 dark:border-jp-gray-960 hover:text-opacity-100 dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 bg-gradient-to-b from-jp-gray-250 dark:text-opacity-50 focus:outline-none px-2 text-sm cursor-pointer">
                <NewThemeUtils.Badge number={i + 1} />
                <div>
                  {React.string(
                    (
                      connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                        (
                          item->AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData
                        ).merchant_connector_id,
                        ~version=V1,
                      )
                    ).connector_label,
                  )}
                </div>
                <RenderIf condition={isDistribute && selectedOptions->Array.length > 0}>
                  {<>
                    <input
                      className="w-10 text-right outline-none bg-white dark:bg-jp-gray-970 px-1 border border-jp-gray-300 dark:border-jp-gray-850 rounded-md"
                      name=key
                      onChange={ev => {
                        let val = ReactEvent.Form.target(ev)["value"]
                        updatePercentage(item, val->Int.fromString->Option.getOr(0))
                      }}
                      value={item
                      ->AdvancedRoutingUtils.getSplitFromConnectorSelectionData
                      ->Int.toString}
                      type_="text"
                      inputMode="text"
                    />
                    <div> {React.string("%")} </div>
                  </>}
                </RenderIf>
                <Icon
                  name="close"
                  size=10
                  className="mr-2 cursor-pointer "
                  onClick={ev => {
                    ev->ReactEvent.Mouse.stopPropagation
                    removeItem(i)
                  }}
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
        <RenderIf condition={selectedOptions->Array.length > 0}>
          <div
            className="flex flex-col md:flex-row md:items-center gap-4 md:gap-3 lg:gap-4 lg:ml-6">
            <div className={`flex flex-row items-center gap-4 md:gap-1 lg:gap-2`}>
              <CheckBoxIcon
                isSelected=isDistribute
                setIsSelected={v => {
                  isDistributeInput.onChange(v->Identity.anyTypeToReactEvent)
                  onClickDistribute(v)
                }}
                isDisabled=false
              />
              <div> {React.string("Distribute")} </div>
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
  } else {
    <RulePreviewer.GatewayView gateways={selectedOptions} />
  }
}

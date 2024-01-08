external anyToEnum: 'a => AdvancedRoutingTypes.connectorSelectionData = "%identity"

@react.component
let make = (~id, ~gatewayOptions, ~isFirst=false, ~isExpanded=false) => {
  let gateWaysInput = ReactFinalForm.useField(`${id}.connectorSelection.data`).input
  let gateWaysType = ReactFinalForm.useField(`${id}.connectorSelection.type`).input
  let isDistributeInput = ReactFinalForm.useField(`${id}.isDistribute`).input
  let isDistribute = isDistributeInput.value->LogicUtils.getBoolFromJson(false)
  let connectorListJson = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let connectorList = React.useMemo0(() => {
    connectorListJson->LogicUtils.safeParse->ConnectorTableUtils.getArrayOfConnectorListPayloadType
  })

  React.useEffect1(() => {
    let typeString = if isDistribute {
      "volume_split"
    } else {
      "priority"
    }
    gateWaysType.onChange(typeString->Identity.anyTypeToReactEvent)
    None
  }, [isDistributeInput.value])

  let selectedOptions = React.useMemo1(() => {
    gateWaysInput.value
    ->Js.Json.decodeArray
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(item => {
      Some(AdvancedRoutingUtils.connectorSelectionDataMapperFromJson(item))
    })
  }, [gateWaysInput])

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "gateways",
    onBlur: _ev => (),
    onChange: ev => {
      let newSelectedOptions = ev->Identity.formReactEventToArrayOfString

      if newSelectedOptions->Array.length === 0 {
        gateWaysInput.onChange([]->Identity.anyTypeToReactEvent)
      } else {
        let gatewaysArr = newSelectedOptions->Array.map(item => {
          open AdvancedRoutingTypes

          let sharePercent = isDistribute ? 100 / newSelectedOptions->Array.length : 100
          if isDistribute {
            {
              connector: {
                connector: (
                  connectorList->ConnectorTableUtils.getConnectorNameViaId(item)
                ).connector_name,
                merchant_connector_id: item,
              },
              split: sharePercent,
            }->Identity.genericTypeToJson
          } else {
            {
              connector: (
                connectorList->ConnectorTableUtils.getConnectorNameViaId(item)
              ).connector_name,
              merchant_connector_id: item,
            }->Identity.genericTypeToJson
          }
        })
        gateWaysInput.onChange(gatewaysArr->Identity.anyTypeToReactEvent)
      }
    },
    onFocus: _ev => (),
    value: selectedOptions
    ->Array.map(option =>
      AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData(
        option,
      ).merchant_connector_id->Js.Json.string
    )
    ->Js.Json.array,
    checked: true,
  }

  let onClickDistribute = newDistributeValue => {
    open AdvancedRoutingTypes

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
              connectorList->ConnectorTableUtils.getConnectorNameViaId(obj.merchant_connector_id)
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

  let updatePercentage = (item: AdvancedRoutingTypes.connectorSelectionData, value) => {
    open AdvancedRoutingTypes
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

  <div className="flex flex-row ml-2">
    <UIUtils.RenderIf condition={!isFirst}>
      <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
    </UIUtils.RenderIf>
    <div className="flex flex-col gap-6 mt-6 mb-4 pt-0.5">
      <div className="flex flex-wrap gap-4">
        <div className="flex">
          <SelectBox.BaseDropdown
            allowMultiSelect=true
            buttonText="Add Processors"
            buttonType=Button.SecondaryFilled
            hideMultiSelectButtons=true
            customButtonStyle="!bg-white "
            input
            options={gatewayOptions}
            fixedDropDownDirection=SelectBox.TopRight
            searchable=true
            defaultLeftIcon={FontAwesome("plus")}
          />
          <span className="text-lg text-red-500 ml-1"> {React.string("*")} </span>
        </div>
        {selectedOptions
        ->Array.mapWithIndex((item, i) => {
          let key = string_of_int(i + 1)
          <div key className="flex flex-row">
            <div
              className="w-min flex flex-row items-center justify-around gap-2 h-10 rounded-md  border border-jp-gray-500 dark:border-jp-gray-960
               text-jp-gray-900 text-opacity-75 hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme
               dark:hover:text-opacity-75 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 bg-gradient-to-b
               from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-jp-gray-text_darktheme
               dark:text-opacity-50 focus:outline-none px-1 ">
              <NewThemeUtils.Badge number={i + 1} />
              <div>
                {React.string(
                  (
                    connectorList->ConnectorTableUtils.getConnectorNameViaId(
                      (
                        item->AdvancedRoutingUtils.getConnectorStringFromConnectorSelectionData
                      ).merchant_connector_id,
                    )
                  ).connector_label,
                )}
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
              <UIUtils.RenderIf condition={isDistribute && selectedOptions->Array.length > 0}>
                {<>
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
                    value={item
                    ->AdvancedRoutingUtils.getSplitFromConnectorSelectionData
                    ->Belt.Int.toString}
                    type_="text"
                    inputMode="text"
                  />
                  <div> {React.string("%")} </div>
                </>}
              </UIUtils.RenderIf>
            </div>
          </div>
        })
        ->React.array}
      </div>
      <UIUtils.RenderIf condition={selectedOptions->Array.length > 0}>
        <div className="flex flex-col md:flex-row md:items-center gap-4 md:gap-3 lg:gap-4 lg:ml-6">
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
      </UIUtils.RenderIf>
    </div>
  </div>
}

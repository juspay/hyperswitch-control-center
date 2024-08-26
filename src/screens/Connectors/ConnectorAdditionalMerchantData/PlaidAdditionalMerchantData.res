@react.component
let make = (~connectorAdditionalMerchantData) => {
  open LogicUtils
  open ConnectorAdditionalMerchantDataUtils
  let keys = connectorAdditionalMerchantData->Dict.keysToArray
  let (dropValue, setDropValue) = React.useState(_ => "")
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "string",
    onBlur: _ => (),
    onChange: ev => {
      let val = ev->Identity.formReactEventToString
      setDropValue(_ => val)
    },
    onFocus: _ => (),
    value: dropValue->JSON.Encode.string,
    checked: true,
  }
  <>
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText="Select PM Authentication Processor"
      input
      options={["exa", "exf"]->SelectBox.makeOptions}
      hideMultiSelectButtons=false
      showSelectionAsChips=true
      customButtonStyle="w-full"
      fullLength=true
      // dropdownClassName={`${options->PaymentMethodConfigUtils.dropdownClassName}`}
    />
    {keys
    ->Array.mapWithIndex((field, index) => {
      switch JSON.Classify.classify(connectorAdditionalMerchantData->getJsonObjectFromDict(field)) {
      | Object(_) => {
          let fields =
            connectorAdditionalMerchantData
            ->getDictfromDict(field)
            ->JSON.Encode.object
            ->convertMapObjectToDict
            ->CommonDataUtils.inputFieldMapper
          <div key={index->Int.toString}>
            <FormRenderer.FieldRenderer
              labelClass="font-semibold !text-hyperswitch_black"
              field={connectorAdditionalMerchantDataValueInput(
                ~connectorAdditionalMerchantData={fields},
                ~onItemChange=(),
              )}
            />
          </div>
        }
      | Array(val) =>
        val
        ->Array.mapWithIndex((field, index) => {
          let fie =
            field
            ->convertMapObjectToDict
            ->CommonDataUtils.inputFieldMapper
          <div key={index->Int.toString}>
            <FormRenderer.FieldRenderer
              labelClass="font-semibold !text-hyperswitch_black"
              field={connectorAdditionalMerchantDataValueInput(
                ~connectorAdditionalMerchantData={fie},
                ~onItemChange=(),
              )}
            />
          </div>
        })
        ->React.array
      | Null => <> </>
      | Bool(_) => <> </>
      | String(_) => <> </>
      | Number(_) => <> </>
      }
    })
    ->React.array}
  </>
}

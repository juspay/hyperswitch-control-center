open CommonAuthForm
open CommonInputFields
open OrderTypes
@react.component
let make = (~options) => {
  let (selectedOption, setSelectedOption) = React.useState(_ => UnknownRange("Select Amount"))
  let form = ReactFinalForm.useForm()
  let onClick = _ => {
    form.submit()->ignore
  }
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => {
      let newValue = ev->Identity.formReactEventToString
      if newValue != selectedOption->mapRangeTypetoString && newValue != "" {
        setSelectedOption(_ => newValue->mapStringToRange)
        form.change("amount_filter.end_amount", JSON.Encode.null)
        form.change("amount_filter.start_amount", JSON.Encode.null)
      }
    },
    onFocus: _ => (),
    value: {
      selectedOption->mapRangeTypetoString->JSON.Encode.string
    },
    checked: true,
  }

  let renderCommonFields = (field, customwidth) =>
    <div className={`flex gap-5 items-center justify-center ${customwidth} ml-2`}>
      <Icon name="arrow-icon" size=20 className="mt-3" />
      <FormRenderer.FieldRenderer field={field} labelClass fieldWrapperClass />
    </div>

  let renderFields = () =>
    switch selectedOption {
    | GreaterThanEqualTo => renderCommonFields(startamountField, "w-4/5")
    | LessThanEqualTo => renderCommonFields(endAmountField, "w-4/5")
    | EqualTo => <CustomAmountField />
    | InBetween =>
      <div className="flex gap-1 items-center justify-center mx-1 w-10.25-rem">
        <FormRenderer.FieldRenderer field=startamountField labelClass fieldWrapperClass />
        <p className="mt-3 text-xs text-jp-gray-700"> {"and"->React.string} </p>
        <FormRenderer.FieldRenderer field=endAmountField labelClass fieldWrapperClass />
      </div>

    | _ => React.null
    }

  <>
    <FilterSelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText={selectedOption->mapRangeTypetoString}
      buttonType=Button.SecondaryFilled
      input
      options
      hideMultiSelectButtons=true
      showSelectionAsChips={false}
      fullLength=true
      customButtonStyle="bg-white rounded-md !px-4 !py-2 !h-10"
    />
    {<RenderIf condition={selectedOption != UnknownRange("Select Amount")}>
      <div
        className={"border border-jp-gray-940 border-opacity-50 bg-white rounded-md p-1.5 gap-2.5 "}>
        {renderFields()}
        <Button
          buttonType=Primary
          text="Apply"
          flattenTop=false
          customButtonStyle="w-full mt-4 items-center sticky bottom-0 !h-10"
          onClick
        />
      </div>
    </RenderIf>}
  </>
}

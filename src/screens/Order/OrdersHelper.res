open CommonAuthForm
open CommonInputFields
open OrderTypes
@react.component
let make = (~options) => {
  let (selectedOption, setSelectedOption) = React.useState(_ => UnknownRange("Select Amount"))
  let form = ReactFinalForm.useForm()
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => {
      let newValue = ev->Identity.formReactEventToString
      if newValue != selectedOption->mapRangeTypetoString && newValue->LogicUtils.isNonEmptyString {
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

  let renderCommonFields = field =>
    <div className={"flex gap-5 items-center justify-center w-28"}>
      <FormRenderer.FieldRenderer field={field} labelClass fieldWrapperClass />
    </div>

  let renderFields = () =>
    switch selectedOption {
    | GreaterThanEqualTo => renderCommonFields(startamountField)
    | LessThanEqualTo => renderCommonFields(endAmountField)
    | EqualTo => <CustomAmountEqualField />
    | InBetween => <CustomAmountBetweenField />
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
        className={"border border-jp-gray-940 border-opacity-50 bg-white rounded-md py-1.5 gap-2.5 flex justify-between px-2.5 pb-4 border-t-0"}>
        {renderFields()}
        <FormRenderer.SubmitButton
          customSumbitButtonStyle="!mt-4 items-center"
          text="Apply"
          userInteractionRequired=true
          showToolTip=true
          loadingText="Loading..."
        />
      </div>
    </RenderIf>}
  </>
}

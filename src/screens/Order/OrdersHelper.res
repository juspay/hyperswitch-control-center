open CommonAuthForm
open CommonInputFields
@react.component
let make = (~input, ~options) => {
  let (selectedOption, setSelectedOption) = React.useState(_ => "Select Amount")
  let form = ReactFinalForm.useForm()
  let onClick = _ => {
    form.submit()->ignore
  }
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => {
      let newValue = ev->Identity.formReactEventToString
      if newValue != selectedOption && newValue != "" {
        setSelectedOption(_ => newValue)
        form.change("amount_filter.end_amount", JSON.Encode.null)
        form.change("amount_filter.start_amount", JSON.Encode.null)
      }
    },
    onFocus: _ => (),
    value: {
      selectedOption->JSON.Encode.string
    },
    checked: true,
  }

  let renderCommonFields = (field, customwidth) =>
    <div className={`flex gap-5 items-center justify-center ${customwidth} ml-2`}>
      <img alt="cursor" src={`/assets/arrowicon.svg`} className="cursor-pointer mt-3" />
      <FormRenderer.FieldRenderer field={field} labelClass fieldWrapperClass />
    </div>

  let renderFields = () =>
    switch selectedOption {
    | "Greater than Equal to" => renderCommonFields(startamountField, "w-4/5")
    | "Equal to" => <CustomAmountField />
    | "Less than Equal to" => renderCommonFields(endAmountField, "w-4/5")
    | "In Between" =>
      <div className="flex gap-1 items-center justify-center mx-1 w-[10.25rem]">
        <FormRenderer.FieldRenderer field=startamountField labelClass fieldWrapperClass />
        <img alt="cursor" src={`/assets/inBetweenIcon.svg`} className="cursor-pointer mt-3" />
        <FormRenderer.FieldRenderer field=endAmountField labelClass fieldWrapperClass />
      </div>

    | _ => React.null
    }
  <>
    <FilterSelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText={selectedOption}
      buttonType=Button.SecondaryFilled
      input
      options
      hideMultiSelectButtons=true
      showSelectionAsChips={false}
      fullLength=true
      customButtonStyle="bg-white rounded-md !px-4 !py-2 !h-10"
    />
    {<RenderIf condition={selectedOption != "Select Amount"}>
      <div className={"bg-[#e5e7eb] bg-opacity-50 rounded-bl-md rounded-br-md p-1.5 gap-2.5 "}>
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

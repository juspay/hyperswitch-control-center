module CustomAmountEqualField = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <div className="flex gap-5 items-center justify-center w-28 ml-2">
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(~label="", ~name="start_amount", ~customInput=(
          ~input,
          ~placeholder as _,
        ) =>
          InputFields.numericTextInput(~precision=2)(
            ~input={
              ...input,
              onChange: {
                ev => {
                  form.change("end_amount", ev->Identity.genericTypeToJson)
                  input.onChange(ev)
                }
              },
            },
            ~placeholder="0",
          )
        )}
      />
    </div>
  }
}

module CustomAmountBetweenField = {
  open AmountFilterUtils
  @react.component
  let make = () => {
    <div className="flex gap-1 items-center justify-center mx-1 w-10.25-rem">
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(~label="", ~name="start_amount", ~customInput=(
          ~input,
          ~placeholder as _,
        ) =>
          InputFields.numericTextInput(~precision=2)(
            ~input={
              ...input,
              onChange: {
                ev => {
                  input.onChange(ev)
                }
              },
            },
            ~placeholder="0",
          )
        )}
      />
      <p className="mt-3 text-xs text-jp-gray-700"> {"and"->React.string} </p>
      <FormRenderer.FieldRenderer labelClass="font-semibold !text-black" field=endAmountField />
    </div>
  }
}

@react.component
let make = (~options) => {
  open AmountFilterUtils
  open LogicUtils

  let form = ReactFinalForm.useForm()
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let (selectedOption, setSelectedOption) = React.useState(_ => AmountFilterTypes.UnknownRange(
    "Select Amount",
  ))
  let (isAmountRangeVisible, setIsAmountRangeVisible) = React.useState(_ => true)

  let isApplyButtonDisabled = React.useMemo(() => {
    validateAmount(formState.values->getDictFromJsonObject)
  }, [formState.values])

  let handleInputChange = newValue => {
    if newValue->isNonEmptyString {
      let mappedRange = newValue->mapStringToRange

      form.change("start_amount", JSON.Encode.null)
      form.change("end_amount", JSON.Encode.null)
      form.change("amount_option", mappedRange->Identity.genericTypeToJson)

      setSelectedOption(_ => {newValue->mapStringToRange})
      setIsAmountRangeVisible(_ => true)
    } else {
      setIsAmountRangeVisible(_ => true)
    }
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => {
      handleInputChange(ev->Identity.formReactEventToString)
    },
    onFocus: _ => (),
    value: selectedOption->mapRangeTypetoString->JSON.Encode.string,
    checked: true,
  }

  let handleApply = _ => {
    form.submit()->ignore
    setIsAmountRangeVisible(_ => false)
  }

  let renderFields = () =>
    switch selectedOption {
    | GreaterThanOrEqualTo =>
      <div className="flex gap-5 items-center justify-center w-28">
        <FormRenderer.FieldRenderer field={startamountField} />
      </div>
    | LessThanOrEqualTo =>
      <div className="flex gap-5 items-center justify-center w-28">
        <FormRenderer.FieldRenderer field={endAmountField} />
      </div>
    | EqualTo => <CustomAmountEqualField />
    | InBetween => <CustomAmountBetweenField />
    | _ => React.null
    }

  React.useEffect(() => {
    let onKeyDown = ev => {
      let keyCode = ev->ReactEvent.Keyboard.keyCode
      if keyCode === 13 {
        handleApply()
      }
    }
    Window.addEventListener("keydown", onKeyDown)
    Some(() => Window.removeEventListener("keydown", onKeyDown))
  }, [])

  let displaySelectedRange = () => {
    let dict = formState.values->getDictFromJsonObject
    let start = dict->getOptionFloat("start_amount")
    let end = dict->getOptionFloat("end_amount")

    switch (selectedOption, start, end) {
    | (GreaterThanOrEqualTo, Some(start), _) => (true, `More or Equal to ${start->Float.toString}`)
    | (EqualTo, Some(start), _) => (true, `Exactly ${start->Float.toString}`)
    | (LessThanOrEqualTo, _, Some(end)) => (true, `Less or Equal to ${end->Float.toString}`)
    | (InBetween, Some(start), Some(end)) => (
        true,
        `In Between ${start->Float.toString} and ${end->Float.toString}`,
      )
    | _ => (false, selectedOption->mapRangeTypetoString)
    }
  }

  let (displayCustomCss, buttonText) = displaySelectedRange()

  <>
    <FilterSelectBox.BaseDropdown
      key={buttonText}
      allowMultiSelect=false
      buttonText={buttonText}
      textStyle={displayCustomCss ? "text-primary" : ""}
      buttonType=Button.SecondaryFilled
      input
      options
      hideMultiSelectButtons=true
      showSelectionAsChips=false
      fullLength=true
      customButtonStyle="bg-white rounded-md !px-4 !py-2 !h-10"
    />
    <RenderIf condition={selectedOption != UnknownRange("Select Amount") && isAmountRangeVisible}>
      <div
        className="border border-jp-gray-940 border-opacity-50 bg-white rounded-md py-1.5 gap-2.5 flex justify-between px-2.5 pb-4 border-t-0 items-center">
        {renderFields()}
        <Button
          buttonType=Primary
          text="Apply"
          customButtonStyle="!mt-4 items-center"
          buttonState={isApplyButtonDisabled ? Disabled : Normal}
          showBtnTextToolTip={isApplyButtonDisabled}
          showTooltip={isApplyButtonDisabled}
          tooltipText="Invalid Input"
          onClick=handleApply
        />
      </div>
    </RenderIf>
  </>
}

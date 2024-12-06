let startamountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="start_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(~precision=2),
  ~type_="number",
)

let endAmountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="end_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(~precision=2),
  ~type_="number",
)

module CustomAmountEqualField = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <div className={"flex gap-5 items-center justify-center w-28 ml-2"}>
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
  open OrderTypes
  open LogicUtils
  let (selectedOption, setSelectedOption) = React.useState(_ => UnknownRange("Select Amount"))
  let (isAmountRangeVisible, setIsAmountRangeVisible) = React.useState(_ => true)
  let form = ReactFinalForm.useForm()
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let isApplyButtonDisabled = React.useMemo(() => {
    HSwitchOrderUtils.validateAmount(formState.values->getDictFromJsonObject)
  }, [formState.values])

  let handleInputChange = newValue => {
    if newValue->isNonEmptyString {
      let mappedRange = newValue->mapStringToRange
      setIsAmountRangeVisible(_ => true)
      form.change("start_amount", JSON.Encode.null)
      form.change("end_amount", JSON.Encode.null)
      form.change("amount_option", mappedRange->Identity.genericTypeToJson)
      setSelectedOption(_ => {newValue->mapStringToRange})
    }
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => handleInputChange(ev->Identity.formReactEventToString),
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
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="start_amount",
            ~placeholder="0",
            ~customInput=InputFields.numericTextInput(~precision=2),
            ~type_="number",
          )}
        />
      </div>
    | LessThanOrEqualTo =>
      <div className="flex gap-5 items-center justify-center w-28">
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="end_amount",
            ~placeholder="0",
            ~customInput=InputFields.numericTextInput(~precision=2),
            ~type_="number",
          )}
        />
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
    let startValue = dict->getvalFromDict("start_amount")->getFloatFromJson(0.0)->Float.toString
    let endValue = dict->getvalFromDict("end_amount")->getFloatFromJson(0.0)->Float.toString
    switch (selectedOption, startValue, endValue) {
    | (GreaterThanOrEqualTo, start, _) if start != "0" => (true, `More or Equal to ${start}`)
    | (EqualTo, start, _) if start != "0" => (true, `Exactly ${start}`)
    | (LessThanOrEqualTo, _, end) if end != "0" => (true, `Less or Equal to ${end}`)
    | (InBetween, start, end) if end != "0" && start != "0" => (
        true,
        `In Between ${start} and ${end}`,
      )
    | _ => (false, selectedOption->mapRangeTypetoString)
    }
  }
  let (displayCustomCss, buttonText) = displaySelectedRange()
  <>
    <FilterSelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText={buttonText}
      textStyle={displayCustomCss ? "text-blue-500" : ""}
      buttonType=Button.SecondaryFilled
      input
      options
      hideMultiSelectButtons=true
      showSelectionAsChips=false
      fullLength=true
      customButtonStyle="bg-white rounded-md !px-4 !py-2 !h-10"
    />
    {<RenderIf condition={selectedOption != UnknownRange("Select Amount") && isAmountRangeVisible}>
      <div
        className="border border-jp-gray-940 border-opacity-50 bg-white rounded-md py-1.5 gap-2.5 flex justify-between px-2.5 pb-4 border-t-0">
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
    </RenderIf>}
  </>
}

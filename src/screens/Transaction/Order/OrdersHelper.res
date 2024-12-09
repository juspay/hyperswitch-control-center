let startamountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="start_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
  ~type_="number",
)

let endAmountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="end_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
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
          InputFields.numericTextInput()(
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
          InputFields.numericTextInput()(
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
  open CommonAuthForm
  let (selectedOption, setSelectedOption) = React.useState(_ => UnknownRange("Select Amount"))
  let form = ReactFinalForm.useForm()
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "amount",
    onBlur: _ => (),
    onChange: ev => {
      let newValue = ev->Identity.formReactEventToString
      form.change("start_amount", JSON.Encode.null)
      form.change("end_amount", JSON.Encode.null)
      setSelectedOption(_ => newValue->mapStringToRange)
    },
    onFocus: _ => (),
    value: {
      selectedOption->mapRangeTypetoString->JSON.Encode.string
    },
    checked: true,
  }
  React.useEffect(() => {
    let formDict = formState.values->getDictFromJsonObject
    if selectedOption == GreaterThanEqualTo {
      let _ = formDict->Dict.delete("end_amount")
    } else if selectedOption == LessThanEqualTo {
      let _ = formDict->Dict.delete("start_amount")
    }
    // remove the object reference
    let t = formDict->JSON.Encode.object->JSON.stringify->safeParse
    form.reset(t->Nullable.make)
    None
  }, [selectedOption])

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

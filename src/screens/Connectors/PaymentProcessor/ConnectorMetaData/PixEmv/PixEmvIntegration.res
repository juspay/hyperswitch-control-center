@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open PixEmvUtils
  open Typography

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let pixEmvFieldsArray = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let pixEmvInputFields =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("pix_emv", [])

        pixEmvInputFields
      } else {
        []
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        []
      }
    }
  }, [connector])

  let onSubmit = () => {
    let metadata =
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
    update(metadata)
    closeAccordionFn()
  }

  let onCancel = () => {
    onCloseClickCustomFun()
    closeAccordionFn()
  }
  let pixEmvFields =
    pixEmvFieldsArray
    ->Array.mapWithIndex((field, index) => {
      let pixEmvField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={`${pixEmvField.name}_${index->Int.toString}`}>
        <FormRenderer.FieldRenderer
          labelClass={`${body.sm.semibold} !text-hyperswitch_black`}
          field={pixEmvFieldInput(~pixEmvField, ~fill=textColor.primaryNormal)}
        />
      </div>
    })
    ->React.array

  <div className="flex flex-col gap-6 p-6">
    <div> {pixEmvFields} </div>
    <div className={`flex gap-2 justify-end`}>
      <Button
        text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} customButtonStyle="w-full"
      />
      <Button
        onClick={_ => onSubmit()}
        text="Continue"
        buttonType={Primary}
        customButtonStyle="w-full"
        buttonState={formState.values->PixEmvUtils.validatePixEmvFields}
      />
    </div>
  </div>
}

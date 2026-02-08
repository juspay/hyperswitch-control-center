@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open BoletoUtils

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let boletoFieldsArray = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let boletoInputFields =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("boleto", [])

        boletoInputFields
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
  let boletoFields =
    boletoFieldsArray
    ->Array.mapWithIndex((field, index) => {
      let boletoField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={`${boletoField.name}_${index->Int.toString}`}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={boletoValueInput(~boletoField, ~fill=textColor.primaryNormal)}
        />
      </div>
    })
    ->React.array

  <div className="flex flex-col gap-6 p-6">
    <div> {boletoFields} </div>
    <div className={`flex gap-2 justify-end`}>
      <Button
        text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} customButtonStyle="w-full"
      />
      <Button
        onClick={_ => onSubmit()}
        text="Continue"
        buttonType={Primary}
        customButtonStyle="w-full"
        buttonState={formState.values->BoletoUtils.validateBoletoFields}
      />
    </div>
  </div>
}

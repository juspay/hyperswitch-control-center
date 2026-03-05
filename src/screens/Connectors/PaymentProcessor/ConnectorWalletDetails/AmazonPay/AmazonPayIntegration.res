@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open AmazonPayIntegrationUtils

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let amazonPayFieldsArray = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let amazonPayInputFields =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("connector_wallets_details")
          ->getArrayFromDict("amazon_pay", [])

        amazonPayInputFields
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
    update()
    closeAccordionFn()
  }

  let onCancel = () => {
    onCloseClickCustomFun()
    closeAccordionFn()
  }
  let amazonPayFields =
    amazonPayFieldsArray
    ->Array.mapWithIndex((field, index) => {
      let amazonPayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={`${amazonPayField.name}_${index->Int.toString}`}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={amazonPayValueInput(~amazonPayField, ~fill=textColor.primaryNormal)}
        />
      </div>
    })
    ->React.array

  <div className="flex flex-col gap-6 p-6">
    <div> {amazonPayFields} </div>
    <div className={`flex gap-2 justify-end`}>
      <Button
        text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} customButtonStyle="w-full"
      />
      <Button
        onClick={_ => onSubmit()}
        text="Continue"
        buttonType={Primary}
        customButtonStyle="w-full"
        buttonState={formState.values->AmazonPayIntegrationUtils.validateAmazonPay}
      />
    </div>
  </div>
}

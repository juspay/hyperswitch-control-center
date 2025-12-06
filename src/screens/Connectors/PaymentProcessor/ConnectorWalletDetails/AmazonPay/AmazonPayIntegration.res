@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
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
    setShowWalletConfigurationModal(_ => false)
  }

  let onCancel = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }
  let amazonPayFields =
    amazonPayFieldsArray
    ->Array.mapWithIndex((field, index) => {
      let amazonPayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={amazonPayValueInput(~amazonPayField, ~fill=textColor.primaryNormal)}
        />
      </div>
    })
    ->React.array

  <div className="p-2">
    {amazonPayFields}
    <div className={`flex gap-2  justify-end m-2 p-6`}>
      <Button text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} />
      <Button
        onClick={_ => onSubmit()}
        text="Continue"
        buttonType={Primary}
        buttonState={formState.values->AmazonPayIntegrationUtils.validateAmazonPay}
      />
    </div>
  </div>
}

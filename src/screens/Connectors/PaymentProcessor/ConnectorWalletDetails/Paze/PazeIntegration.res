@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open PazeIntegrationUtils
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()
  let setPazeFormData = () => {
    let initialFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("connector_wallets_details")
      ->getDictfromDict("paze")

    form.change(
      "connector_wallets_details.paze",
      initialFormValue->pazePayRequest->Identity.genericTypeToJson,
    )
  }
  React.useEffect(() => {
    if connector->isNonEmptyString {
      setPazeFormData()
    }
    None
  }, [connector])
  let pazeFields = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let samsungPayInputFields =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("connector_wallets_details")
          ->getArrayFromDict("paze", [])

        samsungPayInputFields
      } else {
        []
      }
    } catch {
    | Exn.Error(_) => []
    }
  }, [connector])
  let onSubmit = _ => {
    update()
    setShowWalletConfigurationModal(_ => false)
  }

  let onCancel = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }
  let pazeInputFields =
    pazeFields
    ->Array.mapWithIndex((field, index) => {
      let pazeField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black" field={pazeValueInput(~pazeField)}
        />
      </div>
    })
    ->React.array
  <div className="p-2">
    {pazeInputFields}
    <div className={`flex gap-2  justify-end m-2 p-6`}>
      <Button text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} />
      <Button
        onClick={onSubmit}
        text="Continue"
        buttonType={Primary}
        buttonState={formState.values->validatePaze}
      />
    </div>
  </div>
}

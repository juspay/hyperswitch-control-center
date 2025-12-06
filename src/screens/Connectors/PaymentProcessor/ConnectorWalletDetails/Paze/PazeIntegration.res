@react.component
let make = (~connector, ~closeAccordionFn, ~update) => {
  open LogicUtils
  open PazeIntegrationUtils
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()
  let setPazeFormData = () => {
    let initalFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("connector_wallets_details")
      ->getDictfromDict("paze")

    form.change(
      "connector_wallets_details.paze",
      initalFormValue->pazePayRequest->Identity.genericTypeToJson,
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
    closeAccordionFn()
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
  <div className="flex flex-col gap-6 p-6">
    <div> {pazeInputFields} </div>
    <Button
      onClick={onSubmit}
      text="Continue"
      buttonType={Primary}
      buttonState={formState.values->validatePaze}
      customButtonStyle="w-full"
      buttonSize={Small}
    />
  </div>
}

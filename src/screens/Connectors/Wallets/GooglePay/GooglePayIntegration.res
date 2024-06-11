let textInput = (~googlePayField: GooglePayIntegrationTypes.inputField) => {
  let {placeholder, label, name, required} = googlePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~name=`${GooglePayUtils.googlePayNameMapper(name)}`,
    ~placeholder,
    ~customInput=InputFields.textInput(),
    ~isRequired=required,
    (),
  )
}

let selectInput = (~googlePayField: GooglePayIntegrationTypes.inputField) => {
  let {label, name, required, options} = googlePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~fullLength=true,
      ~customStyle="max-h-48",
      ~customButtonStyle="pr-3",
      ~options={options->SelectBox.makeOptions},
      ~buttonText="Select Value",
      (),
    ),
    (),
  )
}
let googlePayValueInput = (~googlePayField: GooglePayIntegrationTypes.inputField) => {
  let {\"type"} = googlePayField

  {
    switch \"type" {
    | Text => textInput(~googlePayField)
    | Select => selectInput(~googlePayField)
    | _ => textInput(~googlePayField)
    }
  }
}

@react.component
let make = (~connector) => {
  open LogicUtils
  open GooglePayUtils
  let googlePayFields = React.useMemo1(() => {
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("google_pay", [])

        dict
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
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()
  React.useEffect1(() => {
    let initialGooglePayDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("google_pay")

    let updated = googlePay(initialGooglePayDict, connector)

    form.change("metadata.google_pay", updated->Identity.genericTypeToJson)
    None
  }, [connector])
  <>
    {googlePayFields
    ->Array.mapWithIndex((field, index) => {
      let googlePayField = field->convertMapObjectToDict->inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={googlePayValueInput(~googlePayField)}
        />
      </div>
    })
    ->React.array}
  </>
}

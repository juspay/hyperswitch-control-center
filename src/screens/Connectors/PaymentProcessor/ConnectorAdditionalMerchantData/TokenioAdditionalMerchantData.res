module TokenioAdditionMerchantDataSelect = {
  @react.component
  let make = (
    ~setState,
    ~value="",
    ~options=[],
    ~buttonText="",
    ~label="",
    ~handler: option<ReactEvent.Form.t => unit>=?,
  ) => {
    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let val = ev->Identity.formReactEventToString
        switch handler {
        | Some(func) => func(ev)
        | None => ()
        }
        setState(_ => val)
      },
      onFocus: _ => (),
      value: value->JSON.Encode.string,
      checked: true,
    }
    <>
      <div>
        <h2
          className="font-semibold pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1">
          {label->React.string}
          <span className="text-red-950"> {"*"->React.string} </span>
        </h2>
      </div>
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText
        input
        options={options}
        hideMultiSelectButtons=false
        showSelectionAsChips=true
        customButtonStyle="w-full"
        fullLength=true
        dropdownCustomWidth="w-full"
        fixedDropDownDirection=TopLeft
      />
    </>
  }
}
@react.component
let make = (~connectorAdditionalMerchantData) => {
  open LogicUtils
  open ConnectorAdditionalMerchantDataUtils
  open TokenioAdditionalMerchantDataType
  let form = ReactFinalForm.useForm()
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initialAdditionalMerchantDataDict =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("additional_merchant_data")
  let initialOpenBankingData =
    initialAdditionalMerchantDataDict
    ->getDictfromDict((#open_banking_recipient_data: tokenioAdditionalFields :> string))
    ->Dict.keysToArray
    ->getValueFromArray(0, "")

  let initialAccountdata =
    initialAdditionalMerchantDataDict
    ->getDictfromDict((#open_banking_recipient_data: tokenioAdditionalFields :> string))
    ->getDictfromDict((#account_data: tokenioAdditionalFields :> string))
    ->Dict.keysToArray
    ->getValueFromArray(0, "")

  let (openBankingRecipientData, setOpenBankingRecipientData) = React.useState(_ =>
    initialOpenBankingData
  )
  let (accountData, setaccountData) = React.useState(_ => initialAccountdata)

  let keys = connectorAdditionalMerchantData->Dict.keysToArray

  let updateOpenBanking = _ => {
    form.change(
      "additional_merchant_data.open_banking_recipient_data",
      JSON.Encode.null->Identity.genericTypeToJson,
    )
    setaccountData(_ => "")
  }

  let updateAccountData = _ => {
    form.change(
      "additional_merchant_data.open_banking_recipient_data.account_data",
      JSON.Encode.null->Identity.genericTypeToJson,
    )
  }

  {
    keys
    ->Array.mapWithIndex((field, index) => {
      <div key={index->Int.toString}>
        {if field === (#open_banking_recipient_data: tokenioAdditionalFields :> string) {
          let fields =
            connectorAdditionalMerchantData
            ->getDictfromDict(field)
            ->JSON.Encode.object
            ->convertMapObjectToDict
            ->CommonConnectorUtils.inputFieldMapper
          <TokenioAdditionMerchantDataSelect
            setState=setOpenBankingRecipientData
            value=openBankingRecipientData
            options={fields.options->modifiedOptions}
            buttonText={`Select ${fields.label}`}
            label={fields.label}
            handler=updateOpenBanking
          />
        } else if (
          field === (#account_data: tokenioAdditionalFields :> string) &&
            openBankingRecipientData == (#account_data: tokenioAdditionalFields :> string)
        ) {
          let fields =
            connectorAdditionalMerchantData
            ->getDictfromDict(field)
            ->JSON.Encode.object
            ->convertMapObjectToDict
            ->CommonConnectorUtils.inputFieldMapper
          <TokenioAdditionMerchantDataSelect
            setState=setaccountData
            value=accountData
            options={fields.options->modifiedOptions}
            buttonText={`Select ${fields.label}`}
            label={fields.label}
            handler=updateAccountData
          />
        } else if (
          field === (#bacs: tokenioAdditionalFields :> string) &&
            accountData == (#bacs: tokenioAdditionalFields :> string)
        ) {
          let bacsKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#bacs: tokenioAdditionalFields :> string),
              [],
            )
          Js.log2("bascKeys", bacsKeys)
          bacsKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#bankgiro: tokenioAdditionalFields :> string) &&
            accountData == (#bankgiro: tokenioAdditionalFields :> string)
        ) {
          let bankgiroKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#bankgiro: tokenioAdditionalFields :> string),
              [],
            )
          bankgiroKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#elixir: tokenioAdditionalFields :> string) &&
            accountData == (#elixir: tokenioAdditionalFields :> string)
        ) {
          let elixirKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#elixir: tokenioAdditionalFields :> string),
              [],
            )
          elixirKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#faster_payments: tokenioAdditionalFields :> string) &&
            accountData == (#faster_payments: tokenioAdditionalFields :> string)
        ) {
          let fasterPaymentsKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#faster_payments: tokenioAdditionalFields :> string),
              [],
            )
          fasterPaymentsKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#iban: tokenioAdditionalFields :> string) &&
            accountData == (#iban: tokenioAdditionalFields :> string)
        ) {
          let ibanKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#iban: tokenioAdditionalFields :> string),
              [],
            )
          ibanKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#plusgiro: tokenioAdditionalFields :> string) &&
            accountData == (#plusgiro: tokenioAdditionalFields :> string)
        ) {
          let plusgiroKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#plusgiro: tokenioAdditionalFields :> string),
              [],
            )
          plusgiroKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#sepa: tokenioAdditionalFields :> string) &&
            accountData == (#sepa: tokenioAdditionalFields :> string)
        ) {
          let sepaKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#sepa: tokenioAdditionalFields :> string),
              [],
            )
          sepaKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else if (
          field === (#sepa_instant: tokenioAdditionalFields :> string) &&
            accountData == (#sepa_instant: tokenioAdditionalFields :> string)
        ) {
          let sepaInstantKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#sepa_instant: tokenioAdditionalFields :> string),
              [],
            )
          sepaInstantKeys
          ->Array.mapWithIndex((field, index) => {
            let fields =
              field
              ->convertMapObjectToDict
              ->CommonConnectorUtils.inputFieldMapper
            <div key={index->Int.toString}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={connectorAdditionalMerchantDataValueInput(
                  ~connectorAdditionalMerchantData={fields},
                )}
              />
            </div>
          })
          ->React.array
        } else {
          React.null
        }}
      </div>
    })
    ->React.array
  }
}

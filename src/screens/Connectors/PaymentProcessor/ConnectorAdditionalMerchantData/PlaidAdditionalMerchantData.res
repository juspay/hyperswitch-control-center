module PlaidAdditionMerchantDataSelect = {
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
  open PlaidAdditionalMerchantDataType
  let form = ReactFinalForm.useForm()
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initialValues =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("additional_merchant_data")
  let initialOpenBankingData =
    initialValues
    ->getDictfromDict((#open_banking_recipient_data: pliadAdditionalFields :> string))
    ->Dict.keysToArray
    ->getValueFromArray(0, "")

  let initialAccountdata =
    initialValues
    ->getDictfromDict((#open_banking_recipient_data: pliadAdditionalFields :> string))
    ->getDictfromDict((#account_data: pliadAdditionalFields :> string))
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
        {if field === (#open_banking_recipient_data: pliadAdditionalFields :> string) {
          let fields =
            connectorAdditionalMerchantData
            ->getDictfromDict(field)
            ->JSON.Encode.object
            ->convertMapObjectToDict
            ->CommonConnectorUtils.inputFieldMapper
          <PlaidAdditionMerchantDataSelect
            setState=setOpenBankingRecipientData
            value=openBankingRecipientData
            options={fields.options->modifiedOptions}
            buttonText={`Select ${fields.label}`}
            label={fields.label}
            handler=updateOpenBanking
          />
        } else if (
          field === (#account_data: pliadAdditionalFields :> string) &&
            openBankingRecipientData == (#account_data: pliadAdditionalFields :> string)
        ) {
          let fields =
            connectorAdditionalMerchantData
            ->getDictfromDict(field)
            ->JSON.Encode.object
            ->convertMapObjectToDict
            ->CommonConnectorUtils.inputFieldMapper
          <PlaidAdditionMerchantDataSelect
            setState=setaccountData
            value=accountData
            options={fields.options->modifiedOptions}
            buttonText={`Select ${fields.label}`}
            label={fields.label}
            handler=updateAccountData
          />
        } else if (
          field === (#iban: pliadAdditionalFields :> string) &&
            accountData == (#iban: pliadAdditionalFields :> string)
        ) {
          let ibanKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#iban: pliadAdditionalFields :> string),
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
          field === (#bacs: pliadAdditionalFields :> string) &&
            accountData == (#bacs: pliadAdditionalFields :> string)
        ) {
          let bacsKeys =
            connectorAdditionalMerchantData->getArrayFromDict(
              (#bacs: pliadAdditionalFields :> string),
              [],
            )
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
          field === (#connector_recipient_id: pliadAdditionalFields :> string) &&
            openBankingRecipientData === (#connector_recipient_id: pliadAdditionalFields :> string)
        ) {
          let connectorRecipientId =
            connectorAdditionalMerchantData->getDictfromDict(
              (#connector_recipient_id: pliadAdditionalFields :> string),
            )
          let fields =
            connectorRecipientId
            ->JSON.Encode.object
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
        } else if (
          field === (#wallet_id: pliadAdditionalFields :> string) &&
            openBankingRecipientData == (#wallet_id: pliadAdditionalFields :> string)
        ) {
          let walledId =
            connectorAdditionalMerchantData->getDictfromDict(
              (#wallet_id: pliadAdditionalFields :> string),
            )
          let fields =
            walledId
            ->JSON.Encode.object
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
        } else {
          React.null
        }}
      </div>
    })
    ->React.array
  }
}

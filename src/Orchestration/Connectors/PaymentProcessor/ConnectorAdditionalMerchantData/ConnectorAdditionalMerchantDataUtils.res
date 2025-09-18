let connectorAdditionalMerchantDataMapper = name => {
  switch name {
  | "iban" => `additional_merchant_data.open_banking_recipient_data.account_data.iban.iban`
  | "iban.name" => `additional_merchant_data.open_banking_recipient_data.account_data.${name}`
  | "sort_code" => `additional_merchant_data.open_banking_recipient_data.account_data.bacs.sort_code`
  | "account_number" => `additional_merchant_data.open_banking_recipient_data.account_data.bacs.account_number`
  | "bacs.name" => `additional_merchant_data.open_banking_recipient_data.account_data.${name}`
  | "wallet_id" => `additional_merchant_data.open_banking_recipient_data.wallet_id`
  | "connector_recipient_id" => `additional_merchant_data.open_banking_recipient_data.connector_recipient_id`

  | _ => `additional_merchant_data.${name}`
  }
}
let connectorAdditionalMerchantDataValueInput = (
  ~connectorAdditionalMerchantData: CommonConnectorTypes.inputField,
) => {
  open CommonConnectorHelper
  let {\"type", name} = connectorAdditionalMerchantData
  let formName = connectorAdditionalMerchantDataMapper(name)

  switch \"type" {
  | Text => textInput(~field={connectorAdditionalMerchantData}, ~formName)
  | Select => selectInput(~field={connectorAdditionalMerchantData}, ~formName)
  | Toggle => toggleInput(~field={connectorAdditionalMerchantData}, ~formName)
  | MultiSelect => multiSelectInput(~field={connectorAdditionalMerchantData}, ~formName)
  | _ => textInput(~field={connectorAdditionalMerchantData}, ~formName)
  }
}

let modifiedOptions = options => {
  // This change should be moved to wasm
  let dropDownOptions = options->Array.map((item): SelectBox.dropdownOption => {
    {
      label: switch item {
      | "account_data" => "Bank Scheme"
      | "iban" => "Sepa"
      | _ => item->LogicUtils.snakeToTitle
      },
      value: item,
    }
  })
  dropDownOptions
}

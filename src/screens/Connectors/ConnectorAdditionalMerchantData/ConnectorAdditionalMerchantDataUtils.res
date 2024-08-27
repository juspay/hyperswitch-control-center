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

  {
    switch (\"type", name) {
    | (Text, _) => textInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (Select, _) => selectInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (Toggle, _) => toggleInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (MultiSelect, _) => multiSelectInput(~field={connectorAdditionalMerchantData}, ~formName)
    | _ => textInput(~field={connectorAdditionalMerchantData}, ~formName)
    }
  }
}

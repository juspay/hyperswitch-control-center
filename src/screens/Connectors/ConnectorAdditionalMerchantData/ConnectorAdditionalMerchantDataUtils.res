let connectorAdditionalMerchantDataMapper = name => {
  switch name {
  | "account_data" => `additional_merchant_data.open_banking_recipient_data.${name}.bacs`
  //   | "iban" => `additional_merchant_data.open_banking_recipient_data.account_data.${name}`
  | "sort_code" => `additional_merchant_data.open_banking_recipient_data.account_data.bacs.sort_code`
  | "wallet_id" => `additional_merchant_data.open_banking_recipient_data.${name}`
  | "connector_recipient_id" => `additional_merchant_data.open_banking_recipient_data.${name}`

  | _ => `additional_merchant_data.${name}`
  }
}
let connectorAdditionalMerchantDataValueInput = (
  ~connectorAdditionalMerchantData: CommonDataTypes.inputField,
  ~onItemChange,
) => {
  open CommonDataHelper
  let {\"type", name} = connectorAdditionalMerchantData
  let formName = connectorAdditionalMerchantDataMapper(name)

  {
    switch (\"type", name) {
    // | (Select, "merchant_config_currency") => currencyField(~name=formName)
    | (Text, _) => textInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (Select, _) => selectInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (Toggle, _) => toggleInput(~field={connectorAdditionalMerchantData}, ~formName)
    | (MultiSelect, _) => multiSelectInput(~field={connectorAdditionalMerchantData}, ~formName)
    | _ => textInput(~field={connectorAdditionalMerchantData}, ~formName)
    }
  }
}

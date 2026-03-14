let vault_token_selector_list = [
  "card_number",
  "card_cvc",
  "card_expiry_year",
  "card_expiry_month",
  "network_token",
  "network_token_cryptogram",
  "network_token_expiry_month",
  "network_token_expiry_year",
]

let vaultTokenSelectorDropdownOptions = vault_token_selector_list->Array.map((
  item
): SelectBox.dropdownOption => {
  {
    label: item->LogicUtils.snakeToTitle,
    value: item,
  }
})

let vaultConnectorDropdownOptions = (
  vaultConnectorsList: array<ConnectorTypes.connectorPayloadCommonType>,
) =>
  vaultConnectorsList->Array.map((item): SelectBox.dropdownOption => {
    {
      label: `${item.connector_label} - ${item.id}`,
      value: item.id,
    }
  })

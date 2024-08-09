open LogicUtils
open BankDebitTypes

let dropdownOptions = (connectors: array<string>) => {
  connectors->Array.map((item): SelectBox.dropdownOption => {
    label: item,
    value: item,
  })
}

let itemToObjMapper = dict => {
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    connector_name: dict->getString("connector_name", ""),
    mca_id: dict->getString("mca_id", ""),
  }
}

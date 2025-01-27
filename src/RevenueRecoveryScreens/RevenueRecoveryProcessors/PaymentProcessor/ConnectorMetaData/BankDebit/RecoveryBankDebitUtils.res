open LogicUtils
open BankDebitTypes

let dropdownOptions = (connectors: array<string>) => {
  connectors->Array.map((item): SelectBox.dropdownOption => {
    label: item->snakeToTitle,
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

let validateSelectedPMAuth = (values, paymentMethodType) => {
  let existingPaymentMethodValues =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("pm_auth_config")
    ->getArrayFromDict("enabled_payment_methods", [])
    ->JSON.Encode.array
    ->getArrayDataFromJson(itemToObjMapper)

  let newPaymentMethodValues =
    existingPaymentMethodValues->Array.filter(item => item.payment_method_type == paymentMethodType)

  newPaymentMethodValues->Array.length > 0 ? Button.Normal : Button.Disabled
}

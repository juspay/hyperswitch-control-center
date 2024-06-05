open GooglePayIntegrationTypes
open LogicUtils
let allowedAuthMethod = ["PAN_ONLY", "CRYPTOGRAM_3DS"]
let allowedCardNetworks = ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"]
let allowedPaymentMethodparameters = {
  allowed_auth_methods: allowedAuthMethod,
  allowed_card_networks: allowedCardNetworks,
}
let test = dict => {
  switch dict->getOptionString("stripe_version") {
  | Some(_) => {gateway: "STRIPE", stripe_version: dict->getString("stripe_version", "")}
  | _ => {gateway: "STRIPE"}
  }
}
let tokenizationSpecificationParameters = dict => {
  let d = dict->test
  d
}
let merchantInfo = dict => {
  merchant_id: dict->getOptionString("merchant_id"),
  merchant_name: dict->getOptionString("merchant_name"),
}
let tokenizationSpecification = dict => {
  \"type": "PAYMENT_GATEWAY",
  parameters: dict->tokenizationSpecificationParameters,
}

let allowedPaymentMethod = dict => {
  \"type": "CARD",
  parameters: allowedPaymentMethodparameters,
  tokenization_specification: dict->tokenizationSpecification,
}

let googlePay = dict => {
  merchant_info: dict->merchantInfo,
  allowed_payment_methods: [dict->allowedPaymentMethod],
}

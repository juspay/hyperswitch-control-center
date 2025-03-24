open VaultPaymentMethodDetailsTypes
open LogicUtils

let cardDetailsMapper = dict => {
  issuer_country: dict->getString("issuer_country", ""),
  last4_digits: dict->getString("last4_digits", ""),
  expiry_month: dict->getString("expiry_month", ""),
  expiry_year: dict->getString("expiry_year", ""),
  card_holder_name: dict->getString("card_holder_name", ""),
  card_fingerprint: dict->getString("card_fingerprint", ""),
  nick_name: dict->getString("nick_name", ""),
  card_network: dict->getString("card_network", ""),
  card_isin: dict->getString("card_isin", ""),
  card_issuer: dict->getString("card_issuer", ""),
  card_type: dict->getString("card_type", ""),
  saved_to_locker: dict->getBool("saved_to_locker", false),
}

let paymentMethodDataMapper = dict => {
  card: dict->getJsonObjectFromDict("card"),
}

let networkTokensData = dict => {
  token: dict->getString("token", ""),
  card_network: dict->getString("card_network", ""),
}

let connectorTokensMapper = dict => {
  connector_id: dict->getString("connector_id", ""),
  connector: dict->getString("connector", "NA"),
  token_type: dict->getString("token_type", ""),
  status: dict->getString("status", ""),
  connector_token_request_reference_id: dict->getString("connector_token_request_reference_id", ""),
  original_payment_authorized_amount: dict->getInt("original_payment_authorized_amount", 0),
  original_payment_authorized_currency: dict->getString("original_payment_authorized_currency", ""),
  metadata: dict->getDictfromDict("metadata"),
  token: dict->getString("token", ""),
}

let itemToObjMapper: JSON.t => paymentMethodDetails = json => {
  let dict = json->getDictFromJsonObject
  {
    id: dict->getString("id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    customer_id: dict->getOptionString("customer_id"),
    payment_method_subtype: dict->getOptionString("payment_method_subtype"),
    payment_method_type: dict->getOptionString("payment_method_type"),
    recurring_enabled: dict->getBool("recurring_enabled", false),
    created: dict->getString("created", ""),
    last_used_at: dict->getString("last_used_at", ""),
    payment_method_data: dict
    ->getDictfromDict("payment_method_data")
    ->paymentMethodDataMapper,
    connector_tokens: dict
    ->getJsonObjectFromDict("connector_tokens")
    ->getArrayDataFromJson(connectorTokensMapper),
    network_tokens: dict->getJsonObjectFromDict("network_tokens"),
  }
}

let getArrayOfPaymentMethodListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->itemToObjMapper
  })
}

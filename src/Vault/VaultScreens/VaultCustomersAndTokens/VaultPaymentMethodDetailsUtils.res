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

let pspTokensizationMapper = dict => {
  {
    psp_token: dict
    ->getArrayFromDict("psp_token", [])
    ->JSON.Encode.array
    ->getArrayDataFromJson(VaultPSPTokensEntity.itemToObjMapper),
  }
}

let networkTokenizationMappper = dict => {
  network_token: dict
  ->getArrayFromDict("network_token", [])
  ->JSON.Encode.array
  ->getArrayDataFromJson(VaultNetworkTokensEntity.itemToObjMapper),
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
    card: dict->getDictfromDict("payment_method_data")->getDictfromDict("card")->cardDetailsMapper,
    card_tokens: dict->getDictfromDict("connector_tokens"),
  }
}

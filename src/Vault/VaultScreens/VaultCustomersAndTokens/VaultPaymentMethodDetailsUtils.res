open VaultPaymentMethodDetailsTypes
open LogicUtils

let pspTokensizationMapper = dict => {
  psp_token: dict->JSON.Encode.object->getArrayDataFromJson(VaultPSPTokensEntity.itemToObjMapper),
}

let networkTokenizationMappper = dict => {
  network_token: dict
  ->JSON.Encode.object
  ->getArrayDataFromJson(VaultNetworkTokensEntity.itemToObjMapper),
}

let itemToObjMapper: JSON.t => paymentMethodDetails = json => {
  let dict = json->getDictFromJsonObject
  {
    merchant: dict->getString("merchant", ""),
    customer_id: dict->getOptionString("customer_id"),
    payment_method_id: dict->getString("payment_method_id", ""),
    payment_method_type: dict->getOptionString("payment_method_type"),
    payment_method: dict->getString("payment_method", ""),
    card: {
      card_holder_name: dict->getString("card_holder_name", ""),
      card_type: dict->getString("card_type", ""),
      card_network: dict->getString("card_network", ""),
      last_four_digits: dict->getString("last_four_digits", ""),
      card_expiry_month: dict->getString("card_expiry_month", ""),
      card_expiry_year: dict->getString("card_expiry_year", ""),
      card_issuer: dict->getString("card_issuer", ""),
      card_issuing_country: dict->getString("card_issuing_country", ""),
      card_is_in: dict->getString("card_is_in", ""),
      card_extended_bin: dict->getString("card_extended_bin", ""),
      payment_checks: dict->getString("payment_checks", ""),
      authentication_data: dict->getString("authentication_data", ""),
    },
    recurring_enabled: dict->getBool("recurring_enabled", false),
    tokenization_type: dict->getDictfromDict("tokenization_type")->JSON.Encode.object,
    psp_tokensization: dict->getDictfromDict("psp_tokensization")->pspTokensizationMapper,
    network_tokensization: dict
    ->getDictfromDict("network_tokensization")
    ->networkTokenizationMappper,
    created: dict->getString("created", ""),
    last_used_at: dict->getString("last_used_at", ""),
    network_transaction_id: dict->getString("network_transaction_id", ""),
  }
}

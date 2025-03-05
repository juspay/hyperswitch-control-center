open HSwitchSettingTypes

let constructWebhookDetailsObject = webhookDetailsDict => {
  open LogicUtils
  let webhookDetails = {
    webhook_version: webhookDetailsDict->getOptionString("webhook_version"),
    webhook_username: webhookDetailsDict->getOptionString("webhook_username"),
    webhook_password: webhookDetailsDict->getOptionString("webhook_password"),
    webhook_url: webhookDetailsDict->getOptionString("webhook_url"),
    payment_created_enabled: webhookDetailsDict->getOptionBool("payment_created_enabled"),
    payment_succeeded_enabled: webhookDetailsDict->getOptionBool("payment_succeeded_enabled"),
    payment_failed_enabled: webhookDetailsDict->getOptionBool("payment_failed_enabled"),
  }
  webhookDetails
}
let constructCardGuardDetailsObject = cardDetailsDict => {
  open LogicUtils
  let cardGuardDetails = {
    card_ip_blocking_status: cardDetailsDict->getOptionString("card_ip_blocking_status"),
    card_ip_blocking_threshold: cardDetailsDict->getOptionInt("card_ip_blocking_threshold"),
    guest_user_card_blocking_status: cardDetailsDict->getOptionString(
      "guest_user_card_blocking_status",
    ),
    guest_user_card_blocking_threshold: cardDetailsDict->getOptionInt(
      "guest_user_card_blocking_threshold",
    ),
    customer_id_blocking_status: cardDetailsDict->getOptionString("customer_id_blocking_status"),
    customer_id_blocking_threshold: cardDetailsDict->getOptionInt("customer_id_blocking_threshold"),
    card_testing_guard_expiry: cardDetailsDict->getOptionInt("card_testing_guard_expiry"),
  }
  cardGuardDetails
}
let constructAuthConnectorObject = authConnectorDict => {
  open LogicUtils
  let authConnectorDetails = {
    authentication_connectors: authConnectorDict->getOptionalArrayFromDict(
      "authentication_connectors",
    ),
    three_ds_requestor_url: authConnectorDict->getOptionString("three_ds_requestor_url"),
  }
  authConnectorDetails
}

let businessProfileTypeMapper = values => {
  open LogicUtils
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")

  {
    merchant_id: jsonDict->getString("merchant_id", ""),
    profile_id: jsonDict->getString("profile_id", ""),
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
    authentication_connector_details: authenticationConnectorDetails->constructAuthConnectorObject,
    collect_shipping_details_from_wallet_connector: jsonDict->getOptionBool(
      "collect_shipping_details_from_wallet_connector",
    ),
    always_collect_shipping_details_from_wallet_connector: jsonDict->getOptionBool(
      "always_collect_shipping_details_from_wallet_connector",
    ),
    collect_billing_details_from_wallet_connector: jsonDict->getOptionBool(
      "collect_billing_details_from_wallet_connector",
    ),
    always_collect_billing_details_from_wallet_connector: jsonDict->getOptionBool(
      "always_collect_billing_details_from_wallet_connector",
    ),
    is_connector_agnostic_mit_enabled: jsonDict->getOptionBool("is_connector_agnostic_mit_enabled"),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookHeades->isEmptyDict)
      ? Some(outgoingWebhookHeades)
      : None,
    metadata: metadataKeyValue->isEmptyDict ? None : Some(metadataKeyValue),
    is_auto_retries_enabled: jsonDict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: jsonDict->getOptionInt("max_auto_retries_enabled"),
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    authentication_product_ids: Some(
      jsonDict
      ->getDictfromDict("authentication_product_ids")
      ->JSON.Encode.object,
    ),
    card_testing_guard_config: jsonDict
    ->getDictfromDict("card_testing_guard_config")
    ->constructCardGuardDetailsObject,
  }
}

let convertObjectToType = value => {
  value->Array.map(businessProfileTypeMapper)
}

let getArrayOfBusinessProfile = businessProfileValue => {
  open LogicUtils
  businessProfileValue->getArrayFromJson([])->convertObjectToType
}

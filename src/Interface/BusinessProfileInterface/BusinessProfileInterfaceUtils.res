open HSwitchSettingTypes
open LogicUtils
open BusinessProfileMapper

let mapJsonToBusinessProfileV1 = (values): profileEntity => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  let paymentLinkConfig = jsonDict->getDictfromDict("payment_link_config")

  {
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
    force_3ds_challenge: jsonDict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookHeades->isEmptyDict)
      ? Some(outgoingWebhookHeades)
      : None,
    metadata: metadataKeyValue->isEmptyDict ? None : Some(metadataKeyValue),
    is_auto_retries_enabled: jsonDict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: jsonDict->getOptionInt("max_auto_retries_enabled"),
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    acquirer_configs: jsonDict->getOptionalArrayFromDict("acquirer_configs"),
    authentication_product_ids: Some(
      jsonDict
      ->getDictfromDict("authentication_product_ids")
      ->JSON.Encode.object,
    ),
    merchant_category_code: jsonDict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: jsonDict->getOptionBool("is_network_tokenization_enabled"),
    always_request_extended_authorization: jsonDict->getOptionBool(
      "always_request_extended_authorization",
    ),
    is_manual_retry_enabled: jsonDict->getOptionBool("is_manual_retry_enabled"),
    always_enable_overcapture: jsonDict->getOptionBool("always_enable_overcapture"),
    payment_link_config: paymentLinkConfig->isEmptyDict
      ? None
      : Some(paymentLinkConfig->paymentLinkConfigMapper),
  }
}
let mapJsonToBusinessProfileV2 = (values): profileEntity => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  let paymentLinkConfig = jsonDict->getDictfromDict("payment_link_config")

  {
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
    force_3ds_challenge: jsonDict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookHeades->isEmptyDict)
      ? Some(outgoingWebhookHeades)
      : None,
    metadata: metadataKeyValue->isEmptyDict ? None : Some(metadataKeyValue),
    is_auto_retries_enabled: jsonDict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: jsonDict->getOptionInt("max_auto_retries_enabled"),
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    acquirer_configs: jsonDict->getOptionalArrayFromDict("acquirer_configs"),
    authentication_product_ids: Some(
      jsonDict
      ->getDictfromDict("authentication_product_ids")
      ->JSON.Encode.object,
    ),
    merchant_category_code: jsonDict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: jsonDict->getOptionBool("is_network_tokenization_enabled"),
    always_request_extended_authorization: jsonDict->getOptionBool(
      "always_request_extended_authorization",
    ),
    is_manual_retry_enabled: jsonDict->getOptionBool("is_manual_retry_enabled"),
    always_enable_overcapture: jsonDict->getOptionBool("always_enable_overcapture"),
    payment_link_config: paymentLinkConfig->isEmptyDict
      ? None
      : Some(paymentLinkConfig->paymentLinkConfigMapper),
  }
}

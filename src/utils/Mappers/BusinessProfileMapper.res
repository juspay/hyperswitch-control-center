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
let constructAuthConnectorObject = authConnectorDict => {
  open LogicUtils
  let authConnectorDetails = {
    authentication_connectors: authConnectorDict->getOptionalArrayFromDict(
      "authentication_connectors",
    ),
    three_ds_requestor_url: authConnectorDict->getOptionString("three_ds_requestor_url"),
    three_ds_requestor_app_url: authConnectorDict->getOptionString("three_ds_requestor_app_url"),
  }
  authConnectorDetails
}

let paymentLinkConfigMapper = paymentLinkConfigDict => {
  open LogicUtils
  {
    theme: paymentLinkConfigDict->getString("theme", ""),
    logo: paymentLinkConfigDict->getString("logo", ""),
    seller_name: paymentLinkConfigDict->getString("seller_name", ""),
    sdk_layout: paymentLinkConfigDict->getString("sdk_layout", ""),
    display_sdk_only: paymentLinkConfigDict->getBool("display_sdk_only", false),
    enabled_saved_payment_method: paymentLinkConfigDict->getBool(
      "enabled_saved_payment_method",
      false,
    ),
    hide_card_nickname_field: paymentLinkConfigDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: paymentLinkConfigDict->getBool("show_card_form_by_default", false),
    payment_button_text: paymentLinkConfigDict->getString("payment_button_text", ""),
    sdk_ui_rules: paymentLinkConfigDict->getJsonObjectFromDict("sdk_ui_rules"),
    allowed_domains: paymentLinkConfigDict->getStrArrayFromDict("allowed_domains", []),
    payment_link_ui_rules: paymentLinkConfigDict->getJsonObjectFromDict("payment_link_ui_rules"),
    business_specific_configs: paymentLinkConfigDict->getJsonObjectFromDict(
      "business_specific_configs",
    ),
    domain_name: paymentLinkConfigDict->getString("domain_name", ""),
    branding_visibility: paymentLinkConfigDict->getBool("branding_visibility", false),
  }
}

let businessProfileTypeMapper = values => {
  open LogicUtils
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  let paymentLinkConfig = jsonDict->getDictfromDict("payment_link_config")

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
    force_3ds_challenge: jsonDict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
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
    acquirer_configs: jsonDict->getOptionalArrayFromDict("acquirer_configs"),
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

let convertObjectToType = value => {
  value->Array.map(businessProfileTypeMapper)
}

let getArrayOfBusinessProfile = businessProfileValue => {
  open LogicUtils
  businessProfileValue->getArrayFromJson([])->convertObjectToType
}

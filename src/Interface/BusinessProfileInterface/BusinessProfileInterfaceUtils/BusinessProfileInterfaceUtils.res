open LogicUtils
open BusinessProfileInterfaceTypes

let constructWebhookDetailsObject = webhookDetailsDict => {
  webhook_version: webhookDetailsDict->getOptionString("webhook_version"),
  webhook_username: webhookDetailsDict->getOptionString("webhook_username"),
  webhook_password: webhookDetailsDict->getOptionString("webhook_password"),
  webhook_url: webhookDetailsDict->getOptionString("webhook_url"),
  payment_created_enabled: webhookDetailsDict->getOptionBool("payment_created_enabled"),
  payment_succeeded_enabled: webhookDetailsDict->getOptionBool("payment_succeeded_enabled"),
  payment_failed_enabled: webhookDetailsDict->getOptionBool("payment_failed_enabled"),
}

let constructAuthConnectorObject = authConnectorDict => {
  authentication_connectors: authConnectorDict->getOptionalArrayFromDict(
    "authentication_connectors",
  ),
  three_ds_requestor_url: authConnectorDict->getOptionString("three_ds_requestor_url"),
  three_ds_requestor_app_url: authConnectorDict->getOptionString("three_ds_requestor_app_url"),
}

let convertOptionalBoolToOptionalJson = optBool => {
  let jsonVal = switch optBool {
  | Some(value) => value->JSON.Encode.bool
  | None => JSON.Encode.null
  }
  Some(jsonVal)
}

let convertOptionalStringToOptionalJson = optString => {
  let jsonVal = switch optString {
  | Some(value) => value->JSON.Encode.string
  | None => JSON.Encode.null
  }
  Some(jsonVal)
}

let convertOptionalIntToOptionalJson = optInt => {
  let jsonVal = switch optInt {
  | Some(value) => value->JSON.Encode.int
  | None => JSON.Encode.null
  }
  Some(jsonVal)
}

let convertDictToOptionalJson = dict => {
  !(dict->isEmptyDict) ? Some(dict->JSON.Encode.object) : Some(JSON.Encode.null)
}

let getBackgroundImage = backgroundImageDict => {
  {
    url: backgroundImageDict->getString("url", ""),
    position: backgroundImageDict->getString("position", ""),
    size: backgroundImageDict->getString("size", ""),
  }
}

let styleConfigMapper = paymentLinkConfigDict => {
  let backgroundImageDict = paymentLinkConfigDict->getDictfromDict("background_image")

  {
    theme: paymentLinkConfigDict->getOptionString("theme"),
    logo: paymentLinkConfigDict->getOptionString("logo"),
    seller_name: paymentLinkConfigDict->getOptionString("seller_name"),
    sdk_layout: paymentLinkConfigDict->getOptionString("sdk_layout"),
    display_sdk_only: paymentLinkConfigDict->getOptionBool("display_sdk_only"),
    enabled_saved_payment_method: paymentLinkConfigDict->getOptionBool(
      "enabled_saved_payment_method",
    ),
    hide_card_nickname_field: paymentLinkConfigDict->getOptionBool("hide_card_nickname_field"),
    show_card_form_by_default: paymentLinkConfigDict->getOptionBool("show_card_form_by_default"),
    transaction_details: paymentLinkConfigDict->Dict.get("transaction_details"),
    background_image: backgroundImageDict->isEmptyDict
      ? None
      : Some(backgroundImageDict->getBackgroundImage),
    details_layout: paymentLinkConfigDict->getOptionString("details_layout"),
    payment_button_text: paymentLinkConfigDict->getOptionString("payment_button_text"),
    custom_message_for_card_terms: paymentLinkConfigDict->getOptionString(
      "custom_message_for_card_terms",
    ),
    payment_button_colour: paymentLinkConfigDict->getOptionString("payment_button_colour"),
    skip_status_screen: paymentLinkConfigDict->getOptionBool("skip_status_screen"),
    payment_button_text_colour: paymentLinkConfigDict->getOptionString(
      "payment_button_text_colour",
    ),
    background_colour: paymentLinkConfigDict->getOptionString("background_colour"),
    sdk_ui_rules: paymentLinkConfigDict->Dict.get("sdk_ui_rules"),
    payment_link_ui_rules: paymentLinkConfigDict->Dict.get("payment_link_ui_rules"),
    enable_button_only_on_form_ready: paymentLinkConfigDict->getOptionBool(
      "enable_button_only_on_form_ready",
    ),
    payment_form_header_text: paymentLinkConfigDict->getOptionString("payment_form_header_text"),
    payment_form_label_type: paymentLinkConfigDict->getOptionString("payment_form_label_type"),
    show_card_terms: paymentLinkConfigDict->getOptionString("show_card_terms"),
    is_setup_mandate_flow: paymentLinkConfigDict->getOptionBool("is_setup_mandate_flow"),
    color_icon_card_cvc_error: paymentLinkConfigDict->getOptionString("color_icon_card_cvc_error"),
  }
}

let paymentLinkConfigMapper = paymentLinkConfigDict => {
  let backgroundImageDict = paymentLinkConfigDict->getDictfromDict("background_image")

  {
    theme: paymentLinkConfigDict->getOptionString("theme"),
    logo: paymentLinkConfigDict->getOptionString("logo"),
    seller_name: paymentLinkConfigDict->getOptionString("seller_name"),
    sdk_layout: paymentLinkConfigDict->getOptionString("sdk_layout"),
    display_sdk_only: paymentLinkConfigDict->getOptionBool("display_sdk_only"),
    enabled_saved_payment_method: paymentLinkConfigDict->getOptionBool(
      "enabled_saved_payment_method",
    ),
    hide_card_nickname_field: paymentLinkConfigDict->getOptionBool("hide_card_nickname_field"),
    show_card_form_by_default: paymentLinkConfigDict->getOptionBool("show_card_form_by_default"),
    transaction_details: paymentLinkConfigDict->Dict.get("transaction_details"),
    background_image: backgroundImageDict->isEmptyDict
      ? None
      : Some(backgroundImageDict->getBackgroundImage),
    details_layout: paymentLinkConfigDict->getOptionString("details_layout"),
    payment_button_text: paymentLinkConfigDict->getOptionString("payment_button_text"),
    custom_message_for_card_terms: paymentLinkConfigDict->getOptionString(
      "custom_message_for_card_terms",
    ),
    payment_button_colour: paymentLinkConfigDict->getOptionString("payment_button_colour"),
    skip_status_screen: paymentLinkConfigDict->getOptionBool("skip_status_screen"),
    payment_button_text_colour: paymentLinkConfigDict->getOptionString(
      "payment_button_text_colour",
    ),
    background_colour: paymentLinkConfigDict->getOptionString("background_colour"),
    sdk_ui_rules: paymentLinkConfigDict->Dict.get("sdk_ui_rules"),
    payment_link_ui_rules: paymentLinkConfigDict->Dict.get("payment_link_ui_rules"),
    enable_button_only_on_form_ready: paymentLinkConfigDict->getOptionBool(
      "enable_button_only_on_form_ready",
    ),
    payment_form_header_text: paymentLinkConfigDict->getOptionString("payment_form_header_text"),
    payment_form_label_type: paymentLinkConfigDict->getOptionString("payment_form_label_type"),
    show_card_terms: paymentLinkConfigDict->getOptionString("show_card_terms"),
    is_setup_mandate_flow: paymentLinkConfigDict->getOptionBool("is_setup_mandate_flow"),
    color_icon_card_cvc_error: paymentLinkConfigDict->getOptionString("color_icon_card_cvc_error"),
    branding_visibility: paymentLinkConfigDict->getOptionBool("branding_visibility"),
    domain_name: paymentLinkConfigDict->getOptionString("domain_name"),
    allowed_domains: paymentLinkConfigDict->Dict.get("allowed_domains"),
    business_specific_configs: paymentLinkConfigDict->Dict.get("business_specific_configs"),
  }
}

let mapJsontoCommonType: JSON.t => commonProfileEntity = input => {
  let jsonDict = input->getDictFromJsonObject
  let authConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookdict = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  let paymentLinkConfig = jsonDict->getDictfromDict("payment_link_config")
  {
    profile_id: jsonDict->getString("profile_id", ""),
    merchant_id: jsonDict->getString("merchant_id", ""),
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: jsonDict->getDictfromDict("webhook_details")->constructWebhookDetailsObject,
    authentication_connector_details: !(authConnectorDetails->isEmptyDict)
      ? Some(authConnectorDetails->constructAuthConnectorObject)
      : None,
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
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    authentication_product_ids: Some(jsonDict->getJsonObjectFromDict("authentication_product_ids")),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookdict->isEmptyDict)
      ? Some(outgoingWebhookdict)
      : None,
    is_auto_retries_enabled: jsonDict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: jsonDict->getOptionInt("max_auto_retries_enabled"),
    metadata: !(metadataKeyValue->isEmptyDict) ? Some(metadataKeyValue) : None,
    force_3ds_challenge: jsonDict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
    acquirer_configs: jsonDict->getOptionalArrayFromDict("acquirer_configs"),
    merchant_category_code: jsonDict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: jsonDict->getOptionBool("is_network_tokenization_enabled"),
    always_request_extended_authorization: jsonDict->getOptionBool(
      "always_request_extended_authorization",
    ),
    always_enable_overcapture: jsonDict->getOptionBool("always_enable_overcapture"),
    is_manual_retry_enabled: jsonDict->getOptionBool("is_manual_retry_enabled"),
    collect_shipping_details_from_wallet_connector_if_required: jsonDict->getOptionBool(
      "collect_shipping_details_from_wallet_connector_if_required",
    ),
    collect_billing_details_from_wallet_connector_if_required: jsonDict->getOptionBool(
      "collect_billing_details_from_wallet_connector_if_required",
    ),
    billing_processor_id: jsonDict->getOptionString("billing_processor_id"),
    payment_link_config: paymentLinkConfig->isEmptyDict
      ? None
      : Some(paymentLinkConfig->paymentLinkConfigMapper),
  }
}

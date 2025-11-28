open BusinessProfileInterfaceTypesV1
open BusinessProfileInterfaceUtils
open LogicUtils

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

let constructWebhookDetailsRequestObject: _ => webhookDetailsRequest_v1 = webhookDetailsDict => {
  webhook_url: webhookDetailsDict
  ->getOptionString("webhook_url")
  ->BusinessProfileInterfaceUtils.convertOptionalStringToOptionalJson,
}

let mapV1WebhookDetailsToCommonType: webhookDetails_v1 => BusinessProfileInterfaceTypes.webhookDetails = webhookDetailsRecord => {
  {
    webhook_version: webhookDetailsRecord.webhook_version,
    webhook_username: webhookDetailsRecord.webhook_username,
    webhook_password: webhookDetailsRecord.webhook_password,
    webhook_url: webhookDetailsRecord.webhook_url,
    payment_created_enabled: webhookDetailsRecord.payment_created_enabled,
    payment_succeeded_enabled: webhookDetailsRecord.payment_succeeded_enabled,
    payment_failed_enabled: webhookDetailsRecord.payment_failed_enabled,
  }
}

let mapV1AuthConnectorDetailsToCommonType: option<authConnectorDetailsType_v1> => option<
  BusinessProfileInterfaceTypes.authConnectorDetailsType,
> = authConnectorDetailsOption => {
  switch authConnectorDetailsOption {
  | Some(authConnectorDetails) =>
    Some({
      authentication_connectors: authConnectorDetails.authentication_connectors,
      three_ds_requestor_url: authConnectorDetails.three_ds_requestor_url,
      three_ds_requestor_app_url: authConnectorDetails.three_ds_requestor_app_url,
    })
  | None => None
  }
}

let mapV1ExternalVaultConnectorDetailsToCommonType: option<
  externalVaultConnectorDetailsType_v1,
> => option<
  BusinessProfileInterfaceTypes.externalVaultConnectorDetails,
> = externalVaultConnectorDetailsOption => {
  switch externalVaultConnectorDetailsOption {
  | Some(externalVaultConnectorDetails) =>
    Some({
      vault_connector_id: externalVaultConnectorDetails.vault_connector_id,
      vault_token_selector: externalVaultConnectorDetails.vault_token_selector,
    })
  | None => None
  }
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

let externalVaultConnectorDetailsMapper = externalVaultConnectorDetailsDict => {
  vault_connector_id: externalVaultConnectorDetailsDict->getString("vault_connector_id", ""),
  vault_token_selector: externalVaultConnectorDetailsDict->getOptionalArrayFromDict(
    "vault_token_selector",
  ),
}

let mapJsonToBusinessProfileV1 = (values): profileEntity_v1 => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeaders = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  let paymentLinkConfig = jsonDict->getDictfromDict("payment_link_config")
  let externalVaultConnectorDetails = jsonDict->getDictfromDict("external_vault_connector_details")
  {
    profile_id: jsonDict->getString("profile_id", ""),
    merchant_id: jsonDict->getString("merchant_id", ""),
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
    authentication_connector_details: !(authenticationConnectorDetails->isEmptyDict)
      ? Some(authenticationConnectorDetails->constructAuthConnectorObject)
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
    force_3ds_challenge: jsonDict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookHeaders->isEmptyDict)
      ? Some(outgoingWebhookHeaders)
      : None,
    metadata: !(metadataKeyValue->isEmptyDict) ? Some(metadataKeyValue) : None,
    is_auto_retries_enabled: jsonDict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: jsonDict->getOptionInt("max_auto_retries_enabled"),
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    acquirer_configs: jsonDict->getOptionalArrayFromDict("acquirer_configs"),
    authentication_product_ids: Some(jsonDict->getJsonObjectFromDict("authentication_product_ids")),
    merchant_category_code: jsonDict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: jsonDict->getOptionBool("is_network_tokenization_enabled"),
    always_request_extended_authorization: jsonDict->getOptionBool(
      "always_request_extended_authorization",
    ),
    is_manual_retry_enabled: jsonDict->getOptionBool("is_manual_retry_enabled"),
    always_enable_overcapture: jsonDict->getOptionBool("always_enable_overcapture"),
    billing_processor_id: jsonDict->getOptionString("billing_processor_id"),
    payment_link_config: paymentLinkConfig->isEmptyDict
      ? None
      : Some(paymentLinkConfig->paymentLinkConfigMapper),
    is_external_vault_enabled: jsonDict->getOptionString("is_external_vault_enabled"),
    external_vault_connector_details: externalVaultConnectorDetails->isEmptyDict
      ? None
      : Some(externalVaultConnectorDetails->externalVaultConnectorDetailsMapper),
  }
}

let mapV1BackgroundImageToCommonType: backgroundImage_v1 => BusinessProfileInterfaceTypes.backgroundImage = backgroundImageRecord => {
  {
    url: backgroundImageRecord.url,
    position: backgroundImageRecord.position,
    size: backgroundImageRecord.size,
  }
}

let mapV1PaymentLinkConfigToCommonType: paymentLinkConfig_v1 => BusinessProfileInterfaceTypes.paymentLinkConfig = paymentLinkConfigRecord => {
  let backgroundImage =
    paymentLinkConfigRecord.background_image->Option.map(bgImage =>
      bgImage->mapV1BackgroundImageToCommonType
    )

  {
    theme: paymentLinkConfigRecord.theme,
    logo: paymentLinkConfigRecord.logo,
    seller_name: paymentLinkConfigRecord.seller_name,
    sdk_layout: paymentLinkConfigRecord.sdk_layout,
    display_sdk_only: paymentLinkConfigRecord.display_sdk_only,
    enabled_saved_payment_method: paymentLinkConfigRecord.enabled_saved_payment_method,
    hide_card_nickname_field: paymentLinkConfigRecord.hide_card_nickname_field,
    show_card_form_by_default: paymentLinkConfigRecord.show_card_form_by_default,
    transaction_details: paymentLinkConfigRecord.transaction_details,
    background_image: backgroundImage,
    details_layout: paymentLinkConfigRecord.details_layout,
    payment_button_text: paymentLinkConfigRecord.payment_button_text,
    custom_message_for_card_terms: paymentLinkConfigRecord.custom_message_for_card_terms,
    payment_button_colour: paymentLinkConfigRecord.payment_button_colour,
    skip_status_screen: paymentLinkConfigRecord.skip_status_screen,
    payment_button_text_colour: paymentLinkConfigRecord.payment_button_text_colour,
    background_colour: paymentLinkConfigRecord.background_colour,
    sdk_ui_rules: paymentLinkConfigRecord.sdk_ui_rules,
    payment_link_ui_rules: paymentLinkConfigRecord.payment_link_ui_rules,
    enable_button_only_on_form_ready: paymentLinkConfigRecord.enable_button_only_on_form_ready,
    payment_form_header_text: paymentLinkConfigRecord.payment_form_header_text,
    payment_form_label_type: paymentLinkConfigRecord.payment_form_label_type,
    show_card_terms: paymentLinkConfigRecord.show_card_terms,
    is_setup_mandate_flow: paymentLinkConfigRecord.is_setup_mandate_flow,
    color_icon_card_cvc_error: paymentLinkConfigRecord.color_icon_card_cvc_error,
    branding_visibility: paymentLinkConfigRecord.branding_visibility,
    domain_name: paymentLinkConfigRecord.domain_name,
    allowed_domains: paymentLinkConfigRecord.allowed_domains,
    business_specific_configs: paymentLinkConfigRecord.business_specific_configs,
  }
}

let mapV1toCommonType: profileEntity_v1 => BusinessProfileInterfaceTypes.commonProfileEntity = profileRecord => {
  let paymentLinkConfig =
    profileRecord.payment_link_config->Option.map(config =>
      config->mapV1PaymentLinkConfigToCommonType
    )

  {
    profile_id: profileRecord.profile_id,
    merchant_id: profileRecord.merchant_id,
    profile_name: profileRecord.profile_name,
    return_url: profileRecord.return_url,
    payment_response_hash_key: profileRecord.payment_response_hash_key,
    webhook_details: profileRecord.webhook_details->mapV1WebhookDetailsToCommonType,
    authentication_connector_details: profileRecord.authentication_connector_details->mapV1AuthConnectorDetailsToCommonType,
    collect_shipping_details_from_wallet_connector: profileRecord.collect_shipping_details_from_wallet_connector,
    always_collect_shipping_details_from_wallet_connector: profileRecord.always_collect_shipping_details_from_wallet_connector,
    collect_billing_details_from_wallet_connector: profileRecord.collect_billing_details_from_wallet_connector,
    always_collect_billing_details_from_wallet_connector: profileRecord.always_collect_billing_details_from_wallet_connector,
    is_connector_agnostic_mit_enabled: profileRecord.is_connector_agnostic_mit_enabled,
    is_click_to_pay_enabled: profileRecord.is_click_to_pay_enabled,
    authentication_product_ids: profileRecord.authentication_product_ids,
    outgoing_webhook_custom_http_headers: profileRecord.outgoing_webhook_custom_http_headers,
    is_auto_retries_enabled: profileRecord.is_auto_retries_enabled,
    max_auto_retries_enabled: profileRecord.max_auto_retries_enabled,
    metadata: profileRecord.metadata,
    force_3ds_challenge: profileRecord.force_3ds_challenge,
    is_debit_routing_enabled: profileRecord.is_debit_routing_enabled,
    acquirer_configs: profileRecord.acquirer_configs,
    merchant_category_code: profileRecord.merchant_category_code,
    is_network_tokenization_enabled: profileRecord.is_network_tokenization_enabled,
    always_request_extended_authorization: profileRecord.always_request_extended_authorization,
    always_enable_overcapture: profileRecord.always_enable_overcapture,
    is_manual_retry_enabled: profileRecord.is_manual_retry_enabled,
    collect_shipping_details_from_wallet_connector_if_required: None,
    collect_billing_details_from_wallet_connector_if_required: None,
    billing_processor_id: profileRecord.billing_processor_id,
    payment_link_config: paymentLinkConfig,
    split_txns_enabled: None,
    is_external_vault_enabled: profileRecord.is_external_vault_enabled,
    external_vault_connector_details: profileRecord.external_vault_connector_details->mapV1ExternalVaultConnectorDetailsToCommonType,
  }
}

let commonTypeJsonToV1ForRequest: JSON.t => profileEntityRequestType_v1 = json => {
  let dict = json->getDictFromJsonObject
  let outgoingWebhookdict = PaymentSettingsV2Utils.removeEmptyValues(
    ~dict,
    ~key="outgoing_webhook_custom_http_headers",
  )
  let metadataDict = PaymentSettingsV2Utils.removeEmptyValues(~dict, ~key="metadata")
  let authenticationConnectorDetails = dict->getDictfromDict("authentication_connector_details")
  let webhookDetails = dict->getDictfromDict("webhook_details")
  let authProductIds = dict->getJsonObjectFromDict("authentication_product_ids")
  let externalVaultConnectorDetails = dict->getDictfromDict("external_vault_connector_details")

  {
    profile_name: dict->getString("profile_name", ""),
    collect_billing_details_from_wallet_connector: dict
    ->getOptionBool("collect_billing_details_from_wallet_connector")
    ->convertOptionalBoolToOptionalJson,
    always_collect_billing_details_from_wallet_connector: dict
    ->getOptionBool("always_collect_billing_details_from_wallet_connector")
    ->convertOptionalBoolToOptionalJson,
    is_connector_agnostic_mit_enabled: dict
    ->getOptionBool("is_connector_agnostic_mit_enabled")
    ->convertOptionalBoolToOptionalJson,
    force_3ds_challenge: dict
    ->getOptionBool("force_3ds_challenge")
    ->convertOptionalBoolToOptionalJson,
    is_debit_routing_enabled: dict
    ->getOptionBool("is_debit_routing_enabled")
    ->convertOptionalBoolToOptionalJson,
    outgoing_webhook_custom_http_headers: outgoingWebhookdict->BusinessProfileInterfaceUtils.convertDictToOptionalJson,
    metadata: metadataDict->BusinessProfileInterfaceUtils.convertDictToOptionalJson,
    is_auto_retries_enabled: dict
    ->getOptionBool("is_auto_retries_enabled")
    ->convertOptionalBoolToOptionalJson,
    max_auto_retries_enabled: dict
    ->getOptionInt("max_auto_retries_enabled")
    ->convertOptionalIntToOptionalJson,
    is_click_to_pay_enabled: dict
    ->getOptionBool("is_click_to_pay_enabled")
    ->convertOptionalBoolToOptionalJson,
    authentication_product_ids: Some(authProductIds),
    merchant_category_code: dict
    ->getOptionString("merchant_category_code")
    ->convertOptionalStringToOptionalJson,
    is_network_tokenization_enabled: dict
    ->getOptionBool("is_network_tokenization_enabled")
    ->convertOptionalBoolToOptionalJson,
    always_request_extended_authorization: dict
    ->getOptionBool("always_request_extended_authorization")
    ->convertOptionalBoolToOptionalJson,
    is_manual_retry_enabled: dict
    ->getOptionBool("is_manual_retry_enabled")
    ->convertOptionalBoolToOptionalJson,
    return_url: dict
    ->getOptionString("return_url")
    ->BusinessProfileInterfaceUtils.convertOptionalStringToOptionalJson,
    webhook_details: !{webhookDetails->isEmptyDict}
      ? Some(
          webhookDetails
          ->constructWebhookDetailsRequestObject
          ->Identity.genericTypeToJson,
        )
      : Some(JSON.Encode.null),
    collect_shipping_details_from_wallet_connector: dict
    ->getOptionBool("collect_shipping_details_from_wallet_connector")
    ->convertOptionalBoolToOptionalJson,
    always_enable_overcapture: dict
    ->getOptionBool("always_enable_overcapture")
    ->convertOptionalBoolToOptionalJson,
    always_collect_shipping_details_from_wallet_connector: dict
    ->getOptionBool("always_collect_shipping_details_from_wallet_connector")
    ->convertOptionalBoolToOptionalJson,
    authentication_connector_details: !(authenticationConnectorDetails->isEmptyDict)
      ? Some(
          authenticationConnectorDetails
          ->constructAuthConnectorObject
          ->Identity.genericTypeToJson,
        )
      : Some(JSON.Encode.null),
    is_external_vault_enabled: dict->getOptionString("is_external_vault_enabled"),
    external_vault_connector_details: externalVaultConnectorDetails->isEmptyDict
      ? None
      : Some(externalVaultConnectorDetails->externalVaultConnectorDetailsMapper),
  }
}

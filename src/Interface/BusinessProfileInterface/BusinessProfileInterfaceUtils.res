open HSwitchSettingTypes
open LogicUtils

let constructWebhookDetailsObject = webhookDetailsDict => {
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
  let authConnectorDetails = {
    authentication_connectors: authConnectorDict->getOptionalArrayFromDict(
      "authentication_connectors",
    ),
    three_ds_requestor_url: authConnectorDict->getOptionString("three_ds_requestor_url"),
    three_ds_requestor_app_url: authConnectorDict->getOptionString("three_ds_requestor_app_url"),
  }

  authConnectorDetails
}

let mapJsonToBusinessProfileV1 = (values): profileEntity => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
  {
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
    authentication_connector_details: if authenticationConnectorDetails->isEmptyDict {
      None
    } else {
      Some(authenticationConnectorDetails->constructAuthConnectorObject)
    },
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
  }
}

let mapJsonToBusinessProfileV2 = (values): profileEntity => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")

  {
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
    authentication_connector_details: if authenticationConnectorDetails->isEmptyDict {
      None
    } else {
      Some(authenticationConnectorDetails->constructAuthConnectorObject)
    },
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
  }
}

let mapV1toCommonType: HSwitchSettingTypes.profileEntity => HSwitchSettingTypes.commonProfileEntity = profileEntity => {
  {
    profile_name: profileEntity.profile_name,
    return_url: profileEntity.return_url,
    payment_response_hash_key: profileEntity.payment_response_hash_key,
    webhook_details: profileEntity.webhook_details,
    authentication_connector_details: profileEntity.authentication_connector_details,
    collect_shipping_details_from_wallet_connector: profileEntity.collect_shipping_details_from_wallet_connector,
    always_collect_shipping_details_from_wallet_connector: profileEntity.always_collect_shipping_details_from_wallet_connector,
    collect_billing_details_from_wallet_connector: profileEntity.collect_billing_details_from_wallet_connector,
    always_collect_billing_details_from_wallet_connector: profileEntity.always_collect_billing_details_from_wallet_connector,
    is_connector_agnostic_mit_enabled: profileEntity.is_connector_agnostic_mit_enabled,
    is_click_to_pay_enabled: profileEntity.is_click_to_pay_enabled,
    authentication_product_ids: profileEntity.authentication_product_ids,
    outgoing_webhook_custom_http_headers: profileEntity.outgoing_webhook_custom_http_headers,
    is_auto_retries_enabled: profileEntity.is_auto_retries_enabled,
    max_auto_retries_enabled: profileEntity.max_auto_retries_enabled,
    metadata: profileEntity.metadata,
    force_3ds_challenge: profileEntity.force_3ds_challenge,
    is_debit_routing_enabled: profileEntity.is_debit_routing_enabled,
    acquirer_configs: profileEntity.acquirer_configs,
    merchant_category_code: profileEntity.merchant_category_code,
    is_network_tokenization_enabled: profileEntity.is_network_tokenization_enabled,
    always_request_extended_authorization: profileEntity.always_request_extended_authorization,
    always_enable_overcapture: profileEntity.always_enable_overcapture,
    is_manual_retry_enabled: profileEntity.is_manual_retry_enabled,
    collect_shipping_details_from_wallet_connector_if_required: None,
    collect_billing_details_from_wallet_connector_if_required: None,
  }
}
let mapV2toCommonType: HSwitchSettingTypes.profileEntity => HSwitchSettingTypes.commonProfileEntity = profileEntity => {
  {
    profile_name: profileEntity.profile_name,
    return_url: profileEntity.return_url,
    payment_response_hash_key: profileEntity.payment_response_hash_key,
    webhook_details: profileEntity.webhook_details,
    authentication_connector_details: profileEntity.authentication_connector_details,
    collect_shipping_details_from_wallet_connector: profileEntity.collect_shipping_details_from_wallet_connector,
    always_collect_shipping_details_from_wallet_connector: profileEntity.always_collect_shipping_details_from_wallet_connector,
    collect_billing_details_from_wallet_connector: profileEntity.collect_billing_details_from_wallet_connector,
    always_collect_billing_details_from_wallet_connector: profileEntity.always_collect_billing_details_from_wallet_connector,
    is_connector_agnostic_mit_enabled: profileEntity.is_connector_agnostic_mit_enabled,
    is_click_to_pay_enabled: profileEntity.is_click_to_pay_enabled,
    authentication_product_ids: profileEntity.authentication_product_ids,
    outgoing_webhook_custom_http_headers: profileEntity.outgoing_webhook_custom_http_headers,
    is_auto_retries_enabled: profileEntity.is_auto_retries_enabled,
    max_auto_retries_enabled: profileEntity.max_auto_retries_enabled,
    metadata: profileEntity.metadata,
    force_3ds_challenge: profileEntity.force_3ds_challenge,
    is_debit_routing_enabled: profileEntity.is_debit_routing_enabled,
    acquirer_configs: profileEntity.acquirer_configs,
    merchant_category_code: profileEntity.merchant_category_code,
    is_network_tokenization_enabled: profileEntity.is_network_tokenization_enabled,
    always_request_extended_authorization: profileEntity.always_request_extended_authorization,
    always_enable_overcapture: profileEntity.always_enable_overcapture,
    is_manual_retry_enabled: profileEntity.is_manual_retry_enabled,
    collect_shipping_details_from_wallet_connector_if_required: None,
    collect_billing_details_from_wallet_connector_if_required: None,
  }
}

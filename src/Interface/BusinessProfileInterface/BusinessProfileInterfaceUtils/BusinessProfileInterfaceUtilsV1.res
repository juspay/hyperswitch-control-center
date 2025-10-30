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

let mapJsonToBusinessProfileV1 = (values): profileEntity_v1 => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeaders = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
  let metadataKeyValue = jsonDict->getDictfromDict("metadata")
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
  }
}

let mapV1toCommonType: profileEntity_v1 => BusinessProfileInterfaceTypes.commonProfileEntity = profileRecord => {
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
  }
}

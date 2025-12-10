open LogicUtils
open BusinessProfileInterfaceTypesV2
open BusinessProfileInterfaceUtils

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

let constructWebhookDetailsRequestObject: _ => webhookDetailsRequest_v2 = webhookDetailsDict => {
  webhook_url: webhookDetailsDict
  ->getOptionString("webhook_url")
  ->convertOptionalStringToOptionalJson,
}
let mapV2AuthConnectorDetailsToCommonType: option<authConnectorDetailsType_v2> => option<
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

let mapJsonToBusinessProfileV2 = (values): profileEntity_v2 => {
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let outgoingWebhookHeades = jsonDict->getDictfromDict("outgoing_webhook_custom_http_headers")
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
    collect_shipping_details_from_wallet_connector_if_required: jsonDict->getOptionBool(
      "collect_shipping_details_from_wallet_connector_if_required",
    ),
    always_collect_shipping_details_from_wallet_connector: jsonDict->getOptionBool(
      "always_collect_shipping_details_from_wallet_connector",
    ),
    collect_billing_details_from_wallet_connector_if_required: jsonDict->getOptionBool(
      "collect_billing_details_from_wallet_connector_if_required",
    ),
    always_collect_billing_details_from_wallet_connector: jsonDict->getOptionBool(
      "always_collect_billing_details_from_wallet_connector",
    ),
    is_connector_agnostic_mit_enabled: jsonDict->getOptionBool("is_connector_agnostic_mit_enabled"),
    is_debit_routing_enabled: jsonDict->getOptionBool("is_debit_routing_enabled"),
    outgoing_webhook_custom_http_headers: !(outgoingWebhookHeades->isEmptyDict)
      ? Some(outgoingWebhookHeades)
      : None,
    metadata: !(metadataKeyValue->isEmptyDict) ? Some(metadataKeyValue) : None,
    is_click_to_pay_enabled: jsonDict->getOptionBool("is_click_to_pay_enabled"),
    authentication_product_ids: Some(
      jsonDict
      ->getDictfromDict("authentication_product_ids")
      ->JSON.Encode.object,
    ),
    merchant_category_code: jsonDict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: jsonDict->getOptionBool("is_network_tokenization_enabled"),
    split_txns_enabled: jsonDict->getOptionString("split_txns_enabled"),
  }
}
let mapV2WebhookDetailsToCommonType: webhookDetails_v2 => BusinessProfileInterfaceTypes.webhookDetails = webhookDetailsRecord => {
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

let mapV2toCommonType: profileEntity_v2 => BusinessProfileInterfaceTypes.commonProfileEntity = profileRecord => {
  {
    profile_id: profileRecord.profile_id,
    merchant_id: profileRecord.merchant_id,
    profile_name: profileRecord.profile_name,
    return_url: profileRecord.return_url,
    payment_response_hash_key: profileRecord.payment_response_hash_key,
    webhook_details: profileRecord.webhook_details->mapV2WebhookDetailsToCommonType,
    authentication_connector_details: profileRecord.authentication_connector_details->mapV2AuthConnectorDetailsToCommonType,
    collect_shipping_details_from_wallet_connector: None,
    always_collect_shipping_details_from_wallet_connector: profileRecord.always_collect_shipping_details_from_wallet_connector,
    collect_billing_details_from_wallet_connector: None,
    always_collect_billing_details_from_wallet_connector: profileRecord.always_collect_billing_details_from_wallet_connector,
    is_connector_agnostic_mit_enabled: profileRecord.is_connector_agnostic_mit_enabled,
    is_click_to_pay_enabled: profileRecord.is_click_to_pay_enabled,
    authentication_product_ids: profileRecord.authentication_product_ids,
    outgoing_webhook_custom_http_headers: profileRecord.outgoing_webhook_custom_http_headers,
    is_auto_retries_enabled: None,
    max_auto_retries_enabled: None,
    metadata: profileRecord.metadata,
    force_3ds_challenge: None,
    is_debit_routing_enabled: profileRecord.is_debit_routing_enabled,
    acquirer_configs: None,
    merchant_category_code: profileRecord.merchant_category_code,
    is_network_tokenization_enabled: profileRecord.is_network_tokenization_enabled,
    always_request_extended_authorization: None,
    always_enable_overcapture: None,
    is_manual_retry_enabled: None,
    collect_shipping_details_from_wallet_connector_if_required: profileRecord.collect_shipping_details_from_wallet_connector_if_required,
    collect_billing_details_from_wallet_connector_if_required: profileRecord.collect_billing_details_from_wallet_connector_if_required,
    split_txns_enabled: profileRecord.split_txns_enabled,
    billing_processor_id: None,
    payment_link_config: None,
    is_external_vault_enabled: None,
    external_vault_connector_details: None,
  }
}

let commonTypeJsonToV2ForRequest: JSON.t => profileEntityRequestType_v2 = json => {
  let dict = json->getDictFromJsonObject
  let outgoingWebhookdict = PaymentSettingsV2Utils.removeEmptyValues(
    ~dict,
    ~key="outgoing_webhook_custom_http_headers",
  )
  let metadataDict = PaymentSettingsV2Utils.removeEmptyValues(~dict, ~key="metadata")
  let authenticationConnectorDetails = dict->getDictfromDict("authentication_connector_details")
  let webhookDetails = dict->getDictfromDict("webhook_details")
  let authProductIds = dict->getDictfromDict("authentication_product_ids")

  {
    profile_name: dict->getString("profile_name", ""),
    collect_billing_details_from_wallet_connector_if_required: dict
    ->getOptionBool("collect_billing_details_from_wallet_connector_if_required")
    ->convertOptionalBoolToOptionalJson,
    always_collect_billing_details_from_wallet_connector: dict
    ->getOptionBool("always_collect_billing_details_from_wallet_connector")
    ->convertOptionalBoolToOptionalJson,
    is_connector_agnostic_mit_enabled: dict
    ->getOptionBool("is_connector_agnostic_mit_enabled")
    ->convertOptionalBoolToOptionalJson,
    is_debit_routing_enabled: dict
    ->getOptionBool("is_debit_routing_enabled")
    ->convertOptionalBoolToOptionalJson,
    outgoing_webhook_custom_http_headers: !(outgoingWebhookdict->isEmptyDict)
      ? Some(outgoingWebhookdict->JSON.Encode.object)
      : Some(JSON.Encode.null),
    metadata: !(metadataDict->isEmptyDict)
      ? Some(metadataDict->JSON.Encode.object)
      : Some(JSON.Encode.null),
    is_click_to_pay_enabled: dict
    ->getOptionBool("is_click_to_pay_enabled")
    ->convertOptionalBoolToOptionalJson,
    authentication_product_ids: !(authProductIds->isEmptyDict)
      ? Some(authProductIds->JSON.Encode.object)
      : Some(JSON.Encode.null),
    merchant_category_code: dict
    ->getOptionString("merchant_category_code")
    ->convertOptionalStringToOptionalJson,
    is_network_tokenization_enabled: dict
    ->getOptionBool("is_network_tokenization_enabled")
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
    collect_shipping_details_from_wallet_connector_if_required: dict
    ->getOptionBool("collect_shipping_details_from_wallet_connector_if_required")
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
    split_txns_enabled: dict
    ->getOptionString("split_txns_enabled")
    ->convertOptionalStringToOptionalJson,
  }
}

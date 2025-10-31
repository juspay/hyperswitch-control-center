type webhookDetails_v2 = {
  webhook_version: option<string>,
  webhook_username: option<string>,
  webhook_password: option<string>,
  webhook_url: option<string>,
  payment_created_enabled: option<bool>,
  payment_succeeded_enabled: option<bool>,
  payment_failed_enabled: option<bool>,
}
type authConnectorDetailsType_v2 = {
  authentication_connectors: option<array<JSON.t>>,
  three_ds_requestor_url: option<string>,
  three_ds_requestor_app_url: option<string>,
}

type profileEntityRequestType_v2 = {
  profile_name: string,
  return_url: option<JSON.t>,
  webhook_details: option<JSON.t>,
  authentication_connector_details: option<JSON.t>,
  collect_shipping_details_from_wallet_connector_if_required: option<JSON.t>,
  always_collect_shipping_details_from_wallet_connector: option<JSON.t>,
  collect_billing_details_from_wallet_connector_if_required: option<JSON.t>,
  always_collect_billing_details_from_wallet_connector: option<JSON.t>,
  is_connector_agnostic_mit_enabled: option<JSON.t>,
  is_click_to_pay_enabled: option<JSON.t>,
  authentication_product_ids: option<JSON.t>,
  outgoing_webhook_custom_http_headers: option<JSON.t>,
  metadata: option<JSON.t>,
  is_debit_routing_enabled: option<JSON.t>,
  merchant_category_code: option<JSON.t>,
  is_network_tokenization_enabled: option<JSON.t>,
  split_txns_enabled: option<JSON.t>,
}
type webhookDetailsRequest_v2 = {webhook_url: option<JSON.t>}

type profileEntity_v2 = {
  profile_id: string,
  merchant_id: string,
  profile_name: string,
  return_url: option<string>,
  payment_response_hash_key: option<string>,
  webhook_details: webhookDetails_v2,
  authentication_connector_details: option<authConnectorDetailsType_v2>,
  collect_shipping_details_from_wallet_connector_if_required: option<bool>,
  always_collect_shipping_details_from_wallet_connector: option<bool>,
  collect_billing_details_from_wallet_connector_if_required: option<bool>,
  always_collect_billing_details_from_wallet_connector: option<bool>,
  is_connector_agnostic_mit_enabled: option<bool>,
  is_click_to_pay_enabled: option<bool>,
  authentication_product_ids: option<JSON.t>,
  outgoing_webhook_custom_http_headers: option<Dict.t<JSON.t>>,
  metadata: option<Dict.t<JSON.t>>,
  force_3ds_challenge: option<bool>,
  is_debit_routing_enabled: option<bool>,
  merchant_category_code: option<string>,
  is_network_tokenization_enabled: option<bool>,
  split_txns_enabled: option<string>,
}

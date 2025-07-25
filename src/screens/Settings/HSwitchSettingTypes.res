type address = {
  line1: option<string>,
  line2: option<string>,
  line3: option<string>,
  city: option<string>,
  state: option<string>,
  zip: option<string>,
  country?: string,
}

type merchantDetails = {
  primary_contact_person: option<string>,
  primary_email: option<string>,
  primary_phone: option<string>,
  secondary_contact_person: option<string>,
  secondary_email: option<string>,
  secondary_phone: option<string>,
  website: option<string>,
  about_business: option<string>,
  address: address,
}

type webhookDetails = {
  webhook_version: option<string>,
  webhook_username: option<string>,
  webhook_password: option<string>,
  webhook_url: option<string>,
  payment_created_enabled: option<bool>,
  payment_succeeded_enabled: option<bool>,
  payment_failed_enabled: option<bool>,
}

type authConnectorDetailsType = {
  authentication_connectors: option<array<JSON.t>>,
  three_ds_requestor_url: option<string>,
  three_ds_requestor_app_url: option<string>,
}

type profileSetting = {
  merchant_id: string,
  merchant_name: string,
  locker_id: string,
  primary_business_details: array<JSON.t>,
  merchant_details: merchantDetails,
}

type webhookSettings = {
  merchant_id: string,
  return_url: string,
  webhook_details: webhookDetails,
}

type consolidatedBusinessEntity = {
  businesses: array<string>,
  country: string,
}

type businessEntity = {
  business: string,
  country: string,
}

type reconStatus = NotRequested | Requested | Active | Disabled

type merchantPayload = {
  api_key: string,
  enable_payment_response_hash: bool,
  locker_id: string,
  merchant_details: merchantDetails,
  merchant_id: string,
  merchant_name: option<string>,
  primary_business_details: array<businessEntity>,
  metadata: string,
  parent_merchant_id: string,
  payment_response_hash_key: option<string>,
  publishable_key: string,
  redirect_to_merchant_with_http_post: bool,
  sub_merchants_enabled: bool,
  recon_status: reconStatus,
  product_type: ProductTypes.productTypes,
  merchant_account_type: OMPSwitchTypes.ompType,
}

type organizationPayload = {
  organization_id: string,
  organization_name: option<string>,
  organization_type: OMPSwitchTypes.ompType,
}

type colType =
  | Name
  | Description
  | Prefix
  | Created
  | Expiration
  | CustomCell

type apiModalState = Create | Update | Loading | SettingApiModalError | Success

type parseMerchantJson = {
  apiKeys: Dict.t<JSON.t>,
  merchantInfo: Dict.t<JSON.t>,
}

type validationFields =
  | PrimaryEmail
  | SecondaryEmail
  | PrimaryPhone
  | SecondaryPhone
  | Website
  | WebhookUrl
  | ReturnUrl
  | AuthenticationConnectors(array<JSON.t>)
  | ThreeDsRequestorUrl
  | ThreeDsRequestorAppUrl
  | UnknownValidateFields(string)
  | MaxAutoRetries

type formStateType = Preview | Edit
type fieldType = {
  placeholder: string,
  label: string,
  name: string,
  inputType: InputFields.customInputFn,
}
type fieldsInfoType = {
  name: string,
  description: string,
  inputFields: array<fieldType>,
}
type detailsType = Primary | Secondary | Business

type cardNames = [
  | #BUSINESS_SETTINGS
  | #BUSINESS_UNITS
  | #NOTIFICATIONS
  | #PROFILE_SETTINGS
  | #DELETE_SAMPLE_DATA
  | #MANDATE_SETTINGS
]

type personalSettings = {
  heading: string,
  subHeading: string,
  redirect?: string,
  cardName: cardNames,
  isComingSoon?: bool,
  buttonText?: string,
  redirectUrl?: string,
  isApiCall?: bool,
}

type profileEntity = {
  merchant_id: string,
  profile_id: string,
  profile_name: string,
  return_url: option<string>,
  payment_response_hash_key: option<string>,
  webhook_details: webhookDetails,
  authentication_connector_details: authConnectorDetailsType,
  collect_shipping_details_from_wallet_connector: option<bool>,
  always_collect_shipping_details_from_wallet_connector: option<bool>,
  collect_billing_details_from_wallet_connector: option<bool>,
  always_collect_billing_details_from_wallet_connector: option<bool>,
  is_connector_agnostic_mit_enabled: option<bool>,
  is_click_to_pay_enabled: option<bool>,
  authentication_product_ids: option<JSON.t>,
  outgoing_webhook_custom_http_headers: option<Dict.t<JSON.t>>,
  is_auto_retries_enabled: option<bool>,
  max_auto_retries_enabled: option<int>,
  metadata: option<Dict.t<JSON.t>>,
  force_3ds_challenge: option<bool>,
  is_debit_routing_enabled: option<bool>,
  acquirer_configs: option<array<JSON.t>>,
  merchant_category_code: option<string>,
}

type twoFaType = RecoveryCode | Totp

type twoSettingsTypes = ResetTotp | RegenerateRecoveryCode

type profileSettingsTypes = ACCOUNT_SETTINGS | TWO_FA_SETTINGS(twoSettingsTypes)

type checkStatusType = {
  totp: bool,
  recovery_code: bool,
}

type regenerateRecoveryCode = RegenerateQR | ShowNewTotp(string)

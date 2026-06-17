@unboxed
type styleType =
  | @as("default") Default
  | @as("") Custom

@unboxed
type captureMethod =
  | @as("automatic") Automatic
  | @as("manual") Manual

@unboxed
type setupFutureUsage =
  | @as("off_session") OffSession
  | @as("on_session") OnSession

@unboxed
type authenticationType =
  | @as("three_ds") ThreeDS
  | @as("no_three_ds") NoThreeDS

@unboxed
type showCardTerms =
  | @as("always") Always
  | @as("auto") Auto
  | @as("never") Never

type background_image = {url: string}

type preloadSdkWithParams = {
  payment_methods_list: option<JSON.t>,
  customer_methods_list: option<JSON.t>,
  session_tokens: option<JSON.t>,
  blocked_bins: option<JSON.t>,
}

type paymentLinkWasmPayload = {
  test_mode: option<bool>,
  preload_sdk_with_params: option<preloadSdkWithParams>,
  client_secret: string,
  payment_id: string,
  session_expiry: string,
  status: string,
  amount: string,
  currency: string,
  pub_key: string,
  merchant_logo: string,
  return_url: string,
  merchant_name: string,
  max_items_visible_after_collapse: int,
  theme: string,
  merchant_description: option<string>,
  sdk_layout: string,
  display_sdk_only: bool,
  hide_card_nickname_field: bool,
  show_card_form_by_default: bool,
  locale: option<string>,
  background_image: option<background_image>,
  details_layout: option<string>,
  branding_visibility: option<bool>,
  payment_button_text: option<string>,
  skip_status_screen: option<bool>,
  custom_message_for_card_terms: option<string>,
  payment_button_colour: option<string>,
  payment_button_text_colour: option<string>,
  background_colour: option<string>,
  sdk_ui_rules: option<JSON.t>,
  enable_button_only_on_form_ready: bool,
  payment_form_header_text: option<string>,
  payment_form_label_type: option<string>,
  show_card_terms: option<string>,
  is_setup_mandate_flow: option<bool>,
  capture_method: option<string>,
  setup_future_usage_applied: option<string>,
  color_icon_card_cvc_error: option<string>,
}

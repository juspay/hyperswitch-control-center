type stepType =
  | Checkout
  | Configurator

@unboxed
type styleType =
  | @as("default") Default
  | @as("") Custom

type previewState =
  | PreviewLoading
  | PreviewError(string)
  | PreviewSuccess(string)

type previewMode =
  | Mobile
  | Web

type previewModeMeta = {
  key: string,
  label: string,
  icon: string,
}

type previewContentConfig = {
  iframeScale: string,
  iframeWidth: string,
  iframeHeight: string,
}

@unboxed
type setupFutureUsage =
  | @as("off_session") OffSession
  | @as("on_session") OnSession

@unboxed
type showCardTerms =
  | @as("always") Always
  | @as("auto") Auto
  | @as("never") Never

@unboxed
type sdkLayout =
  | @as("accordion") Accordion
  | @as("tabs") Tabs
  | @as("spaced_accordion") SpacedAccordion

@unboxed
type detailsLayout =
  | @as("layout1") Layout1
  | @as("layout2") Layout2

type cssRulesKey =
  | SdkUiRules
  | PaymentLinkUiRules

type cssInputType =
  | CssColor
  | CssText
  | CssPxNumber
  | CssFontWeight

type cssFieldDefinition = {
  rulesKey: cssRulesKey,
  selectorKey: string,
  selector: string,
  cssProperty: string,
  label: string,
  inputType: cssInputType,
  placeholder: string,
  important: bool,
}

type cssAccordionDefinition = {
  title: string,
  fields: array<cssFieldDefinition>,
}

@unboxed
type cssFontWeight =
  | @as("100") FontWeight100
  | @as("200") FontWeight200
  | @as("300") FontWeight300
  | @as("400") FontWeight400
  | @as("500") FontWeight500
  | @as("600") FontWeight600
  | @as("700") FontWeight700
  | @as("800") FontWeight800
  | @as("900") FontWeight900

type backgroundImage = {url: string}

type paymentLinkWasmPayload = {
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
  background_image: option<backgroundImage>,
  details_layout: option<string>,
  branding_visibility: option<bool>,
  payment_button_text: option<string>,
  skip_status_screen: option<bool>,
  custom_message_for_card_terms: option<string>,
  payment_button_colour: option<string>,
  payment_button_text_colour: option<string>,
  background_colour: option<string>,
  sdk_ui_rules: option<JSON.t>,
  payment_link_ui_rules: option<JSON.t>,
  enable_button_only_on_form_ready: bool,
  payment_form_header_text: option<string>,
  payment_form_label_type: option<string>,
  show_card_terms: option<string>,
  is_setup_mandate_flow: option<bool>,
  capture_method: option<string>,
  setup_future_usage_applied: option<string>,
  color_icon_card_cvc_error: option<string>,
}

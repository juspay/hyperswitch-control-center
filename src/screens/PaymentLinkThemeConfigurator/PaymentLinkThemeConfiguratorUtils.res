open LogicUtils
open PaymentLinkThemeConfiguratorTypes

let defaultStyleId = (Default: PaymentLinkThemeConfiguratorTypes.styleType :> string)

let showCardTermsOptions: array<SelectBox.dropdownOption> = [
  Always,
  Auto,
  Never,
]->Array.map(item => {
  let value = (item :> string)
  let option: SelectBox.dropdownOption = {label: value->capitalizeString, value}
  option
})

let allowedDomainsToArray = allowedDomainsOpt => {
  let domainsStr =
    allowedDomainsOpt->Option.getOr(JSON.Encode.null)->JSON.Decode.string->Option.getOr("")
  let allowedDomains =
    domainsStr
    ->String.split(",")
    ->Array.map(String.trim)
    ->Array.filter(isNonEmptyString)
  allowedDomains->Array.length === 0 ? None : Some(allowedDomains->getJsonFromArrayOfString)
}

let constructBusinessProfileBody = (~paymentLinkConfig, ~styleID) => {
  open BusinessProfileInterfaceUtils

  let paymentLinkConfig = paymentLinkConfig->Option.getOr(paymentLinkConfigMapper(Dict.make()))
  let businessSpecificConfigs =
    paymentLinkConfig.business_specific_configs->Option.getOr(JSON.Encode.null)
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
  updatedBusinessSpecificDict->Dict.set(styleID, Dict.make()->JSON.Encode.object)

  {
    ...paymentLinkConfig,
    allowed_domains: paymentLinkConfig.allowed_domains->allowedDomainsToArray,
    business_specific_configs: Some(updatedBusinessSpecificDict->JSON.Encode.object),
  }
}

let constructBusinessProfileBodyFromJson = (~json, ~paymentLinkConfig, ~styleID) => {
  open BusinessProfileInterfaceUtils

  let paymentLinkConfig = paymentLinkConfig->Option.getOr(paymentLinkConfigMapper(Dict.make()))

  let businessSpecificConfigs =
    paymentLinkConfig.business_specific_configs->Option.getOr(JSON.Encode.null)
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
  updatedBusinessSpecificDict->Dict.set(styleID, json)

  let paymentLinkConfig: BusinessProfileInterfaceTypes.paymentLinkConfig = {
    theme: paymentLinkConfig.theme,
    logo: paymentLinkConfig.logo,
    seller_name: paymentLinkConfig.seller_name,
    sdk_layout: paymentLinkConfig.sdk_layout,
    display_sdk_only: paymentLinkConfig.display_sdk_only,
    enabled_saved_payment_method: paymentLinkConfig.enabled_saved_payment_method,
    hide_card_nickname_field: paymentLinkConfig.hide_card_nickname_field,
    show_card_form_by_default: paymentLinkConfig.show_card_form_by_default,
    transaction_details: paymentLinkConfig.transaction_details,
    background_image: paymentLinkConfig.background_image,
    details_layout: paymentLinkConfig.details_layout,
    payment_button_text: paymentLinkConfig.payment_button_text,
    custom_message_for_card_terms: paymentLinkConfig.custom_message_for_card_terms,
    payment_button_colour: paymentLinkConfig.payment_button_colour,
    skip_status_screen: paymentLinkConfig.skip_status_screen,
    payment_button_text_colour: paymentLinkConfig.payment_button_text_colour,
    background_colour: paymentLinkConfig.background_colour,
    sdk_ui_rules: paymentLinkConfig.sdk_ui_rules,
    payment_link_ui_rules: paymentLinkConfig.payment_link_ui_rules,
    enable_button_only_on_form_ready: paymentLinkConfig.enable_button_only_on_form_ready,
    payment_form_header_text: paymentLinkConfig.payment_form_header_text,
    payment_form_label_type: paymentLinkConfig.payment_form_label_type,
    show_card_terms: paymentLinkConfig.show_card_terms,
    is_setup_mandate_flow: paymentLinkConfig.is_setup_mandate_flow,
    color_icon_card_cvc_error: paymentLinkConfig.color_icon_card_cvc_error,
    domain_name: paymentLinkConfig.domain_name,
    allowed_domains: paymentLinkConfig.allowed_domains->allowedDomainsToArray,
    branding_visibility: paymentLinkConfig.branding_visibility,
    business_specific_configs: Some(updatedBusinessSpecificDict->JSON.Encode.object),
  }
  paymentLinkConfig
}

let generateWasmPayload = (~paymentDetails, ~publishableKey, ~formValues) => {
  let paymentDetailsDict = paymentDetails->getDictFromJsonObject
  let formValuesDict = formValues->getDictFromJsonObject

  let backgroundImage = getString(formValuesDict, "background_image", "")
  let backgroundImageObj = backgroundImage->isNonEmptyString ? Some({url: backgroundImage}) : None

  let currency = getString(paymentDetailsDict, "currency", "USD")
  let amount = paymentDetailsDict->getInt("amount", 0)->Int.toFloat
  let formattedAmount =
    CurrencyUtils.convertCurrencyFromLowestDenomination(~amount, ~currency)->Float.toString

  let getNonEmptyValue = (dict, key, defaultValue) => {
    switch getOptionString(dict, key) {
    | Some(value) if value->isNonEmptyString => value
    | _ => defaultValue
    }
  }

  {
    pub_key: publishableKey,
    amount: formattedAmount,
    currency,
    client_secret: getString(paymentDetailsDict, "client_secret", ""),
    payment_id: getString(paymentDetailsDict, "payment_id", ""),
    status: getString(paymentDetailsDict, "status", "incomplete"),
    session_expiry: getString(paymentDetailsDict, "expires_on", ""),
    merchant_logo: getString(formValuesDict, "logo", ""),
    return_url: getString(formValuesDict, "return_url", "https://google.com"),
    merchant_name: getNonEmptyValue(formValuesDict, "seller_name", "Seller Name"),
    max_items_visible_after_collapse: formValuesDict->getInt("max_items_visible_after_collapse", 3),
    theme: getNonEmptyValue(formValuesDict, "theme", "#FFFFFF"),
    sdk_layout: getNonEmptyValue(formValuesDict, "sdk_layout", "accordion"),
    display_sdk_only: formValuesDict->getBool("display_sdk_only", false),
    hide_card_nickname_field: formValuesDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: formValuesDict->getBool("show_card_form_by_default", true),
    enable_button_only_on_form_ready: formValuesDict->getBool(
      "enable_button_only_on_form_ready",
      true,
    ),
    payment_button_text: getOptionString(formValuesDict, "payment_button_text"),
    merchant_description: getOptionString(formValuesDict, "merchant_description"),
    locale: Some("en"),
    background_image: backgroundImageObj,
    details_layout: getOptionString(formValuesDict, "details_layout"),
    branding_visibility: getOptionBool(formValuesDict, "branding_visibility"),
    skip_status_screen: getOptionBool(formValuesDict, "skip_status_screen"),
    custom_message_for_card_terms: getOptionString(formValuesDict, "custom_message_for_card_terms"),
    payment_button_colour: getOptionString(formValuesDict, "payment_button_colour"),
    payment_button_text_colour: getOptionString(formValuesDict, "payment_button_text_colour"),
    background_colour: getOptionString(formValuesDict, "background_colour"),
    sdk_ui_rules: None,
    payment_form_header_text: getOptionString(formValuesDict, "payment_form_header_text"),
    payment_form_label_type: getOptionString(formValuesDict, "payment_form_label_type"),
    show_card_terms: getOptionString(formValuesDict, "show_card_terms"),
    is_setup_mandate_flow: getOptionBool(formValuesDict, "is_setup_mandate_flow"),
    capture_method: getOptionString(paymentDetailsDict, "capture_method"),
    setup_future_usage_applied: getOptionString(paymentDetailsDict, "setup_future_usage"),
    color_icon_card_cvc_error: getOptionString(formValuesDict, "color_icon_card_cvc_error"),
  }
}

let validateStyleIdForm = (values: JSON.t) => {
  let errors = Dict.make()

  let styleId = values->getDictFromJsonObject->getString("payment_link_config_id", "")->String.trim
  let regexForStyleId = "^([a-zA-Z0-9_\\s-]+)$"

  let isDefault = styleId == defaultStyleId
  let errorMessage = if styleId->isEmptyString {
    "Payment Link Config ID name cannot be empty"
  } else if styleId->String.length > 32 {
    "Payment Link Config ID name cannot exceed 32 characters"
  } else if !RegExp.test(RegExp.fromString(regexForStyleId), styleId) {
    "Payment Link Config ID name should not contain special characters"
  } else if isDefault {
    "Payment Link Config ID with this name already exists in this organization"
  } else {
    ""
  }

  if errorMessage->isNonEmptyString {
    Dict.set(errors, "payment_link_config_id", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}

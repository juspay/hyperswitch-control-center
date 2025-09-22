let constructBusinessProfileBody = (~paymentLinkConfig, ~styleID) => {
  open LogicUtils

  let paymentLinkConfig = switch paymentLinkConfig {
  | Some(config) => config
  | None => BusinessProfileMapper.paymentLinkConfigMapper(Dict.make())
  }

  let sytleIdConfig: HSwitchSettingTypes.style_configs = {
    theme: paymentLinkConfig.theme,
    logo: paymentLinkConfig.logo,
    seller_name: paymentLinkConfig.seller_name,
    sdk_layout: paymentLinkConfig.sdk_layout,
    display_sdk_only: paymentLinkConfig.display_sdk_only,
    enabled_saved_payment_method: paymentLinkConfig.enabled_saved_payment_method,
    hide_card_nickname_field: paymentLinkConfig.hide_card_nickname_field,
    show_card_form_by_default: paymentLinkConfig.show_card_form_by_default,
    payment_button_text: paymentLinkConfig.payment_button_text,
    sdk_ui_rules: paymentLinkConfig.sdk_ui_rules,
    allowed_domains: paymentLinkConfig.allowed_domains,
    payment_link_ui_rules: paymentLinkConfig.payment_link_ui_rules,
    domain_name: paymentLinkConfig.domain_name,
    branding_visibility: paymentLinkConfig.branding_visibility,
  }

  let businessSpecificConfigs = paymentLinkConfig.business_specific_configs
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let newConfigs = Dict.copy(businessSpecificConfigsDict)
  newConfigs->Dict.set(styleID, sytleIdConfig->Identity.genericTypeToJson)

  let paymentLinkConfigNew = {
    ...paymentLinkConfig,
    business_specific_configs: newConfigs->JSON.Encode.object,
  }

  paymentLinkConfigNew
}

let constructBusinessProfileBodyFromJson = (~json, ~paymentLinkConfig, ~styleID) => {
  open LogicUtils

  let paymentLinkConfig = switch paymentLinkConfig {
  | Some(config) => config
  | None => BusinessProfileMapper.paymentLinkConfigMapper(Dict.make())
  }

  let businessSpecificConfigs = paymentLinkConfig.business_specific_configs
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let newConfigs = Dict.copy(businessSpecificConfigsDict)
  newConfigs->Dict.set(styleID, json)

  let paymentLinkConfigNew = {
    ...paymentLinkConfig,
    business_specific_configs: newConfigs->JSON.Encode.object,
  }

  paymentLinkConfigNew
}

let generateWasmPayload = (~paymentDetails, ~publishableKey, ~formValues) => {
  open PaymentLinkThemeConfiguratorTypes
  open LogicUtils

  // Js.log2("paymentDetails", paymentDetails)
  // Js.log2("formValues", formValues)

  let paymentDetailsDict = paymentDetails->getDictFromJsonObject
  let formValuesDict = formValues->getDictFromJsonObject

  let getStringFromDict = (dict, key, default) => dict->getString(key, default)

  let backgroundImage = getStringFromDict(formValuesDict, "background_image", "")
  let backgroundImageObj = if backgroundImage->LogicUtils.isNonEmptyString {
    Some({url: backgroundImage})
  } else {
    None
  }

  {
    pub_key: publishableKey,
    amount: paymentDetailsDict->getInt("amount", 0)->Int.toString,
    currency: getStringFromDict(paymentDetailsDict, "currency", "USD"),
    client_secret: getStringFromDict(paymentDetailsDict, "client_secret", ""),
    payment_id: getStringFromDict(paymentDetailsDict, "payment_id", ""),
    status: getStringFromDict(paymentDetailsDict, "status", "incomplete"),
    session_expiry: getStringFromDict(paymentDetailsDict, "expires_on", ""),
    merchant_logo: getStringFromDict(formValuesDict, "logo", ""),
    return_url: getStringFromDict(formValuesDict, "return_url", "https://google.com"),
    merchant_name: getStringFromDict(formValuesDict, "seller_name", "Seller Name"),
    max_items_visible_after_collapse: formValuesDict->getInt("max_items_visible_after_collapse", 3),
    theme: getStringFromDict(formValuesDict, "theme", ""),
    sdk_layout: getStringFromDict(formValuesDict, "sdk_layout", "accordion"),
    display_sdk_only: formValuesDict->getBool("display_sdk_only", false),
    hide_card_nickname_field: formValuesDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: formValuesDict->getBool("show_card_form_by_default", true),
    enable_button_only_on_form_ready: formValuesDict->getBool(
      "enable_button_only_on_form_ready",
      true,
    ),
    payment_button_text: Some(getStringFromDict(formValuesDict, "payment_button_text", "")),
    merchant_description: Some(getStringFromDict(formValuesDict, "merchant_description", "")),
    locale: Some("en"),
    background_image: backgroundImageObj,
    details_layout: Some(getStringFromDict(formValuesDict, "details_layout", "")),
    branding_visibility: Some(formValuesDict->getBool("branding_visibility", false)),
    skip_status_screen: Some(formValuesDict->getBool("skip_status_screen", false)),
    custom_message_for_card_terms: Some(
      getStringFromDict(formValuesDict, "custom_message_for_card_terms", ""),
    ),
    payment_button_colour: Some(getStringFromDict(formValuesDict, "payment_button_colour", "")),
    payment_button_text_colour: Some(
      getStringFromDict(formValuesDict, "payment_button_text_colour", ""),
    ),
    background_colour: Some(getStringFromDict(formValuesDict, "background_colour", "#FFFFFF")),
    sdk_ui_rules: None,
    payment_form_header_text: Some(
      getStringFromDict(formValuesDict, "payment_form_header_text", ""),
    ),
    payment_form_label_type: Some(getStringFromDict(formValuesDict, "payment_form_label_type", "")),
    show_card_terms: Some(getStringFromDict(formValuesDict, "show_card_terms", "")),
    is_setup_mandate_flow: Some(formValuesDict->getBool("is_setup_mandate_flow", false)),
    capture_method: Some(getStringFromDict(paymentDetailsDict, "capture_method", "")),
    setup_future_usage_applied: Some(
      getStringFromDict(paymentDetailsDict, "setup_future_usage_applied", ""),
    ),
    color_icon_card_cvc_error: Some(
      getStringFromDict(formValuesDict, "color_icon_card_cvc_error", ""),
    ),
  }
}

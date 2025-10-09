open LogicUtils
open PaymentLinkThemeConfiguratorTypes

let selectedStyleVariant = styleID => {
  switch styleID {
  | "default" => Default
  | _ => Custom
  }
}

let getDefaultStyleLabelValue = styleVariant => {
  switch styleVariant {
  | Default => "default"
  | _ => ""
  }
}

let getDefaultStylesValue: HSwitchSettingTypes.payment_link_config => HSwitchSettingTypes.style_configs = paymentLinkConfig => {
  {
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
}

let constructBusinessProfileBody = (~paymentLinkConfig, ~styleID) => {
  open BusinessProfileMapper

  let paymentLinkConfig = switch paymentLinkConfig {
  | Some(config) => config
  | None => paymentLinkConfigMapper(Dict.make())
  }

  let defaultStyles = paymentLinkConfig->getDefaultStylesValue

  let businessSpecificConfigs = paymentLinkConfig.business_specific_configs
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
  updatedBusinessSpecificDict->Dict.set(styleID, defaultStyles->Identity.genericTypeToJson)

  {
    ...paymentLinkConfig,
    business_specific_configs: updatedBusinessSpecificDict->JSON.Encode.object,
  }
}

let constructBusinessProfileBodyFromJson = (~json, ~paymentLinkConfig, ~styleID) => {
  open BusinessProfileMapper

  let paymentLinkConfig = switch paymentLinkConfig {
  | Some(config) => config
  | None => paymentLinkConfigMapper(Dict.make())
  }

  switch styleID->selectedStyleVariant {
  | Default => {
      let styleConfig = json->getDictFromJsonObject->styleConfigMapper

      {
        ...styleConfig,
        business_specific_configs: paymentLinkConfig.business_specific_configs,
      }
    }
  | Custom => {
      let businessSpecificConfigs = paymentLinkConfig.business_specific_configs
      let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
      let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
      updatedBusinessSpecificDict->Dict.set(styleID, json)

      {
        ...paymentLinkConfig,
        business_specific_configs: updatedBusinessSpecificDict->JSON.Encode.object,
      }
    }
  }
}

let generateWasmPayload = (~paymentDetails, ~publishableKey, ~formValues) => {
  let paymentDetailsDict = paymentDetails->getDictFromJsonObject
  let formValuesDict = formValues->getDictFromJsonObject

  let getStringFromDict = (dict, key, default) => dict->getString(key, default)

  let backgroundImage = getStringFromDict(formValuesDict, "background_image", "")
  let backgroundImageObj = if backgroundImage->isNonEmptyString {
    Some({url: backgroundImage})
  } else {
    None
  }

  {
    pub_key: publishableKey,
    amount: (paymentDetailsDict->getInt("amount", 0) / 100)->Int.toString,
    currency: getStringFromDict(paymentDetailsDict, "currency", "USD"),
    client_secret: getStringFromDict(paymentDetailsDict, "client_secret", ""),
    payment_id: getStringFromDict(paymentDetailsDict, "payment_id", ""),
    status: getStringFromDict(paymentDetailsDict, "status", "incomplete"),
    session_expiry: getStringFromDict(paymentDetailsDict, "expires_on", ""),
    merchant_logo: getStringFromDict(formValuesDict, "logo", ""),
    return_url: getStringFromDict(formValuesDict, "return_url", "https://google.com"),
    merchant_name: getStringFromDict(formValuesDict, "seller_name", "Seller Name"),
    max_items_visible_after_collapse: formValuesDict->getInt("max_items_visible_after_collapse", 3),
    theme: getStringFromDict(formValuesDict, "theme", "#FFFFFF"),
    sdk_layout: getStringFromDict(formValuesDict, "sdk_layout", "accordion"),
    display_sdk_only: formValuesDict->getBool("display_sdk_only", false),
    hide_card_nickname_field: formValuesDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: formValuesDict->getBool("show_card_form_by_default", true),
    enable_button_only_on_form_ready: formValuesDict->getBool(
      "enable_button_only_on_form_ready",
      true,
    ),
    payment_button_text: Some(getStringFromDict(formValuesDict, "payment_button_text", "Pay Now")),
    merchant_description: Some(getStringFromDict(formValuesDict, "merchant_description", "")),
    locale: Some("en"),
    background_image: backgroundImageObj,
    details_layout: Some(getStringFromDict(formValuesDict, "details_layout", "")),
    branding_visibility: Some(formValuesDict->getBool("branding_visibility", false)),
    skip_status_screen: Some(formValuesDict->getBool("skip_status_screen", false)),
    custom_message_for_card_terms: Some(
      getStringFromDict(formValuesDict, "custom_message_for_card_terms", ""),
    ),
    payment_button_colour: Some(
      getStringFromDict(formValuesDict, "payment_button_colour", "#FFFFFF"),
    ),
    payment_button_text_colour: Some(
      getStringFromDict(formValuesDict, "payment_button_text_colour", "#000000"),
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
      getStringFromDict(formValuesDict, "color_icon_card_cvc_error", "#FFFFFF"),
    ),
  }
}

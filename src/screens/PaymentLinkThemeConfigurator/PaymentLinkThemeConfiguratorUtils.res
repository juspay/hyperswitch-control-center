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

let generateWasmPayload = (~paymentResult, ~publishableKey, ~initialValues) => {
  open PaymentLinkThemeConfiguratorTypes
  open LogicUtils

  let paymentResultDict = paymentResult->getDictFromJsonObject
  let clientSecret = paymentResultDict->getString("client_secret", "")
  let paymentId = paymentResultDict->getString("payment_id", "")
  let amount = paymentResultDict->getInt("amount", 0)->Int.toString
  let currency = paymentResultDict->getString("currency", "USD")
  let status = paymentResultDict->getString("status", "incomplete")

  let initialValuesDict = initialValues->getDictFromJsonObject

  let getInitialValue = key => initialValuesDict->getString(key, "")

  {
    amount,
    currency,
    pub_key: publishableKey,
    client_secret: clientSecret,
    payment_id: paymentId,
    session_expiry: getInitialValue("session_expiry"),
    merchant_logo: getInitialValue("logo"),
    return_url: getInitialValue("return_url")->isEmptyString
      ? "https://google.com"
      : getInitialValue("return_url"),
    merchant_name: getInitialValue("seller_name"),
    max_items_visible_after_collapse: initialValuesDict->getInt(
      "max_items_visible_after_collapse",
      3,
    ),
    theme: getInitialValue("theme"),
    sdk_layout: getInitialValue("sdk_layout")->isEmptyString
      ? "accordion"
      : getInitialValue("sdk_layout"),
    display_sdk_only: initialValuesDict->getBool("display_sdk_only", false),
    hide_card_nickname_field: initialValuesDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: initialValuesDict->getBool("show_card_form_by_default", false),
    status,
    enable_button_only_on_form_ready: initialValuesDict->getBool(
      "enable_button_only_on_form_ready",
      false,
    ),
    merchant_description: None,
    locale: None,
    background_image: None,
    details_layout: None,
    branding_visibility: None,
    payment_button_text: None,
    skip_status_screen: None,
    custom_message_for_card_terms: None,
    payment_button_colour: None,
    payment_button_text_colour: None,
    background_colour: None,
    sdk_ui_rules: None,
    payment_form_header_text: None,
    payment_form_label_type: None,
    show_card_terms: None,
    is_setup_mandate_flow: None,
    capture_method: None,
    setup_future_usage_applied: None,
    color_icon_card_cvc_error: None,
  }
}

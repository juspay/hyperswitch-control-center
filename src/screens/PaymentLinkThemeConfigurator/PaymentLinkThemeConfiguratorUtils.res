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

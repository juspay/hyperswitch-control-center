let getConfigFromDict: Dict.t<JSON.t> => HyperSwitchConfigTypes.urlConfig = dict => {
  open LogicUtils
  {
    apiBaseUrl: dict->getString("api_url", ""),
    mixpanelToken: dict->getString("mixpanel_token", ""),
    sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
    agreementUrl: dict->getString("agreement_url", "")->getNonEmptyString,
    dssCertificateUrl: dict->getString("dss_certificate_url", "")->getNonEmptyString,
    dynamoSimulationTemplateUrl: dict
    ->getString("dynamo_simulation_template_url", "")
    ->getNonEmptyString,
    applePayCertificateUrl: dict
    ->getString("apple_pay_certificate_url", "")
    ->getNonEmptyString,
    agreementVersion: dict->getString("agreement_version", "")->getNonEmptyString,
    reconIframeUrl: dict->getString("recon_iframe_url", "")->getNonEmptyString,
    urlThemeConfig: {
      faviconUrl: dict->getString("favicon_url", "")->getNonEmptyString,
      logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
    },
    hypersenseUrl: dict->getString("hypersense_url", ""),
    clarityBaseUrl: dict->getString("clarity_base_url", "")->getNonEmptyString,
  }
}

let getConfigFromDict = (
  dict: Dict.t<JSON.t>,
  ~complianceDict: Dict.t<JSON.t>,
): HyperSwitchConfigTypes.urlConfig => {
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
    whitelabelComplianceConfig: {
      applePayInstructions: complianceDict
      ->getString("apple_pay_instructions", "")
      ->getNonEmptyString,
      applePayRequestTemplate: complianceDict
      ->getString("apple_pay_request_template", "")
      ->getNonEmptyString,
      supportEmail: complianceDict->getString("support_email", "")->getNonEmptyString,
      certificateTitle: complianceDict->getString("certificate_title", "")->getNonEmptyString,
      certificateDownloadFilename: complianceDict
      ->getString("certificate_download_filename", "")
      ->getNonEmptyString,
    },
    hypersenseUrl: dict->getString("hypersense_url", ""),
  }
}

let messageToTypeConversion = messageString => {
  switch messageString->String.toLowerCase {
  | "auth_token" => EmbeddedTypes.AUTH_TOKEN
  | "auth_error" => EmbeddedTypes.AUTH_ERROR
  | "init_config" => EmbeddedTypes.INIT_CONFIG
  | str => EmbeddedTypes.Unknown(str)
  }
}

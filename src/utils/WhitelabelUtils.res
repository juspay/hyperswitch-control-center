let useResolvedProductName = () => {
  let {productName} = React.useContext(ThemeProvider.themeContext)
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  switch productName->Option.flatMap(LogicUtils.getNonEmptyString) {
  | Some(name) => Some(name)
  | None => branding ? None : Some("Hyperswitch")
  }
}

type approvedComplianceConfig = {
  applePayInstructions: string,
  applePayRequestTemplate: string,
  supportEmail: string,
  certificateTitle: string,
  certificateDownloadFilename: string,
  certificateUrl: string,
}

let getApprovedComplianceConfig = (): option<approvedComplianceConfig> => {
  let config = Window.env.whitelabelComplianceConfig
  let applePayInstructions =
    config.applePayInstructions->Option.flatMap(LogicUtils.getNonEmptyString)
  let applePayRequestTemplate =
    config.applePayRequestTemplate->Option.flatMap(LogicUtils.getNonEmptyString)
  let supportEmail = config.supportEmail->Option.flatMap(LogicUtils.getNonEmptyString)
  let certificateTitle = config.certificateTitle->Option.flatMap(LogicUtils.getNonEmptyString)
  let certificateDownloadFilename =
    config.certificateDownloadFilename->Option.flatMap(LogicUtils.getNonEmptyString)
  let certificateUrl = Window.env.dssCertificateUrl->Option.flatMap(LogicUtils.getNonEmptyString)

  switch (
    applePayInstructions,
    applePayRequestTemplate,
    supportEmail,
    certificateTitle,
    certificateDownloadFilename,
    certificateUrl,
  ) {
  | (
      Some(applePayInstructions),
      Some(applePayRequestTemplate),
      Some(supportEmail),
      Some(certificateTitle),
      Some(certificateDownloadFilename),
      Some(certificateUrl),
    )
    if supportEmail->String.includes("@") &&
    certificateDownloadFilename->String.endsWith(".pdf") &&
    !(certificateDownloadFilename->String.includes("/")) &&
    !(certificateDownloadFilename->String.includes("\\")) =>
    Some({
      applePayInstructions,
      applePayRequestTemplate,
      supportEmail,
      certificateTitle,
      certificateDownloadFilename,
      certificateUrl,
    })
  | _ => None
  }
}

let isCustomComplianceAvailable = () => getApprovedComplianceConfig()->Option.isSome

open LogicUtils

/*
Whitelabelling helpers, all keyed off the `branding` feature flag.

`branding=false` is the hosted Hyperswitch deployment and behaves exactly as before.
`branding=true` strips every Hyperswitch identity, outbound link and compliance claim
from the dashboard. An optional `product_name` feature flag supplies the deployment's
own name for the identity copy; without it the copy falls back to neutral wording.
*/

/* None => render neutral copy, Some(name) => substitute the name */
let useProductName = () => {
  let {branding, productName} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  switch productName->getNonEmptyString {
  | Some(name) => Some(name)
  | None => branding ? None : Some("Hyperswitch")
  }
}

/* Whether Hyperswitch owned resources (docs, blog, Slack, support, legal) may be linked */
let useShowHyperswitchResources = () => {
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  !branding
}

let hyperswitchResourceHosts = ["hyperswitch.io", "hyperswitch-io.slack.com", "juspay.in"]

/* Whether a URL points at a Hyperswitch owned resource, and so must be hidden on a
 branded deployment. Merchant configured URLs are left alone. */
let isHyperswitchResourceUrl = url =>
  hyperswitchResourceHosts->Array.some(host => url->String.includes(host))

type approvedComplianceConfig = {
  applePayInstructions: string,
  applePayRequestTemplate: string,
  supportEmail: string,
  certificateTitle: string,
}

/*
Merchant owned compliance content, read from [default.whitelabel_compliance].

A whitelabeled deployment is not covered by Hyperswitch's PCI attestation, so the
compliance UI must never fall back to Hyperswitch's own certificates or email template.
This returns Some only when the whole block is supplied and at least one certificate URL
is configured - a partially filled block fails closed and the UI stays hidden.
*/
let getApprovedComplianceConfig = (): option<approvedComplianceConfig> => {
  let config = Window.env.whitelabelCompliance
  let hasCertificateUrl =
    Window.env.dssCertificateUsUrl->Option.isSome || Window.env.dssCertificateEuUrl->Option.isSome

  switch (
    config.applePayInstructions,
    config.applePayRequestTemplate,
    config.supportEmail,
    config.certificateTitle,
  ) {
  | (
      Some(applePayInstructions),
      Some(applePayRequestTemplate),
      Some(supportEmail),
      Some(certificateTitle),
    ) if hasCertificateUrl && supportEmail->String.includes("@") =>
    Some({applePayInstructions, applePayRequestTemplate, supportEmail, certificateTitle})
  | _ => None
  }
}

let isCustomComplianceAvailable = () => getApprovedComplianceConfig()->Option.isSome

/*
Compliance content may render when this is a hosted deployment, or when a branded
deployment has supplied its own approved content.
*/
let isComplianceContentAllowed = (~branding) => !branding || isCustomComplianceAvailable()

let useIsComplianceContentAllowed = () => {
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  isComplianceContentAllowed(~branding)
}

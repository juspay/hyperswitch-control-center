@val external appVersion: string = "appVersion"

let mixpanelToken = "773ae99db494f9e23d86ab7a160bc21b"
let tag_ID = "G-KW7THEZCZ2"

type hostType = Integ | Live | Sandbox | Local | Netlify

let hostName = Window.Location.hostname

let hostType = switch hostName {
| "integ.hyperswitch.io" => Integ
| "live.hyperswitch.io" => Live
| "app.hyperswitch.io" => Sandbox
| _ => hostName->Js.String2.includes("netlify") ? Netlify : Local
}

let getHostURLFromVariant = (host: hostType) => {
  switch host {
  | Integ => "https://integ.hyperswitch.io"
  | Live => "https://live.hyperswitch.io"
  | Sandbox => "https://app.hyperswitch.io"
  | Netlify => `https://${hostName}`
  | Local => `${Window.Location.origin}`
  }
}

let integURL = Integ->getHostURLFromVariant
let liveURL = Live->getHostURLFromVariant
let sandboxURL = Sandbox->getHostURLFromVariant
let localURL = Local->getHostURLFromVariant
let netlifyUrl = Netlify->getHostURLFromVariant

let isHyperSwitchDashboard = GlobalVars.dashboardAppName === #hyperswitch

let hyperSwitchApiPrefix = Window.env.apiBaseUrl->Belt.Option.getWithDefault("/api")

let dashboardUrl = switch hostType {
| Live => Live->getHostURLFromVariant
| Sandbox => Sandbox->getHostURLFromVariant
| Integ | Netlify | Local => Integ->getHostURLFromVariant
}

let hyperSwitchFEPrefix = switch hostType {
| Integ => integURL
| Live => liveURL
| Sandbox => sandboxURL
| Local => localURL
| Netlify => netlifyUrl
}

let hyperSwitchversion = appVersion->Js.String2.length > 0 ? `v${appVersion}` : ""

let playgroundUserEmail = "dummyuser@dummymerchant.com"
let playgroundUserPassword = "Dummy@1234"

let urlFordownloadingAgreementMapper = switch hostType {
| Integ => "https://integ.hyperswitch.io/agreement/MerchantAgreement.pdf"
| Sandbox => "https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
| Live => "https://live.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
| _ => ""
}

let urlToDownloadApplePayCertificate = switch hostType {
| Integ => "https://integ.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| Sandbox => "https://app.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| Live => "https://live.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| _ => "/apple-developer-merchantid-domain-association"
}

let recoEmail = "biz@hyperswitch.io"
let agreementVersion = "1.1.0"

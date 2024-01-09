@val external appVersion: string = "appVersion"

let mixpanelToken = Window.env.mixpanelToken->Belt.Option.getWithDefault("mixpanel-token")

type hostType = Live | Sandbox | Local | Netlify

let hostName = Window.Location.hostname

let hostType = switch hostName {
| "live.hyperswitch.io" => Live
| "app.hyperswitch.io" => Sandbox
| _ => hostName->String.includes("netlify") ? Netlify : Local
}

let getHostURLFromVariant = (host: hostType) => {
  switch host {
  | Live => "https://live.hyperswitch.io"
  | Sandbox => "https://app.hyperswitch.io"
  | Netlify => `https://${hostName}`
  | Local => `${Window.Location.origin}`
  }
}

let liveURL = Live->getHostURLFromVariant
let sandboxURL = Sandbox->getHostURLFromVariant
let localURL = Local->getHostURLFromVariant
let netlifyUrl = Netlify->getHostURLFromVariant

let isHyperSwitchDashboard = GlobalVars.dashboardAppName === #hyperswitch

let hyperSwitchApiPrefix = Window.env.apiBaseUrl->Belt.Option.getWithDefault("/api")

let dashboardUrl = switch hostType {
| Live => Live->getHostURLFromVariant
| Sandbox | Local | Netlify => Sandbox->getHostURLFromVariant
}

let hyperSwitchFEPrefix = switch hostType {
| Live => liveURL
| Sandbox => sandboxURL
| Local => localURL
| Netlify => netlifyUrl
}

let playgroundUserEmail = "dummyuser@dummymerchant.com"
let playgroundUserPassword = "Dummy@1234"

let urlFordownloadingAgreementMapper = switch hostType {
| Sandbox => "https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
| Live => "https://live.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
| _ => "https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
}

let urlToDownloadApplePayCertificate = switch hostType {
| Sandbox => "https://app.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| Live => "https://live.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| _ => "/apple-developer-merchantid-domain-association"
}

let agreementVersion = "1.1.0"

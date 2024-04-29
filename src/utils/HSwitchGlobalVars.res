@val external appVersion: string = "appVersion"

let dashboardBasePath = Some("/dashboard")

let appendDashboardPath = (~url) => {
  switch dashboardBasePath {
  | Some(dashboardBaseUrl) => `${dashboardBaseUrl}${url}`
  | None => url
  }
}

let mixpanelToken = Window.env.mixpanelToken->Option.getOr("mixpanel-token")

type hostType = Live | Sandbox | Local | Netlify

let hostName = Window.Location.hostname

let hostType = switch hostName {
| "live.hyperswitch.io" => Live
| "app.hyperswitch.io" => Sandbox
| _ => hostName->String.includes("netlify") ? Netlify : Local
}

let getHostUrlWithBasePath = `${Window.Location.origin}${appendDashboardPath(~url="")}`

let getHostUrl = Window.Location.origin

let isHyperSwitchDashboard = GlobalVars.dashboardAppName === #hyperswitch

let hyperSwitchApiPrefix = Window.env.apiBaseUrl->Option.getOr("/api")

let playgroundUserEmail = "dummyuser@dummymerchant.com"
let playgroundUserPassword = "Dummy@1234"

let urlFordownloadingAgreementMapper = switch hostType {
| Sandbox => "https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
| Live => "https://live.hyperswitch.io/agreement/tc-hyperswitch-apr-24.pdf"
| _ => "https://app.hyperswitch.io/agreement/tc-hyperswitch-aug-23.pdf"
}

let urlToDownloadApplePayCertificate = switch hostType {
| Sandbox => "https://app.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| Live => "https://live.hyperswitch.io/applepay-domain/apple-developer-merchantid-domain-association"
| _ => "/apple-developer-merchantid-domain-association"
}

let agreementVersion = "2.0.0"

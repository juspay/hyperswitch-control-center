@val external appVersion: string = "appVersion"

let dashboardBasePath = Some("/dashboard")

let appendTrailingSlash = url => {
  url->String.startsWith("/") ? url : `/${url}`
}

let appendDashboardPath = (~url) => {
  switch dashboardBasePath {
  | Some(dashboardBaseUrl) =>
    if url->String.length === 0 {
      dashboardBaseUrl
    } else {
      `${dashboardBaseUrl}${url->appendTrailingSlash}`
    }
  | None => url
  }
}

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

let maximumRecoveryCodes = 8

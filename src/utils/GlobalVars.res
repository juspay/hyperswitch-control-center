@val external appVersion: string = "appVersion"

type appName = [
  | #hyperswitch
]

type appEnv = [#production | #sandbox | #integration | #development]

@val external dashboardAppName: appName = "dashboardAppName"

let isLocalhost =
  Window.Location.hostname === "localhost" || Window.Location.hostname === "127.0.0.1"

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

let isHyperSwitchDashboard = dashboardAppName === #hyperswitch

let playgroundUserEmail = "dummyuser@dummymerchant.com"
let playgroundUserPassword = "Dummy@1234"

let maximumRecoveryCodes = 8

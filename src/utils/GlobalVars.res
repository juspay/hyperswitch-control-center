@val external appVersion: string = "appVersion"

type appName = [
  | #hyperswitch
]

type appEnv = [#production | #sandbox | #integration | #development]

@val external dashboardAppName: appName = "dashboardAppName"

let isLocalhost =
  Window.Location.hostname === "localhost" || Window.Location.hostname === "127.0.0.1"

let dashboardPrefix = "dashboard"
let dashboardBasePath = Some(`/${dashboardPrefix}`)

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

let extractModulePath = (url: RescriptReactRouter.url) => {
  let currentPathList = url.path->List.toArray

  /* condition is added to check for v2 routes . Eg: /v2/${productName}/${routeName} */
  let modulePath = if currentPathList->Array.includes("v2") {
    currentPathList->Array.slice(~start=0, ~end=4)->Array.joinWith("/")->appendTrailingSlash
  } else if currentPathList->Array.includes(dashboardPrefix) {
    currentPathList->Array.slice(~start=0, ~end=2)->Array.joinWith("/")->appendTrailingSlash
  } else {
    currentPathList->Array.slice(~start=0, ~end=1)->Array.joinWith("/")->appendTrailingSlash
  }
  Js.log2("modulePath", modulePath)
  modulePath
}

type hostType = Live | Sandbox | Local | Integ

let hostName = Window.Location.hostname

let hostType = switch hostName {
| "live.hyperswitch.io" => Live
| "app.hyperswitch.io" => Sandbox
| "integ.hyperswitch.io" => Integ

| _ => Local
}

let getEnvironment = hostType =>
  switch hostType {
  | Live => "production"
  | Sandbox => "sandbox"
  | Integ => "integ"
  | Local => "localhost"
  }
let getHostUrlWithBasePath = `${Window.Location.origin}${appendDashboardPath(~url="")}`

let getHostUrl = Window.Location.origin

let isHyperSwitchDashboard = dashboardAppName === #hyperswitch

let playgroundUserEmail = "dummyuser@dummymerchant.com"
let playgroundUserPassword = "Dummy@1234"

let maximumRecoveryCodes = 8

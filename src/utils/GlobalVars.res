type appName = [
  | #hyperswitch
]

type appEnv = [#production | #sandbox | #integration | #development]

@val external dashboardAppName: appName = "dashboardAppName"

let isLocalhost =
  Window.Location.hostname === "localhost" || Window.Location.hostname === "127.0.0.1"

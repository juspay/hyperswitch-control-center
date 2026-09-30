open MonitoringTypes

type url
@new external makeUrl: string => url = "URL"
@get external origin: url => string = "origin"
@get external pathname: url => string = "pathname"
@get external username: url => string = "username"
@get external password: url => string = "password"
@get external href: url => string = "href"
@get external search: url => string = "search"
@set external setSearch: (url, string) => unit = "search"
type searchParams
@get external searchParams: url => searchParams = "searchParams"
@send external setParam: (searchParams, string, string) => unit = "set"

let destinations = [Explore, ApiHealth, ConnectorPerformance, BusinessMetrics, SystemHealth]

let getId = destination =>
  switch destination {
  | Explore => "explore"
  | ApiHealth => "api_health"
  | ConnectorPerformance => "connector_performance"
  | BusinessMetrics => "business_metrics"
  | SystemHealth => "system_health"
  }

let getSlug = destination => getId(destination)->String.split("_")->Array.joinWith("-")

let getTitle = destination =>
  switch destination {
  | Explore => "Explore"
  | ApiHealth => "API Health"
  | ConnectorPerformance => "Connector Performance"
  | BusinessMetrics => "Business Metrics"
  | SystemHealth => "System Health"
  }

let fromSlug = slug => destinations->Array.find(destination => getSlug(destination) === slug)

// Only the configured same-origin gateway can receive the browser's Grafana cookie.
let getEmbedUrl = (~embedUrl, ~theme) => {
  try {
    let url = makeUrl(embedUrl)
    let currentUrl = makeUrl(Window.Location.href)
    if (
      url->origin !== currentUrl->origin ||
      !(url->pathname->String.startsWith("/api/observability-plane/grafana/")) ||
      url->username !== "" ||
      url->password !== ""
    ) {
      None
    } else {
      url->searchParams->setParam("kiosk", "")
      url->searchParams->setParam("theme", theme)
      // Grafana distinguishes the bare kiosk flag from an empty kiosk= value.
      url->setSearch(
        url->search->String.replace("?kiosk=", "?kiosk")->String.replace("&kiosk=", "&kiosk"),
      )
      Some(url->href)
    }
  } catch {
  | _ => None
  }
}

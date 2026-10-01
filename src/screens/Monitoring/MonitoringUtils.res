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
      // Preserve backend-owned parameters, including Grafana's bare kiosk flag.
      let params =
        url
        ->search
        ->String.sliceToEnd(~start=1)
        ->String.split("&")
        ->Array.filter(param =>
          param !== "" && param !== "theme" && !(param->String.startsWith("theme="))
        )
      url->setSearch(`?${params->Array.concat([`theme=${theme}`])->Array.joinWith("&")}`)
      Some(url->href)
    }
  } catch {
  | _ => None
  }
}

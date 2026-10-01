open MonitoringTypes

module Url = Webapi.Url

let destinations = [Explore, ApiHealth, ConnectorPerformance, BusinessMetrics, SystemHealth]

let getId = destination =>
  switch destination {
  | Explore => "explore"
  | ApiHealth => "api_health"
  | ConnectorPerformance => "connector_performance"
  | BusinessMetrics => "business_metrics"
  | SystemHealth => "system_health"
  }

let getRouteSlug = destination => getId(destination)->String.split("_")->Array.joinWith("-")

let getTitle = destination =>
  switch destination {
  | Explore => "Explore"
  | ApiHealth => "API Health"
  | ConnectorPerformance => "Connector Performance"
  | BusinessMetrics => "Business Metrics"
  | SystemHealth => "System Health"
  }

let getDestinationFromRouteSlug = slug =>
  destinations->Array.find(destination => getRouteSlug(destination) === slug)

// Only the configured same-origin gateway can receive the browser's Grafana cookie.
let getEmbedUrl = (~embedUrl, ~theme) => {
  try {
    let url = Url.make(embedUrl)
    let currentUrl = Url.make(Window.Location.href)
    if (
      embedUrl->String.trim->String.startsWith("//") ||
      url->Url.origin !== currentUrl->Url.origin ||
      !(url->Url.pathname->String.startsWith("/api/observability-plane/grafana/")) ||
      url->Url.username !== "" ||
      url->Url.password !== ""
    ) {
      None
    } else {
      // Preserve backend-owned parameters, including Grafana's bare kiosk flag.
      let params =
        url
        ->Url.search
        ->String.sliceToEnd(~start=1)
        ->String.split("&")
        ->Array.filter(param =>
          param !== "" && param !== "theme" && !(param->String.startsWith("theme="))
        )
      url->Url.setSearch(`?${params->Array.concat([`theme=${theme}`])->Array.joinWith("&")}`)
      Some(url->Url.href)
    }
  } catch {
  | _ => None
  }
}

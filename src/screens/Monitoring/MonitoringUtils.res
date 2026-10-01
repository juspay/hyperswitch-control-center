open MonitoringTypes

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

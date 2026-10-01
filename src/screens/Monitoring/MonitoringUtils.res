open MonitoringTypes

let destinations = [Explore, ApiHealth, ConnectorPerformance, BusinessMetrics, SystemHealth]

let getTitle = (destination: destination) =>
  (destination :> string)
  ->LogicUtils.camelCaseToTitle
  ->String.replace("Api Health", "API Health")

let getId = destination => getTitle(destination)->LogicUtils.titleToSnake

let getRouteSlug = destination => getId(destination)->String.split("_")->Array.joinWith("-")

let getDestinationFromRouteSlug = slug =>
  destinations->Array.find(destination => getRouteSlug(destination) === slug)

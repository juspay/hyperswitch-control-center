open MonitoringTypes
open LogicUtils

let destinations = [Explore, ApiHealth, ConnectorPerformance, BusinessMetrics, SystemHealth]

let getTitle = (destination: destination) =>
  (destination :> string)
  ->camelCaseToTitle
  ->String.replace("Api Health", "API Health")

let getId = (destination, ~separator="_") =>
  getTitle(destination)->titleToSnake->String.split("_")->Array.joinWith(separator)

let getDestinationFromRouteId = viewId =>
  destinations->Array.find(destination => getId(destination, ~separator="-") === viewId)

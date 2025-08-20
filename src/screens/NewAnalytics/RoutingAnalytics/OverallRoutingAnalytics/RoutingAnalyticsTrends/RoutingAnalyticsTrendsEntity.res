open RoutingAnalyticsTrendsTypes
let routingSuccessRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Routing Success Rate",
}

let routingSuccessRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: RoutingAnalyticsTrendsUtils.routingSuccessRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let routingVolumeEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Routing Volume",
}

let routingVolumeChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: RoutingAnalyticsTrendsUtils.routingVolumeMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

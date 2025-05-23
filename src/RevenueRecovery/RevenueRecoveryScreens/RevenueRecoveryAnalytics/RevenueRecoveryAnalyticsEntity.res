open InsightsTypes
open BarGraphTypes

// Retries Comparision
let retriesComparisionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Static vs Smart Retries",
  domain: #payments,
}

let retriesComparisionChartEntity: chartEntity<
  LineScatterGraphTypes.lineScatterGraphPayload,
  LineScatterGraphTypes.lineScatterGraphOptions,
  JSON.t,
> = {
  getObjects: RetriesComparisionAnalyticsUtils.staticRetriesComparisionMapper,
  getChatOptions: LineScatterGraphUtils.getLineGraphOptions,
}

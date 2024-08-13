open PerformanceMonitorTypes
open LogicUtils

let getDimensionNameFromString = dimension => {
  switch dimension {
  | "connector" => #connector
  | "payment_method" => #payment_method
  | "payment_method_type" => #payment_method_type
  | "status" => #status
  | _ => #no_value
  }
}

let dimensionMapper = dict => {
  dimension: dict->getString("dimension", "")->getDimensionNameFromString,
  values: dict->getStrArray("values"),
}
let dimensionObjMapper = (dimensions: array<JSON.t>) => {
  dimensions->JSON.Encode.array->getArrayDataFromJson(dimensionMapper)
}

let defaultDimesions = {
  dimension: #no_value,
  values: [],
}

let getStatusPerformanceEntity: entity<stackBarChartData> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status],
    filters: [#status],
    customFilter: None,
    applyFilterFor: None,
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#status],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  title: "Payment Distribution By Status",
  chartOption: {
    colors: [],
  },
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getPerformanceEntity = (
  ~groupBy: array<dimension>,
  ~filters: array<dimension>,
  ~groupByKeys: array<dimension>,
  ~title: string,
): entity<stackBarChartData> => {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status, ...groupBy],
    filters: [#status, ...filters],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure", "charged"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [...groupByKeys],
    plotChartBy: ["failure", "charged"],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  title,
  chartOption: {
    colors: [],
  },
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getConnectorFailureEntity: entity<array<donutPieSeriesRecord>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Connector Wise Payment Failure",
  chartOption: {
    colors: [],
  },
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

let getPaymentMethodFailureEntity: entity<array<donutPieSeriesRecord>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Method Wise Payment Failure",
  chartOption: {
    colors: [],
  },
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

let getConnectorPaymentMethodFailureEntity: entity<array<donutPieSeriesRecord>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #payment_method, #status],
    filters: [#connector, #payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector, #payment_method],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Connector + Payment Method Wise Payment Failure",
  chartOption: {
    colors: [],
  },
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

let getFailureRateEntity: entity<'t> = {
  getRequestBody: PerformanceUtils.requestBody,
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  requestBodyConfig: {
    metrics: [#connector_success_rate],
    groupBy: [],
    filters: [],
    customFilter: None,
    applyFilterFor: None,
  },
  configRequiredForChartData: {
    groupByKeys: [],
  },
  title: "Payment Failures",
  chartOption: {
    colors: [],
  },
}

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

let colors = ["#f44708", "#8ac926"]

let getFailureRateEntity: entity<'t> = {
  getChartData: GaugeChartPerformanceUtils.getGaugeData,
  requestBodyConfig: {
    metrics: [#payment_success_rate],
    groupBy: [],
    filters: [],
    delta: true,
    customFilter: None,
    applyFilterFor: None,
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #payment_success_rate,
  },
  chartConfig: {
    title: "Payment Failures",
    colors: [],
  },
}

let getSuccessRatePerformanceEntity: entity<'t> = {
  getChartData: GaugeChartPerformanceUtils.getGaugeData,
  requestBodyConfig: {
    metrics: [#payment_success_rate],
    groupBy: [],
    filters: [],
    delta: true,
    customFilter: None,
    applyFilterFor: None,
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #payment_success_rate,
  },
  chartConfig: {
    title: "Payment Success Rate",
    colors: [],
  },
}

let getRefundsSuccessRatePerformanceEntity: entity<'t> = {
  getChartData: GaugeChartPerformanceUtils.getGaugeData,
  requestBodyConfig: {
    metrics: [#refund_success_rate],
    groupBy: [],
    filters: [],
    delta: true,
    customFilter: None,
    applyFilterFor: None,
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #refund_success_rate,
  },
  chartConfig: {
    title: "Refund Success Rate",
    colors: [],
  },
}

let getStatusPerformanceEntity: entity<'t> = {
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status],
    filters: [#status],
    customFilter: None,
    applyFilterFor: None,
  },
  configRequiredForChartData: {
    groupByKeys: [#status],
  },
  chartConfig: {
    title: "Payment Distribution By Connector",
    colors: [
      "#7856FF",
      "#FF7557",
      "#80E1D9",
      "#F8BC3B",
      "#B2596E",
      "#72BEF4",
      "#FFB27A",
      "#0D7EA0",
      "#3BA974",
      "#FEBBB2",
      "#CA80DC",
      "#5BB7AF",
    ],
  },
}

let getConnectorPerformanceEntity: entity<'t> = {
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure", "charged"]),
  },
  configRequiredForChartData: {
    groupByKeys: [#connector],
    plotChartBy: ["failure", "charged"],
  },
  chartConfig: {
    title: "Payment Distribution By Status",
    colors: ["#f44708", "#8ac926"],
  },
}

let getPaymentMethodPerformanceEntity: entity<'t> = {
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["charged", "failure"]),
  },
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
    plotChartBy: ["failure", "charged"],
  },
  chartConfig: {
    title: "Payment Distribution By Payment Method",
    colors: ["#f44708", "#8ac926"],
  },
}

let getConnectorFailureEntity: entity<'t> = {
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  configRequiredForChartData: {
    groupByKeys: [#connector],
  },
  chartConfig: {
    title: "Connector Wise Payment Failure",
    colors: [
      "#7856FF",
      "#FF7557",
      "#80E1D9",
      "#F8BC3B",
      "#B2596E",
      "#72BEF4",
      "#FFB27A",
      "#0D7EA0",
      "#3BA974",
      "#FEBBB2",
      "#CA80DC",
      "#5BB7AF",
    ],
  },
}

let getPaymentMethodFailureEntity: entity<'t> = {
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
  },
  chartConfig: {
    title: "Method Wise Payment Failure",
    colors: [
      "#7856FF",
      "#FF7557",
      "#80E1D9",
      "#F8BC3B",
      "#B2596E",
      "#72BEF4",
      "#FFB27A",
      "#0D7EA0",
      "#3BA974",
      "#FEBBB2",
      "#CA80DC",
      "#5BB7AF",
    ],
  },
}

let getConnectorPaymentMethodFailureEntity: entity<'t> = {
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #payment_method, #status],
    filters: [#connector, #payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  configRequiredForChartData: {
    groupByKeys: [#connector, #payment_method],
  },
  chartConfig: {
    title: "Connector + Payment Method Wise Payment Failure",
    colors: [
      "#7856FF",
      "#FF7557",
      "#80E1D9",
      "#F8BC3B",
      "#B2596E",
      "#72BEF4",
      "#FFB27A",
      "#0D7EA0",
      "#3BA974",
      "#FEBBB2",
      "#CA80DC",
      "#5BB7AF",
    ],
  },
}

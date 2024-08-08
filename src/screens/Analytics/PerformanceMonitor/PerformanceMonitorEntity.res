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

let colors = ["#c74050", "#619f5b"]

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
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Distribution By Connector",
    },
    colors: ["#c74050", "#619f5b", "#ca8a04", "#06b6d4"],
  },
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getConnectorPerformanceEntity: entity<stackBarChartData> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure", "charged"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector],
    plotChartBy: ["failure", "charged"],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Distribution By Connector",
    },
    colors: ["#c74050", "#619f5b"],
  },
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getPaymentMethodPerformanceEntity: entity<stackBarChartData> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["charged", "failure"]),
  },
  getRequestBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
    plotChartBy: ["failure", "charged"],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Distribution By Payment Method",
    },
    colors: ["#c74050", "#619f5b"],
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
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Connector Wise Payment Failure",
    },
    colors: ["#c74050", "#619f5b"],
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
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Method Wise Payment Failure",
    },
    colors: ["#c74050", "#619f5b"],
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
  chartOption: {
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Connector + Payment Method Wise Payment Failure",
    },
    colors: ["#c74050", "#619f5b"],
  },
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

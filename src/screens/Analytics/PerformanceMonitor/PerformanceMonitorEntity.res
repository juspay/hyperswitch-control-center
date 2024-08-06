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
let getConnectorPerformanceEntity: entity<'t> = {
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["charged", "failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  dataConfig: {
    key: "connector",
    chartSeries: ["failure", "charged"],
  },
  chartConfig: {
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
  getBody: PerformanceUtils.requestBody,
  dataConfig: {
    key: "payment_method",
    chartSeries: ["failure", "charged"],
  },
  chartConfig: {
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
}

let getConnectorFailureEntity: entity<'t> = {
  getChartData: DontcharPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  dataConfig: {
    key: "connector",
    chartSeries: ["failure"],
  },
  chartConfig: {
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
}

let getPaymentMethodFailureEntity: entity<'t> = {
  getChartData: DontcharPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  dataConfig: {
    key: "payment_method",
    chartSeries: ["failure"],
  },
  chartConfig: {
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
}

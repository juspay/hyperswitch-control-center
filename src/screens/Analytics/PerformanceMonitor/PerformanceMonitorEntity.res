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

let getStatusPerformanceEntity: entity<'t> = {
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status],
    filters: [#status],
    customFilter: None,
    applyFilterFor: None,
  },
  getBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#status],
    // plotChartBy: ["failure"],
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
    colors: ["#c74050", "#619f5b", "#ca8a04", "#06b6d4"],
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
  getBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector],
    plotChartBy: ["failure", "charged"],
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
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
    plotChartBy: ["failure", "charged"],
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
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector],
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
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
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

let getConnectorPaymentMethodFailureEntity: entity<'t> = {
  getChartData: PieChartPerformanceUtils.getPieCharData,
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #payment_method, #status],
    filters: [#connector, #payment_method, #status],
    customFilter: Some(#status),
    applyFilterFor: Some(["failure"]),
  },
  getBody: PerformanceUtils.requestBody,
  configRequiredForChartData: {
    groupByKeys: [#connector, #payment_method],
  },
  chartConfig: {
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
}

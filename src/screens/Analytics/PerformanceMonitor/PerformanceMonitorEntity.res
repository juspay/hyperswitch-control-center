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
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Failures",
    },
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
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Success Rate",
    },
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
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Refund Success Rate",
    },
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
    yAxis: {
      text: "",
    },
    xAxis: {
      text: "",
    },
    title: {
      text: "Payment Distribution By Connector",
    },
    colors: ["#264653", "#619f5b", "#e9c46a", "#f4a261", "#06d6a0", "#c74050"],
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

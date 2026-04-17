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

let defaultDimensions = {
  dimension: #no_value,
  values: [],
}

let getSuccessRatePerformanceEntity: entity<gaugeData, option<string>> = {
  getChartData: GaugeChartPerformanceUtils.getGaugeData,
  requestBodyConfig: {
    delta: true,
    metrics: [#connector_success_rate],
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #connector_success_rate,
  },
  title: "Payment Success Rate",
  getChartOption: GaugeChartPerformanceUtils.gaugeOption,
}

let overallPaymentCount: entity<gaugeData, option<string>> = {
  getChartData: GaugeChartPerformanceUtils.getGaugeData,
  requestBodyConfig: {
    delta: true,
    metrics: [#payment_count],
    filters: [#status],
    excludeFilterValue: [#payment_method_awaited],
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #payment_count,
  },
  title: "Overall Payment Count",
  getChartOption: GaugeFailureRateUtils.failureGaugeOption,
}

let getFailureRateEntity: entity<gaugeData, float> = {
  getChartData: GaugeFailureRateUtils.getFailureRateData,
  requestBodyConfig: {
    metrics: [#payment_count],
    filters: [#status],
    customFilter: #status,
    applyFilterFor: [#failure],
  },
  configRequiredForChartData: {
    groupByKeys: [],
    name: #payment_count,
  },
  title: "Payments Failure Rate",
  getChartOption: GaugeFailureRateUtils.failureGaugeOption,
}

let getStatusPerformanceEntity: entity<stackBarChartData, option<string>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status],
    filters: [#status],
    excludeFilterValue: [#payment_method_awaited],
  },
  configRequiredForChartData: {
    groupByKeys: [#status],
    yLabels: ["Status"],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  title: "Payment Distribution By Status",
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getPerformanceEntity = (
  ~groupBy: array<dimension>,
  ~filters: array<dimension>,
  ~groupByKeys: array<dimension>,
  ~title: string,
): entity<stackBarChartData, option<string>> => {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#status, ...groupBy],
    filters: [#status, ...filters],
    customFilter: #status,
    applyFilterFor: [#failure, #charged],
  },
  configRequiredForChartData: {
    groupByKeys: [...groupByKeys],
    plotChartBy: [#failure, #charged],
  },
  getChartData: BarChartPerformanceUtils.getStackedBarData,
  title,
  getChartOption: BarChartPerformanceUtils.getBarOption,
}

let getConnectorFailureEntity: entity<array<donutPieSeriesRecord>, option<string>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #status],
    filters: [#connector, #status],
    customFilter: #status,
    applyFilterFor: [#failure],
  },
  configRequiredForChartData: {
    groupByKeys: [#connector],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Connector Wise Payment Failure",
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

let getPaymentMethodFailureEntity: entity<array<donutPieSeriesRecord>, option<string>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#payment_method, #status],
    filters: [#payment_method, #status],
    customFilter: #status,
    applyFilterFor: [#failure],
  },
  configRequiredForChartData: {
    groupByKeys: [#payment_method],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Method Wise Payment Failure",
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

let getConnectorPaymentMethodFailureEntity: entity<array<donutPieSeriesRecord>, option<string>> = {
  requestBodyConfig: {
    metrics: [#payment_count],
    groupBy: [#connector, #payment_method, #status],
    filters: [#connector, #payment_method, #status],
    customFilter: #status,
    applyFilterFor: [#failure],
  },
  configRequiredForChartData: {
    groupByKeys: [#connector, #payment_method],
  },
  getChartData: PieChartPerformanceUtils.getDonutCharData,
  title: "Connector + Payment Method Wise Payment Failure",
  getChartOption: PieChartPerformanceUtils.getPieChartOptions,
}

type errorObject = {
  reason: string,
  count: int,
  connector: string,
}

type cols =
  | ErrorReason
  | Count
  | Connector

let visibleColumns = [Connector, ErrorReason, Count]

let colMapper = (col: cols) => {
  switch col {
  | ErrorReason => "reason"
  | Count => "count"
  | Connector => "connector"
  }
}

let getTableData = (array: array<JSON.t>) => {
  let data = []

  array->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let connector = valueDict->getString((#connector: dimension :> string), "")
    let paymentErrorMessage =
      valueDict->getArrayFromDict((#payment_error_message: distribution :> string), [])

    if connector->isNonEmptyString && paymentErrorMessage->Array.length > 0 {
      paymentErrorMessage->Array.forEach(value => {
        let errorDict = value->getDictFromJsonObject

        let obj = {
          reason: errorDict->getString(ErrorReason->colMapper, ""),
          count: errorDict->getInt(Count->colMapper, 0),
          connector,
        }

        data->Array.push(obj)
      })
    }
  })

  data->Array.sort((a, b) => {
    let rowValue_a = a.count
    let rowValue_b = b.count

    rowValue_a <= rowValue_b ? 1. : -1.
  })

  data
}

let tableItemToObjMapper: 'a => errorObject = dict => {
  {
    reason: dict->getString(ErrorReason->colMapper, "NA"),
    count: dict->getInt(Count->colMapper, 0),
    connector: dict->getString(Connector->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<errorObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | ErrorReason => Table.makeHeaderInfo(~key, ~title="Error Reason", ~dataType=TextType)
  | Count => Table.makeHeaderInfo(~key, ~title="Total Occurrences", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  }
}

let getCell = (errorObj, colType): Table.cell => {
  switch colType {
  | ErrorReason => Text(errorObj.reason)
  | Count => Text(errorObj.count->Int.toString)
  | Connector => Text(errorObj.connector)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
)

let getFailureEntity: entity<array<errorObject>, option<string>> = {
  getChartOption: _ => Dict.make()->JSON.Encode.object,
  getChartData: (~args as _) => [],
  requestBodyConfig: {
    metrics: [#connector_success_rate],
    groupBy: [#connector],
    distribution: {
      distributionFor: (#payment_error_message: distribution :> string),
      distributionCardinality: (#TOP_5: distribution :> string),
    },
  },
  configRequiredForChartData: {
    groupByKeys: [#connector],
  },
  title: "Payment Failures",
}

open InsightsTypes

// Normalized Decline Distribution
let normalizedDeclineDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#normalized_failure_reasons],
    groupBy: [#standardised_code],
  },
  title: "Normalized Decline Distribution",
  domain: #payments,
}

let normalizedDeclineDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: NormalizedDeclineDistributionUtils.normalizedDeclineMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let normalizedDeclineTableEntity = {
  open NormalizedDeclineDistributionUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=[],
    ~requiredSearchFieldsList=[],
    ~allColumns=[],
    ~getCell,
    ~getHeading,
  )
}

// Connector Decline Matrix
let connectorDeclineMatrixEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#normalized_failure_reasons],
    groupBy: [#standardised_code, #connector],
  },
  title: "Connector vs Decline Matrix",
  domain: #payments,
}

let connectorDeclineMatrixChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: ConnectorDeclineMatrixUtils.connectorDeclineMapper,
  getChatOptions: ConnectorDeclineMatrixUtils.getStackedBarGraphOptions,
}

let connectorDeclineMatrixTableEntity = {
  open ConnectorDeclineMatrixUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=[],
    ~requiredSearchFieldsList=[],
    ~allColumns=[],
    ~getCell,
    ~getHeading,
  )
}

// Retry Effectiveness by Error Type
let retryEffectivenessEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#retry_success_rate_by_error_type],
    groupBy: [#standardised_code, #error_category],
  },
  title: "Retry Effectiveness by Error Type",
  domain: #payments,
}

// Retry Performance by Connector
let retryByConnectorEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#retry_success_rate_by_connector],
    groupBy: [#connector],
  },
  title: "Retry Performance by Connector",
  domain: #payments,
}

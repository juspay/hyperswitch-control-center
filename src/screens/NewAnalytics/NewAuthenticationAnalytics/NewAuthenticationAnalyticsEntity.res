// SCA Exemption
open NewAuthenticationAnalyticsTypes

let scaExemptionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [
      #authentication_count,
      #authentication_success_count,
      #authentication_exemption_requested_count,
      #authentication_exemption_approved_count,
      #authentication_attempt_count,
    ],
  },
  title: "Exemption Flowchart",
  description: "Breakdown of ThreeDS 2.0 Journey",
  domain: #payments,
}

let scaExemptionChartEntity: chartEntity<
  SankeyGraphTypes.sankeyPayload,
  SankeyGraphTypes.sankeyGraphOptions,
  SCAExemptionAnalyticsTypes.scaExemption,
> = {
  getObjects: SCAExemptionAnalyticsUtils.scaExemptionMapper,
  getChatOptions: SankeyGraphUtils.getSankyGraphOptions,
}

// Authentication Success
let authenticationSuccessEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#authentication_count, #authentication_success_count],
  },
  title: "Authentication Success Rate",
  description: "Breakdown of ThreeDS 2.0 Journey",
  domain: #payments,
}

let authenticationSuccessChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: ExemptionGraphsUtils.exemptionGraphsMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// User Drop Rate
let userDropOffRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#authentication_attempt_count, #authentication_success_count],
  },
  title: "User Drop-off Rate",
  description: "Breakdown of user drop-off rates by device type",
  domain: #payments,
}

let userDropOffRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: ExemptionGraphsUtils.exemptionGraphsMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Exemption Approval Rate
let exemptionApprovalRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#authentication_exemption_requested_count, #authentication_exemption_approved_count],
  },
  title: "Exemption Approval Rate",
  description: "Breakdown of exemption approval rates",
  domain: #payments,
}

let exemptionApprovalRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: ExemptionGraphsUtils.exemptionGraphsMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Exemption Request Rate
let exemptionRequestRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#authentication_exemption_requested_count, #authentication_attempt_count],
  },
  title: "Exemption Request Rate",
  description: "Breakdown of exemption request rates",
  domain: #payments,
}

let exemptionRequestRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: ExemptionGraphsUtils.exemptionGraphsMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Authentication Summary
let authenticationSummaryEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [
      #authentication_count,
      #authentication_success_count,
      #authentication_exemption_requested_count,
      #authentication_exemption_approved_count,
      #authentication_attempt_count,
    ],
  },
  title: "Authentication Summary",
  description: "Breakdown of ThreeDS 2.0 Journey",
  domain: #payments,
}

let authSummaryTableEntity = {
  open ExemptionGraphsUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=visibleColumns,
    ~requiredSearchFieldsList=[],
    ~allColumns=visibleColumns,
    ~getCell,
    ~getHeading,
  )
}

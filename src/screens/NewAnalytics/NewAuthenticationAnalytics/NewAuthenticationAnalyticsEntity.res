// SCA Exemption
open NewAuthenticationAnalyticsTypes

let scaExemptionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
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
  getObjects: AuthenticationSuccessUtils.authenticationSuccessMapper,
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
  getObjects: UserDropOffRateUtils.userDropOffRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Exemption Approval Rate
let exemptionApprovalRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
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
  getObjects: ExemptionApprovalRateUtils.excemptionApprovalRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Exemption Request Rate
let exemptionRequestRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
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
  getObjects: ExemptionRequestRateUtils.excemptionRequestRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Transaction list
let transactionListEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
  },
  title: "Authentication Summary",
  description: "List of transactions with payment processing details",
  domain: #payments,
}

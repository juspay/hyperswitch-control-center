type infoMetrics =
  | Latency
  | ApiName
  | Status_code

let getStringFromVarient = value =>
  switch value {
  | Latency => "latency"
  | ApiName => "api_name"
  | Status_code => "status_code"
  }

type weeklyStateCol = {
  refKey: string,
  newKey: string,
}

type chartItemType = {
  key: string,
  title: string,
  tooltipText: string,
  value: string,
  delta: float,
  data: array<(float, float)>,
  statType: string,
  lineColor: option<string>,
  graphBgColor: string,
  isIncreasing: bool,
  statsPercentage: string,
  arrowIcon: React.element,
}
type connectorTileType = {
  name: string,
  logo: string,
}
type chartOption = {
  name: string,
  key: string,
  type_: LineChartUtils.dropDownMetricType,
  avg: float,
}

type analyticsType = PAYMENT | REFUND | USER_JOURNEY | AUTHENTICATION | UNKNOWN

let getAnalyticsType = moduleName => {
  switch moduleName {
  | "Payments" => PAYMENT
  | "Refunds" => REFUND
  | "UserJourney" | "UserJourneyBar" | "UserJourneyFunnel" => USER_JOURNEY
  | "Authentication" | "AuthenticationBar" | "AuthenticationFunnel" => AUTHENTICATION
  | _ => UNKNOWN
  }
}

let getModuleName = analyticsType => {
  switch analyticsType {
  | PAYMENT => "Payments"
  | REFUND => "Refunds"
  | USER_JOURNEY => "UserJourney"
  | AUTHENTICATION => "Authentication"
  | UNKNOWN => ""
  }
}

type systemMetricsSingleStateMetrics =
  | Latency
  | ApiCount

type systemMetricsObjectType = {
  latency: float,
  api_count: int,
  status_code_count: int,
}

type systemMetricsSingleStateSeries = {
  latency: float,
  api_count: int,
  status_code_count: int,
  time_series: string,
}

type refundColType =
  | SuccessRate
  | Count
  | SuccessCount
  | ProcessedAmount
  | Connector
  | RefundMethod
  | Currency
  | Status
  | NoCol

let defaultRefundColumns = [Connector, RefundMethod, Currency, Status]
let allRefundColumns = [SuccessRate, Count, SuccessCount]

type refundTableType = {
  refund_success_rate: float,
  refund_count: float,
  refund_success_count: float,
  refund_processed_amount: float,
  connector: string,
  refund_method: string,
  currency: string,
  refund_status: string,
}

type refundsSingleState = {
  refund_success_rate: float,
  refund_count: int,
  refund_success_count: int,
  refund_processed_amount: float,
}

type refundsSingleStateSeries = {
  refund_success_rate: float,
  refund_count: int,
  refund_success_count: int,
  time_series: string,
  refund_processed_amount: float,
}

type disputeColType =
  | Connector
  | DisputeStage
  | TotalAmountDisputed
  | TotalDisputeLostAmount
  | NoCol

let defaultDisputeColumns = [Connector, DisputeStage]

let allDisputeColumns = [TotalAmountDisputed, TotalDisputeLostAmount]

type disputeTableType = {
  connector: string,
  dispute_stage: string,
  total_amount_disputed: float,
  total_dispute_lost_amount: float,
}

type disputeSingleStateType = {
  total_amount_disputed: float,
  total_dispute_lost_amount: float,
}

type disputeSingleSeriesState = {
  total_amount_disputed: float,
  total_dispute_lost_amount: float,
  time_series: string,
}

type paymentColType =
  | SuccessRate
  | Count
  | SuccessCount
  | ProcessedAmount
  | AvgTicketSize
  | Connector
  | PaymentErrorMessage
  | PaymentMethod
  | PaymentMethodType
  | Currency
  | AuthType
  | ClientSource
  | ClientVersion
  | Status
  | WeeklySuccessRate
  | NoCol

let defaultPaymentColumns = [
  Connector,
  PaymentMethod,
  PaymentMethodType,
  Currency,
  AuthType,
  Status,
  ClientSource,
  ClientVersion,
]

let allPaymentColumns = [SuccessRate, WeeklySuccessRate, Count, SuccessCount, PaymentErrorMessage]
type paymentsSingleState = {
  payment_success_rate: float,
  payment_count: int,
  payment_success_count: int,
  retries_count: int,
  currency: string,
  retries_amount_processe: float,
  connector_success_rate: float,
  payment_processed_amount: float,
  payment_avg_ticket_size: float,
}

type paymentsSingleStateSeries = {
  payment_success_rate: float,
  payment_count: int,
  retries_count: int,
  retries_amount_processe: float,
  connector_success_rate: float,
  payment_success_count: int,
  time_series: string,
  payment_processed_amount: float,
  payment_avg_ticket_size: float,
}

type error_message_type = {
  reason: string,
  count: int,
  percentage: float,
}

type paymentTableType = {
  payment_success_rate: float,
  payment_count: float,
  payment_success_count: float,
  payment_processed_amount: float,
  payment_error_message: array<error_message_type>,
  avg_ticket_size: float,
  connector: string,
  payment_method: string,
  payment_method_type: string,
  currency: string,
  authentication_type: string,
  client_source: string,
  client_version: string,
  refund_status: string,
  weekly_payment_success_rate: string,
}

type authenticationSingleStat = {
  three_ds_sdk_count: int,
  authentication_success_count: int,
  authentication_attempt_count: int,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
}

type authenticationSingleStatSeries = {
  three_ds_sdk_count: int,
  authentication_success_count: int,
  authentication_attempt_count: int,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  time_series: string,
}

type userJourneysSingleStat = {
  payment_attempts: int,
  sdk_rendered_count: int,
  average_payment_time: float,
  load_time: float,
}

type userJourneysSingleStatSeries = {
  payment_attempts: int,
  sdk_rendered_count: int,
  average_payment_time: float,
  load_time: float,
  time_series: string,
}

type nestedEntityType = {
  default?: DynamicChart.entity,
  userPieChart?: DynamicChart.entity,
  userBarChart?: DynamicChart.entity,
  userFunnelChart?: DynamicChart.entity,
}

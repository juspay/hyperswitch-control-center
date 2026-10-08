type domain =
  | @as("payments") Payments
  | @as("refunds") Refunds
  | @as("disputes") Disputes

type source =
  | Intent
  | Attempt
  | Refund
  | Dispute

type measure =
  | SuccessRate
  | FailureRate
  | Volume
  | Successful
  | Failed
  | ThreeDsFailureRate
  | NotCompletedRate
  | ProcessedAmount
  | AvgTicket
  | LostAmount

type view =
  | @as("trend") Trend
  | @as("breakdown") Breakdown
  | @as("mix") Mix
  | @as("table") Table

type changeImpact =
  | Favorable
  | Unfavorable
  | Neutral

type metric = [
  | #payment_intent_count
  | #payment_count
  | #refund_count
  | #payment_processed_amount
  | #refund_processed_amount
  | #dispute_status_metric
  | #total_amount_disputed
  | #total_dispute_lost_amount
  | #payment_success_rate
  | #payments_success_rate
  | #refund_success_rate
]

type dimension = [
  | #status
  | #refund_status
  | #connector
  | #payment_method
  | #payment_method_type
  | #card_network
  | #authentication_type
  | #error_reason
  | #currency
  | #profile_id
  | #routing_approach
  | #client_source
  | #client_version
  | #refund_type
  | #refund_reason
  | #refund_error_message
  | #dispute_stage
]

type authenticationType = [#three_ds | #no_three_ds]

type intentStatus = [
  | #succeeded
  | #failed
  | #cancelled
  | #cancelled_post_capture
  | #processing
  | #requires_customer_action
  | #requires_merchant_action
  | #requires_payment_method
  | #requires_confirmation
  | #requires_capture
  | #partially_captured
  | #partially_captured_and_capturable
  | #partially_authorized_and_requires_capture
  | #partially_captured_and_processing
  | #conflicted
  | #expired
  | #review
]

type attemptStatus = [
  | #started
  | #authentication_failed
  | #router_declined
  | #authentication_pending
  | #authentication_successful
  | #authorized
  | #authorization_failed
  | #charged
  | #authorizing
  | #cod_initiated
  | #voided
  | #voided_post_charge
  | #void_initiated
  | #capture_initiated
  | #capture_failed
  | #void_failed
  | #auto_refunded
  | #partial_charged
  | #partially_authorized
  | #partial_charged_and_chargeable
  | #unresolved
  | #pending
  | #failure
  | #payment_method_awaited
  | #confirmation_awaited
  | #device_data_collection_pending
  | #integrity_failure
  | #expired
  | #capture_review
]

type refundStatus = [#success | #failure | #transaction_failure | #pending | #manual_review]

type countField =
  | Total
  | Success
  | Failed
  | Awaiting
  | AuthFailed
  | Other

type amountField =
  | Processed
  | Lost

type denominator =
  | AllRecords
  | CompletedRecords
  | Decided
  | ThreeDsAttempts

type formula =
  | Rate(countField, denominator)
  | Count(countField)
  | TotalAmount(amountField)
  | AmountPerSuccess

type sourceConfig = {
  domain: domain,
  statusDimension: option<dimension>,
  countMetrics: array<metric>,
  amountMetrics: array<metric>,
  successRateMetric: option<metric>,
  infoDomain: option<string>,
  dimensions: array<dimension>,
  measures: array<measure>,
}

type counts = {
  total: float,
  success: float,
  failed: float,
  authFailed: float,
  awaiting: float,
  threeDsAttempts: float,
  amount: float,
  lostAmount: float,
  backendRate: option<float>,
}

type group = {
  values: array<string>,
  current: counts,
  previous: option<counts>,
}

type dailyPoint = {
  groupKey: string,
  day: string,
  counts: counts,
}

type question = {
  source: source,
  measure: measure,
  split: array<dimension>,
  view: view,
  dimensions: array<dimension>,
  filters: array<(dimension, array<string>)>,
  currency: string,
  startTime: string,
  endTime: string,
}

type responses = {
  currentRows: array<JSON.t>,
  previousRows: array<JSON.t>,
  currentDaily: array<JSON.t>,
  previousDaily: array<JSON.t>,
  rateCurrent: array<JSON.t>,
  ratePrevious: array<JSON.t>,
  rateCurrentDaily: array<JSON.t>,
  ratePreviousDaily: array<JSON.t>,
  rateOverallCurrent: array<JSON.t>,
  rateOverallPrevious: array<JSON.t>,
}

type dataset = {
  sorted: array<group>,
  topByVolume: array<group>,
  unmeasured: array<(array<string>, counts)>,
  overall: counts,
  overallPrevious: counts,
  currentDaily: array<dailyPoint>,
  previousDaily: array<dailyPoint>,
  minimumRateBase: float,
  amountCurrencies: array<string>,
  amountCurrency: string,
}

type outcomeRow = {
  outcome: string,
  count: float,
  change: string,
  share: float,
}

type outcomeColumn =
  | OutcomeName
  | OutcomeCount
  | OutcomeChange
  | OutcomeShare

type groupRow = {
  group: group,
  labels: array<(dimension, string)>,
  value: string,
  isLowVolume: bool,
  change: string,
  impact: changeImpact,
  volume: float,
  share: float,
}

type groupColumn =
  | SplitColumn(dimension)
  | MeasureColumn
  | ChangeColumn
  | VolumeColumn
  | ShareColumn

type viewContext = {
  question: question,
  dataset: dataset,
  hasPrevious: bool,
  currentLabel: string,
  previousLabel: string,
  singleCurrency: string,
  chartKey: string,
  labelFor: (dimension, string) => string,
  groupLabel: group => string,
  onFocus: group => unit,
}

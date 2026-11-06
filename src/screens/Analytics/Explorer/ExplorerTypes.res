type domain = [#payments | #refunds | #disputes]

type source = [#intent | #attempt | #refund | #dispute]

type flow = [#all | #cit | #cit_saving | #mit]

type measure = [
  | #success_rate
  | #failure_rate
  | #volume
  | #successful
  | #failed
  | #three_ds_failure_rate
  | #not_completed_rate
  | #processed_amount
  | #avg_ticket
  | #lost_amount
]

type selectionKey = [#source | #flow | #measure | #currency | #split | #view | #from]

type view = [#trend | #breakdown | #mix | #table]

type grouping = Overall | Split

type changeImpact =
  | Favorable
  | Unfavorable
  | Neutral

type metric = [
  | #payment_intent_count
  | #payment_count
  | #refund_count
  | #dispute_status_metric
  | #payment_processed_amount
  | #refund_processed_amount
  | #total_amount_disputed
  | #total_dispute_lost_amount
]

type dimension = [
  | #status
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
  | #refund_status
  | #refund_type
  | #refund_reason
  | #refund_error_message
  | #dispute_stage
  | #off_session
  | #setup_future_usage
  | #flow
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
  | Excluded
  | AuthFailed
  | Other

type denominator =
  | AllRecords
  | EligibleRecords
  | DecidedRecords
  | ThreeDsAttempts

type amountField =
  | Processed
  | Lost

type formula =
  | Rate(countField, denominator)
  | Count(countField)
  | TotalAmount(amountField)
  | AmountPerSuccess

type sourceConfig = {
  domain: domain,
  statusDimension: option<dimension>,
  countMetric: metric,
  amountMetrics: array<metric>,
  infoDomain: string,
  dimensions: array<dimension>,
  measures: array<measure>,
}

type counts = {
  total: float,
  success: float,
  failed: float,
  authFailed: float,
  excluded: float,
  threeDsAttempts: float,
  amount: float,
  lostAmount: float,
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

type preset = {
  title: string,
  source: source,
  measure: measure,
  split: array<dimension>,
  view: view,
}

type selection = {
  source: source,
  flow: flow,
  measure: measure,
  split: array<dimension>,
  splitOptions: array<dimension>,
  filterOptions: array<dimension>,
  filters: array<(dimension, array<string>)>,
  drilledFrom: option<dimension>,
  view: view,
  currency: string,
  startTime: string,
  endTime: string,
}

type responses = {
  currentRows: array<JSON.t>,
  previousRows: array<JSON.t>,
  currentDaily: array<JSON.t>,
  previousDaily: array<JSON.t>,
}

type dataset = {
  overall: counts,
  overallPrevious: counts,
  inCurrency: counts,
  inCurrencyPrevious: counts,
  amountCurrencies: array<string>,
  amountCurrency: string,
  groups: array<group>,
  topByVolume: array<group>,
  topMeasured: array<group>,
  unmeasured: array<(array<string>, counts)>,
  currentDaily: Dict.t<dailyPoint>,
  previousDaily: Dict.t<dailyPoint>,
  flowCounts: Dict.t<float>,
}

type chartContext = {
  selection: selection,
  dataset: dataset,
  labelFor: (dimension, string) => string,
}

type summaryLine =
  | CurrencyLine
  | SplitLine

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

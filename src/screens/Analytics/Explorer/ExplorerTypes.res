type source =
  | Intent
  | Attempt

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

type changeImpact =
  | Favorable
  | Unfavorable
  | Neutral

type metric = [
  | #payment_intent_count
  | #payment_count
  | #payment_processed_amount
  | #payment_success_rate
  | #payments_success_rate
]

type dimension = [
  | #status
  | #authentication_type
  | #currency
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

type countField =
  | Total
  | Success
  | Failed
  | Awaiting
  | AuthFailed

type denominator =
  | AllRecords
  | CompletedRecords
  | ThreeDsAttempts

type formula =
  | Rate(countField, denominator)
  | Count(countField)
  | TotalAmount
  | AmountPerSuccess

type sourceConfig = {
  countMetric: metric,
  amountMetric: metric,
  successRateMetric: metric,
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
  backendRate: option<float>,
}

type question = {
  source: source,
  measure: measure,
  currency: string,
  startTime: string,
  endTime: string,
}

type responses = {
  currentRows: array<JSON.t>,
  previousRows: array<JSON.t>,
  rateCurrent: array<JSON.t>,
  ratePrevious: array<JSON.t>,
}

type dataset = {
  overall: counts,
  overallPrevious: counts,
  amountCurrencies: array<string>,
  amountCurrency: string,
}

open ExplorerTypes

let sources = [Intent, Attempt]

let sourceConfig = source =>
  switch source {
  | Intent => {
      countMetric: #payment_intent_count,
      amountMetric: #payment_processed_amount,
      successRateMetric: #payments_success_rate,
      measures: [
        SuccessRate,
        FailureRate,
        NotCompletedRate,
        Volume,
        Successful,
        Failed,
        ProcessedAmount,
        AvgTicket,
      ],
    }
  | Attempt => {
      countMetric: #payment_count,
      amountMetric: #payment_processed_amount,
      successRateMetric: #payment_success_rate,
      measures: [
        SuccessRate,
        FailureRate,
        ThreeDsFailureRate,
        Volume,
        Successful,
        Failed,
        ProcessedAmount,
        AvgTicket,
      ],
    }
  }

let intentStatuses: array<intentStatus> = [
  #succeeded,
  #failed,
  #cancelled,
  #cancelled_post_capture,
  #processing,
  #requires_customer_action,
  #requires_merchant_action,
  #requires_payment_method,
  #requires_confirmation,
  #requires_capture,
  #partially_captured,
  #partially_captured_and_capturable,
  #partially_authorized_and_requires_capture,
  #partially_captured_and_processing,
  #conflicted,
  #expired,
  #review,
]

let attemptStatuses: array<attemptStatus> = [
  #started,
  #authentication_failed,
  #router_declined,
  #authentication_pending,
  #authentication_successful,
  #authorized,
  #authorization_failed,
  #charged,
  #authorizing,
  #cod_initiated,
  #voided,
  #voided_post_charge,
  #void_initiated,
  #capture_initiated,
  #capture_failed,
  #void_failed,
  #auto_refunded,
  #partial_charged,
  #partially_authorized,
  #partial_charged_and_chargeable,
  #unresolved,
  #pending,
  #failure,
  #payment_method_awaited,
  #confirmation_awaited,
  #device_data_collection_pending,
  #integrity_failure,
  #expired,
  #capture_review,
]

let intentStatusOutcomes = (status: intentStatus) =>
  switch status {
  | #succeeded => [Success]
  | #failed => [Failed]
  | #requires_customer_action
  | #requires_payment_method
  | #requires_merchant_action
  | #requires_confirmation => [Awaiting]
  | #cancelled
  | #cancelled_post_capture
  | #processing
  | #requires_capture
  | #partially_captured
  | #partially_captured_and_capturable
  | #partially_authorized_and_requires_capture
  | #partially_captured_and_processing
  | #conflicted
  | #expired
  | #review => []
  }

let attemptStatusOutcomes = (status: attemptStatus) =>
  switch status {
  | #charged => [Success]
  | #authentication_failed => [Failed, AuthFailed]
  | #failure
  | #authorization_failed
  | #router_declined
  | #capture_failed
  | #void_failed
  | #expired => [Failed]
  | #started
  | #authentication_pending
  | #authentication_successful
  | #authorized
  | #authorizing
  | #cod_initiated
  | #voided
  | #voided_post_charge
  | #void_initiated
  | #capture_initiated
  | #auto_refunded
  | #partial_charged
  | #partially_authorized
  | #partial_charged_and_chargeable
  | #unresolved
  | #pending
  | #payment_method_awaited
  | #confirmation_awaited
  | #device_data_collection_pending
  | #integrity_failure
  | #capture_review => []
  }

let getMeasureFormula = (source, measure) =>
  switch (measure, source) {
  | (SuccessRate, Intent) => Rate(Success, CompletedRecords)
  | (SuccessRate, Attempt) => Rate(Success, AllRecords)
  | (FailureRate, Intent) => Rate(Failed, CompletedRecords)
  | (FailureRate, Attempt) => Rate(Failed, AllRecords)
  | (ThreeDsFailureRate, _) => Rate(AuthFailed, ThreeDsAttempts)
  | (NotCompletedRate, _) => Rate(Awaiting, AllRecords)
  | (Volume, _) => Count(Total)
  | (Successful, _) => Count(Success)
  | (Failed, _) => Count(Failed)
  | (ProcessedAmount, _) => TotalAmount
  | (AvgTicket, _) => AmountPerSuccess
  }

let isLowerBetter = measure =>
  switch measure {
  | FailureRate | Failed | ThreeDsFailureRate | NotCompletedRate => true
  | SuccessRate | Volume | Successful | ProcessedAmount | AvgTicket => false
  }

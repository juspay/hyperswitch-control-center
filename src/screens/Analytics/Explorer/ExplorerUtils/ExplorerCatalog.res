open ExplorerTypes

let sources: array<source> = [#intent, #attempt]

let sourceConfig = (source: source) =>
  switch source {
  | #intent => {
      countMetric: #payment_intent_count,
      amountMetric: #payment_processed_amount,
      measures: [
        #success_rate,
        #failure_rate,
        #not_completed_rate,
        #volume,
        #successful,
        #failed,
        #processed_amount,
        #avg_ticket,
      ],
    }
  | #attempt => {
      countMetric: #payment_count,
      amountMetric: #payment_processed_amount,
      measures: [
        #success_rate,
        #failure_rate,
        #three_ds_failure_rate,
        #volume,
        #successful,
        #failed,
        #processed_amount,
        #avg_ticket,
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

let getMeasureFormula = (source: source, measure: measure) =>
  switch (measure, source) {
  | (#success_rate, #intent) => Rate(Success, CompletedRecords)
  | (#success_rate, #attempt) => Rate(Success, AllRecords)
  | (#failure_rate, #intent) => Rate(Failed, CompletedRecords)
  | (#failure_rate, #attempt) => Rate(Failed, AllRecords)
  | (#three_ds_failure_rate, _) => Rate(AuthFailed, ThreeDsAttempts)
  | (#not_completed_rate, _) => Rate(Awaiting, AllRecords)
  | (#volume, _) => Count(Total)
  | (#successful, _) => Count(Success)
  | (#failed, _) => Count(Failed)
  | (#processed_amount, _) => TotalAmount
  | (#avg_ticket, _) => AmountPerSuccess
  }

let isLowerBetter = (measure: measure) =>
  switch measure {
  | #failure_rate | #failed | #three_ds_failure_rate | #not_completed_rate => true
  | #success_rate | #volume | #successful | #processed_amount | #avg_ticket => false
  }

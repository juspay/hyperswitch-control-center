open ExplorerTypes

let domains = [Payments, Refunds, Disputes]

let views = [Trend, Breakdown, Mix, Table]

let sourceConfig = source =>
  switch source {
  | Intent => {
      domain: Payments,
      statusDimension: Some(#status),
      countMetrics: [#payment_intent_count],
      amountMetrics: [#payment_processed_amount],
      successRateMetric: Some(#payments_success_rate),
      infoDomain: Some("payment_intents"),
      dimensions: [#status, #currency, #profile_id],
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
      domain: Payments,
      statusDimension: Some(#status),
      countMetrics: [#payment_count],
      amountMetrics: [#payment_processed_amount],
      successRateMetric: Some(#payment_success_rate),
      infoDomain: Some("payments"),
      dimensions: [
        #connector,
        #payment_method,
        #payment_method_type,
        #card_network,
        #authentication_type,
        #status,
        #error_reason,
        #currency,
        #profile_id,
        #routing_approach,
        #client_source,
        #client_version,
      ],
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
  | Refund => {
      domain: Refunds,
      statusDimension: Some(#refund_status),
      countMetrics: [#refund_count],
      amountMetrics: [#refund_processed_amount],
      successRateMetric: Some(#refund_success_rate),
      infoDomain: Some("refunds"),
      dimensions: [
        #connector,
        #refund_status,
        #refund_type,
        #refund_reason,
        #refund_error_message,
        #currency,
        #profile_id,
      ],
      measures: [
        SuccessRate,
        FailureRate,
        NotCompletedRate,
        Volume,
        Successful,
        Failed,
        ProcessedAmount,
      ],
    }
  | Dispute => {
      domain: Disputes,
      statusDimension: None,
      countMetrics: [#dispute_status_metric, #total_amount_disputed, #total_dispute_lost_amount],
      amountMetrics: [],
      successRateMetric: None,
      infoDomain: None,
      dimensions: [#connector, #dispute_stage, #currency],
      measures: [SuccessRate, FailureRate, Volume, Successful, Failed, ProcessedAmount, LostAmount],
    }
  }

let getDomainSources = domain =>
  switch domain {
  | Payments => [Intent, Attempt]
  | Refunds => [Refund]
  | Disputes => [Dispute]
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

let refundStatuses: array<refundStatus> = [
  #success,
  #failure,
  #transaction_failure,
  #pending,
  #manual_review,
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

let refundStatusOutcomes = (status: refundStatus) =>
  switch status {
  | #success => [Success]
  | #failure | #transaction_failure => [Failed]
  | #pending | #manual_review => [Awaiting]
  }

let getSourceOutcomes = source =>
  switch source {
  | Attempt => [Success, Failed, Other]
  | Intent | Refund | Dispute => [Success, Failed, Awaiting, Other]
  }

let getMeasureFormula = (source, measure) =>
  switch (measure, source) {
  | (SuccessRate, Intent) => Rate(Success, CompletedRecords)
  | (SuccessRate, Dispute) => Rate(Success, Decided)
  | (SuccessRate, _) => Rate(Success, AllRecords)
  | (FailureRate, Intent) => Rate(Failed, CompletedRecords)
  | (FailureRate, Dispute) => Rate(Failed, Decided)
  | (FailureRate, _) => Rate(Failed, AllRecords)
  | (ThreeDsFailureRate, _) => Rate(AuthFailed, ThreeDsAttempts)
  | (NotCompletedRate, _) => Rate(Awaiting, AllRecords)
  | (Volume, _) => Count(Total)
  | (Successful, _) => Count(Success)
  | (Failed, _) => Count(Failed)
  | (ProcessedAmount, _) => TotalAmount(Processed)
  | (LostAmount, _) => TotalAmount(Lost)
  | (AvgTicket, _) => AmountPerSuccess
  }

let isLowerBetter = measure =>
  switch measure {
  | FailureRate | Failed | ThreeDsFailureRate | NotCompletedRate | LostAmount => true
  | SuccessRate | Volume | Successful | ProcessedAmount | AvgTicket => false
  }

let statusDimensions: array<dimension> = [#status, #refund_status]

let suggestedNext = (source, key: option<dimension>): array<dimension> =>
  switch (source, key) {
  | (Intent, Some(#status)) => [#currency, #profile_id]
  | (Intent, _) => [#currency, #status]
  | (Attempt, Some(#connector)) => [#payment_method_type, #error_reason]
  | (Attempt, Some(#payment_method)) => [#payment_method_type, #connector]
  | (Attempt, Some(#payment_method_type)) => [#connector, #card_network]
  | (Attempt, Some(#card_network)) => [#connector, #authentication_type]
  | (Attempt, Some(#error_reason)) => [#connector, #card_network]
  | (Attempt, Some(#status)) => [#error_reason, #connector]
  | (Attempt, _) => [#connector, #error_reason]
  | (Refund, Some(#connector)) => [#refund_error_message, #refund_type]
  | (Refund, Some(#refund_error_message)) => [#connector, #refund_type]
  | (Refund, _) => [#connector, #refund_error_message]
  | (Dispute, Some(#connector)) => [#dispute_stage, #currency]
  | (Dispute, _) => [#connector, #currency]
  }

open ExplorerTypes

let domains: array<domain> = [#payments, #refunds, #disputes]

let sources: array<source> = [#intent, #attempt, #refund, #dispute]

let views: array<view> = [#trend, #breakdown, #mix, #table]

let sourceConfig = (source: source) =>
  switch source {
  | #intent => {
      domain: #payments,
      statusDimension: Some(#status),
      countMetric: #payment_intent_count,
      amountMetrics: [#payment_processed_amount],
      infoDomain: "payment_intents",
      dimensions: [#status, #currency, #profile_id],
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
      domain: #payments,
      statusDimension: Some(#status),
      countMetric: #payment_count,
      amountMetrics: [#payment_processed_amount],
      infoDomain: "payments",
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
  | #refund => {
      domain: #refunds,
      statusDimension: Some(#refund_status),
      countMetric: #refund_count,
      amountMetrics: [#refund_processed_amount],
      infoDomain: "refunds",
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
        #success_rate,
        #failure_rate,
        #not_completed_rate,
        #volume,
        #successful,
        #failed,
        #processed_amount,
      ],
    }
  | #dispute => {
      domain: #disputes,
      statusDimension: None,
      countMetric: #dispute_status_metric,
      amountMetrics: [#total_amount_disputed, #total_dispute_lost_amount],
      infoDomain: "dispute",
      dimensions: [#connector, #dispute_stage, #currency],
      measures: [
        #success_rate,
        #failure_rate,
        #volume,
        #successful,
        #failed,
        #processed_amount,
        #lost_amount,
      ],
    }
  }

let getDomainSources = (domain: domain): array<source> =>
  switch domain {
  | #payments => [#intent, #attempt]
  | #refunds => [#refund]
  | #disputes => [#dispute]
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
  | #requires_confirmation => [Excluded]
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
  | #failure => [Failed]
  | #authentication_failed => [Excluded, AuthFailed]
  | #payment_method_awaited
  | #confirmation_awaited
  | #device_data_collection_pending
  | #unresolved => [Excluded]
  | #started
  | #router_declined
  | #authentication_pending
  | #authentication_successful
  | #authorized
  | #authorization_failed
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
  | #pending
  | #integrity_failure
  | #expired
  | #capture_review => []
  }

let refundStatusOutcomes = (status: refundStatus) =>
  switch status {
  | #success => [Success]
  | #failure | #transaction_failure => [Failed]
  | #pending | #manual_review => [Excluded]
  }

let outcomes = [Success, Failed, Excluded, Other]

let getMeasureFormula = (source: source, measure: measure) =>
  switch (measure, source) {
  | (#success_rate, #intent) => Rate(Success, EligibleRecords)
  | (#success_rate, #dispute) => Rate(Success, DecidedRecords)
  | (#success_rate, #attempt | #refund) => Rate(Success, AllRecords)
  | (#failure_rate, #dispute) => Rate(Failed, DecidedRecords)
  | (#failure_rate, #refund) => Rate(Failed, AllRecords)
  | (#failure_rate, #intent | #attempt) => Rate(Failed, EligibleRecords)
  | (#three_ds_failure_rate, _) => Rate(AuthFailed, ThreeDsAttempts)
  | (#not_completed_rate, _) => Rate(Excluded, AllRecords)
  | (#volume, _) => Count(Total)
  | (#successful, _) => Count(Success)
  | (#failed, _) => Count(Failed)
  | (#processed_amount, _) => TotalAmount(Processed)
  | (#lost_amount, _) => TotalAmount(Lost)
  | (#avg_ticket, _) => AmountPerSuccess
  }

let isLowerBetter = (measure: measure) =>
  switch measure {
  | #failure_rate | #failed | #three_ds_failure_rate | #not_completed_rate | #lost_amount => true
  | #success_rate | #volume | #successful | #processed_amount | #avg_ticket => false
  }

let statusDimensions = sources->Array.filterMap(source => sourceConfig(source).statusDimension)

let suggestedNext = (source: source, key: option<dimension>): array<dimension> =>
  switch (source, key) {
  | (#intent, Some(#status)) => [#currency, #profile_id]
  | (#intent, _) => [#currency, #status]
  | (#attempt, Some(#connector)) => [#payment_method_type, #error_reason]
  | (#attempt, Some(#payment_method)) => [#payment_method_type, #connector]
  | (#attempt, Some(#payment_method_type)) => [#connector, #card_network]
  | (#attempt, Some(#card_network)) => [#connector, #authentication_type]
  | (#attempt, Some(#error_reason)) => [#connector, #card_network]
  | (#attempt, Some(#status)) => [#error_reason, #connector]
  | (#attempt, _) => [#connector, #error_reason]
  | (#refund, Some(#connector)) => [#refund_error_message, #refund_type]
  | (#refund, Some(#refund_error_message)) => [#connector, #refund_type]
  | (#refund, _) => [#connector, #refund_error_message]
  | (#dispute, Some(#connector)) => [#dispute_stage, #currency]
  | (#dispute, _) => [#connector, #currency]
  }

open LogicUtils
open ExplorerTypes

let domainLabel = domain =>
  switch domain {
  | Payments => "Payments"
  | Refunds => "Refunds"
  | Disputes => "Disputes"
  }

let sourceLabel = source =>
  switch source {
  | Intent => "Intents"
  | Attempt => "Attempts"
  | Refund => "Refunds"
  | Dispute => "Disputes"
  }

let sourceDescription = source =>
  switch source {
  | Intent => "One row per payment, regardless of retries. Use this view for the customer experience and to compare CIT and MIT."
  | Attempt => "One row per attempt; each retry is a separate attempt. Use this view to analyse connectors, payment methods and errors."
  | Refund => "One row per refund. Use this view to analyse refund failures by connector, reason and error."
  | Dispute => "One row per dispute. Use this view to track win rate and amounts lost to disputes."
  }

let flowLabel = flow =>
  switch flow {
  | AllFlows => "all payments"
  | Cit => "CIT payments"
  | CitSaving => "CIT payments with card saving"
  | Mit => "MIT payments"
  }

let flowDescription = flow =>
  switch flow {
  | AllFlows => "Every payment"
  | Cit => "Customer present, card not saved"
  | CitSaving => "Customer present, card set to be saved"
  | Mit => "Merchant charged a saved card"
  }

let flowShortLabel = flow =>
  switch flow {
  | AllFlows => "All"
  | Cit => "CIT"
  | CitSaving => "CIT saving card"
  | Mit => "MIT"
  }

let sourceNoun = source =>
  switch source {
  | Intent => "payments"
  | Attempt => "attempts"
  | Refund => "refunds"
  | Dispute => "disputes"
  }

let measureLabel = (source, measure) =>
  switch (source, measure) {
  | (Dispute, SuccessRate) => "Win rate"
  | (Dispute, FailureRate) => "Loss rate"
  | (_, SuccessRate) => "Success rate"
  | (_, FailureRate) => "Failure rate"
  | (Intent, Volume) => "Payments"
  | (Attempt, Volume) => "Attempts"
  | (Refund, Volume) => "Refunds"
  | (Dispute, Volume) => "Disputes"
  | (Intent, Successful) => "Succeeded payments"
  | (Attempt, Successful) => "Successful attempts"
  | (Refund, Successful) => "Successful refunds"
  | (Dispute, Successful) => "Disputes won"
  | (Intent, Failed) => "Failed payments"
  | (Attempt, Failed) => "Failed attempts"
  | (Refund, Failed) => "Failed refunds"
  | (Dispute, Failed) => "Disputes lost"
  | (_, ThreeDsFailureRate) => "3DS failure rate"
  | (Refund, NotCompletedRate) => "Pending rate"
  | (_, NotCompletedRate) => "Not completed rate"
  | (Refund, ProcessedAmount) => "Refunded amount"
  | (Dispute, ProcessedAmount) => "Amount won"
  | (_, ProcessedAmount) => "Processed amount"
  | (_, AvgTicket) => "Average ticket"
  | (_, LostAmount) => "Amount lost"
  }

let measureDefinition = (source, measure) =>
  switch (source, measure) {
  | (
      Intent,
      SuccessRate,
    ) => "Share of payments that succeeded. Payments awaiting customer or merchant action are excluded."
  | (Attempt, SuccessRate) => "Share of attempts that were charged. Pending attempts are included."
  | (Refund, SuccessRate) => "Share of refunds that succeeded."
  | (Dispute, SuccessRate) => "Share of decided disputes (won or lost) that were won."
  | (
      Intent,
      FailureRate,
    ) => "Share of payments that failed. Payments awaiting customer or merchant action are excluded."
  | (Attempt, FailureRate) => "Share of attempts that failed."
  | (Refund, FailureRate) => "Share of refunds that failed."
  | (
      Dispute,
      FailureRate,
    ) => "Share of decided disputes (won or lost) that were lost. Accepted disputes are not counted."
  | (Intent, Volume) => "Payments created, in any status."
  | (Attempt, Volume) => "Attempts made, in any status. Each retry counts as an attempt."
  | (Refund, Volume) => "Refunds created, in any status."
  | (Dispute, Volume) => "Disputes opened, in any status."
  | (Intent, Successful) => "Payments with status succeeded."
  | (Attempt, Successful) => "Attempts with status charged."
  | (Refund, Successful) => "Refunds with status success."
  | (Dispute, Successful) => "Disputes with status won."
  | (Intent, Failed) => "Payments with status failed."
  | (
      Attempt,
      Failed,
    ) => "Attempts that failed, as the backend counts terminal failures: declined, authentication or authorization failed, router declined, capture or void failed, or expired."
  | (Refund, Failed) => "Refunds that failed at the connector or in the transaction."
  | (Dispute, Failed) => "Disputes with status lost."
  | (_, ThreeDsFailureRate) => "Share of 3DS attempts that failed authentication."
  | (Refund, NotCompletedRate) => "Share of refunds still pending or in manual review."
  | (_, NotCompletedRate) => "Share of payments awaiting customer or merchant action."
  | (Intent, ProcessedAmount) => "Amount of succeeded payments, in one currency."
  | (Attempt, ProcessedAmount) => "Amount of charged attempts, in one currency."
  | (Refund, ProcessedAmount) => "Amount of successful refunds, in one currency."
  | (Dispute, ProcessedAmount) => "Amount of disputes won, in one currency."
  | (Attempt, AvgTicket) => "Processed amount divided by charged attempts, in one currency."
  | (_, AvgTicket) => "Processed amount divided by succeeded payments, in one currency."
  | (
      _,
      LostAmount,
    ) => "Amount of disputes lost, in one currency. Accepted disputes are not counted."
  }

let unmeasurableNote = (source, measure) =>
  switch (source, measure) {
  | (Dispute, SuccessRate | FailureRate) => "No decided disputes in this period"
  | (Intent, SuccessRate | FailureRate) => "No completed payments in this period"
  | (_, ThreeDsFailureRate) => "No 3DS attempts in this period"
  | _ => "No data in this period"
  }

let unmeasurableReason = (source, measure) =>
  switch (source, measure) {
  | (Dispute, SuccessRate | FailureRate) => "no decided disputes"
  | (Intent, SuccessRate | FailureRate) => "all awaiting customer or merchant action"
  | (_, ThreeDsFailureRate) => "no 3DS attempts"
  | _ => "no eligible records"
  }

let dimensionLabel = (key: dimension) =>
  switch key {
  | #flow => "Flow"
  | #connector => "Connector"
  | #payment_method => "Payment method"
  | #payment_method_type => "Payment method type"
  | #card_network => "Card network"
  | #authentication_type => "Authentication type"
  | #status => "Status"
  | #error_reason => "Error reason"
  | #currency => "Currency"
  | #profile_id => "Profile"
  | #routing_approach => "Routing approach"
  | #client_source => "Client source"
  | #client_version => "Client version"
  | #refund_status => "Refund status"
  | #refund_type => "Refund type"
  | #refund_reason => "Refund reason"
  | #refund_error_message => "Refund error"
  | #dispute_stage => "Dispute stage"
  | #off_session => "Off session"
  | #setup_future_usage => "Setup future usage"
  }

let dimensionDescription = (source, key: dimension) =>
  switch (source, key) {
  | (
      _,
      #flow,
    ) => "Who started the payment: the customer (CIT), the customer saving the card, or the merchant (MIT)."
  | (_, #connector) => "Processor that handled it."
  | (_, #payment_method) => "Broad method, such as card, wallet or bank transfer."
  | (_, #payment_method_type) => "Specific method, such as credit, debit or Apple Pay."
  | (_, #card_network) => "Card scheme, such as Visa or Mastercard."
  | (_, #authentication_type) => "Whether 3DS was requested."
  | (Intent, #status) => "Payment status, such as succeeded, failed or requires payment method."
  | (_, #status) => "Attempt status, such as charged, failure or authentication failed."
  | (_, #error_reason) => "Error returned by the connector for a failed attempt."
  | (_, #currency) => "Currency of the payment."
  | (_, #profile_id) => "Business profile it belongs to."
  | (
      _,
      #routing_approach,
    ) => "How the connector was chosen, such as rule-based or success-rate based."
  | (_, #client_source) => "Where the payment was confirmed from, such as the SDK or a server call."
  | (_, #client_version) => "Version of the SDK or client that confirmed it."
  | (_, #refund_status) => "Refund status, such as success, failure or pending."
  | (_, #refund_type) => "How the refund was issued, such as instant or regular."
  | (_, #refund_reason) => "Reason given when the refund was created."
  | (_, #refund_error_message) => "Error returned by the connector for a failed refund."
  | (_, #dispute_stage) => "Stage of the dispute, such as pre-dispute, dispute or pre-arbitration."
  | (_, #off_session) => "Whether the merchant charged without the customer present."
  | (_, #setup_future_usage) => "Whether the card was saved for later payments."
  }

let outcomeLabel = (source, field) =>
  switch (source, field) {
  | (Attempt, Success) => "Charged"
  | (Attempt, Other) => "Pending or other"
  | (Dispute, Success) => "Won"
  | (Dispute, Failed) => "Lost"
  | (Dispute, Awaiting) => "Challenged"
  | (Dispute, Other) => "Open, accepted, expired or cancelled"
  | (Intent, Awaiting) => "Waiting on customer or merchant"
  | (Intent, Other) => "Other (cancelled, processing, expired…)"
  | (Refund, Awaiting) => "Pending or in review"
  | (_, Success) => "Succeeded"
  | (_, Failed) => "Failed"
  | (_, Awaiting) => "Waiting"
  | (_, AuthFailed) => "Failed 3DS authentication"
  | (_, Total) => "All"
  | (_, Other) => "Other"
  }

let viewLabel = view =>
  switch view {
  | Trend => "Trend"
  | Breakdown => "Breakdown"
  | Mix => "Mix"
  | Table => "Table"
  }

let viewNote = (question: question) => {
  let isSplit = question.split->isNonEmptyArray
  switch question.view {
  | Trend =>
    isSplit
      ? "Daily in UTC, for the five largest groups."
      : "Daily in UTC, against the same days of the previous period."
  | Breakdown =>
    isSplit
      ? "Groups ranked by the measure; low-volume groups are ranked last. Grey is the previous period."
      : "Outcomes in these dates. Grey is the previous period. Add a split to compare groups."
  | Mix =>
    isSplit
      ? "Share of each UTC day's volume by group."
      : "Share of each UTC day's volume by outcome."
  | Table =>
    isSplit
      ? "Click a row to focus on it."
      : "Outcomes in these dates. Add a split to compare groups."
  }
}

let viewTitle = (question: question) => {
  let {source, measure, split, view} = question
  let splitText = split->Array.map(dimensionLabel)->Array.joinWith(" and ")
  switch (split->isNonEmptyArray, view) {
  | (true, Mix) => `${measureLabel(source, Volume)} by ${splitText}`
  | (true, Trend | Breakdown | Table) => `${measureLabel(source, measure)} by ${splitText}`
  | (false, Breakdown | Table | Mix) => `${measureLabel(source, Volume)} by outcome`
  | (false, Trend) => measureLabel(source, measure)
  }
}

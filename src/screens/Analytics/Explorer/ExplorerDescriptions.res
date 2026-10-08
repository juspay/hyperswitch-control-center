open LogicUtils
open ExplorerTypes

let sourceLabel = source =>
  switch source {
  | Intent => "Intents"
  | Attempt => "Attempts"
  }

let sourceDescription = source =>
  switch source {
  | Intent => "One row per payment, regardless of retries. Use this view for the customer experience."
  | Attempt => "One row per attempt; each retry is a separate attempt. Use this view to analyse how attempts perform."
  }

let sourceNoun = source =>
  switch source {
  | Intent => "payments"
  | Attempt => "attempts"
  }

let measureLabel = (source, measure) =>
  switch (source, measure) {
  | (_, SuccessRate) => "Success rate"
  | (_, FailureRate) => "Failure rate"
  | (Intent, Volume) => "Payments"
  | (Attempt, Volume) => "Attempts"
  | (Intent, Successful) => "Succeeded payments"
  | (Attempt, Successful) => "Successful attempts"
  | (Intent, Failed) => "Failed payments"
  | (Attempt, Failed) => "Failed attempts"
  | (_, ThreeDsFailureRate) => "3DS failure rate"
  | (_, NotCompletedRate) => "Not completed rate"
  | (_, ProcessedAmount) => "Processed amount"
  | (_, AvgTicket) => "Average ticket"
  }

let measureDefinition = (source, measure) =>
  switch (source, measure) {
  | (
      Intent,
      SuccessRate,
    ) => "Share of payments that succeeded. Payments awaiting customer or merchant action are excluded."
  | (Attempt, SuccessRate) => "Share of attempts that were charged. Pending attempts are included."
  | (
      Intent,
      FailureRate,
    ) => "Share of payments that failed. Payments awaiting customer or merchant action are excluded."
  | (Attempt, FailureRate) => "Share of attempts that failed."
  | (Intent, Volume) => "Payments created, in any status."
  | (Attempt, Volume) => "Attempts made, in any status. Each retry counts as an attempt."
  | (Intent, Successful) => "Payments with status succeeded."
  | (Attempt, Successful) => "Attempts with status charged."
  | (Intent, Failed) => "Payments with status failed."
  | (
      Attempt,
      Failed,
    ) => "Attempts that failed, as the backend counts terminal failures: declined, authentication or authorization failed, router declined, capture or void failed, or expired."
  | (_, ThreeDsFailureRate) => "Share of 3DS attempts that failed authentication."
  | (_, NotCompletedRate) => "Share of payments awaiting customer or merchant action."
  | (Intent, ProcessedAmount) => "Amount of succeeded payments, in one currency."
  | (Attempt, ProcessedAmount) => "Amount of charged attempts, in one currency."
  | (Intent, AvgTicket) => "Processed amount divided by succeeded payments, in one currency."
  | (Attempt, AvgTicket) => "Processed amount divided by charged attempts, in one currency."
  }

let unmeasurableNote = (source, measure) =>
  switch (source, measure) {
  | (Intent, SuccessRate | FailureRate) => "No completed payments in this period"
  | (_, ThreeDsFailureRate) => "No 3DS attempts in this period"
  | _ => "No data in this period"
  }

let unmeasurableReason = (source, measure) =>
  switch (source, measure) {
  | (Intent, SuccessRate | FailureRate) => "all awaiting customer or merchant action"
  | (_, ThreeDsFailureRate) => "no 3DS attempts"
  | _ => "no eligible records"
  }

let dimensionLabel = (key: dimension) =>
  switch key {
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
  }

let dimensionDescription = (source, key: dimension) =>
  switch (source, key) {
  | (_, #connector) => "Processor that handled it."
  | (_, #payment_method) => "Broad method, such as card, wallet or bank transfer."
  | (_, #payment_method_type) => "Specific method, such as credit, debit or Apple Pay."
  | (_, #card_network) => "Card scheme, such as Visa or Mastercard."
  | (_, #authentication_type) => "Whether 3DS was requested."
  | (Intent, #status) => "Payment status, such as succeeded, failed or requires payment method."
  | (Attempt, #status) => "Attempt status, such as charged, failure or authentication failed."
  | (_, #error_reason) => "Error returned by the connector for a failed attempt."
  | (_, #currency) => "Currency of the payment."
  | (_, #profile_id) => "Business profile it belongs to."
  | (
      _,
      #routing_approach,
    ) => "How the connector was chosen, such as rule-based or success-rate based."
  | (_, #client_source) => "Where the payment was confirmed from, such as the SDK or a server call."
  | (_, #client_version) => "Version of the SDK or client that confirmed it."
  }

let outcomeLabel = (source, field) =>
  switch (source, field) {
  | (Attempt, Success) => "Charged"
  | (Attempt, Other) => "Pending or other"
  | (Intent, Awaiting) => "Waiting on customer or merchant"
  | (Intent, Other) => "Other (cancelled, processing, expired…)"
  | (_, Success) => "Succeeded"
  | (_, Failed) => "Failed"
  | (_, Awaiting) => "Waiting"
  | (_, AuthFailed) => "Failed 3DS authentication"
  | (_, Total) => "All"
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
      ? "Groups ranked by the measure; low-volume groups are ranked last."
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

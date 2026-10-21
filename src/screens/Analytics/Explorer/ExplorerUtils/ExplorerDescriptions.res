open LogicUtils
open ExplorerTypes
open ExplorerUtils

let sourceLabel = (source: source) =>
  switch source {
  | #intent => "Intents"
  | #attempt => "Attempts"
  }

let sourceDescription = (source: source) =>
  switch source {
  | #intent => "One row per payment, regardless of retries. Use this view for the customer experience."
  | #attempt => "One row per attempt; each retry is a separate attempt. Use this view to analyse how attempts perform."
  }

let sourceNoun = (source: source) =>
  switch source {
  | #intent => "payments"
  | #attempt => "attempts"
  }

let measureLabel = (source: source, measure: measure) =>
  switch (source, measure) {
  | (_, #success_rate) => "Success rate"
  | (_, #failure_rate) => "Failure rate"
  | (#intent, #volume) => "Payments"
  | (#attempt, #volume) => "Attempts"
  | (#intent, #successful) => "Succeeded payments"
  | (#attempt, #successful) => "Successful attempts"
  | (#intent, #failed) => "Failed payments"
  | (#attempt, #failed) => "Failed attempts"
  | (_, #three_ds_failure_rate) => "3DS failure rate"
  | (_, #not_completed_rate) => "Not completed rate"
  | (_, #processed_amount) => "Processed amount"
  | (_, #avg_ticket) => "Average ticket"
  }

let measureDefinition = (source: source, measure: measure) =>
  switch (source, measure) {
  | (
      #intent,
      #success_rate,
    ) => "Share of payments that succeeded. Payments awaiting customer or merchant action are excluded."
  | (
      #attempt,
      #success_rate,
    ) => "Share of attempts that were charged. Pending attempts are included."
  | (
      #intent,
      #failure_rate,
    ) => "Share of payments that failed. Payments awaiting customer or merchant action are excluded."
  | (
      #attempt,
      #failure_rate,
    ) => "Share of attempts with status failure. Attempts that failed authentication or are awaiting a payment method, confirmation, device data or resolution are excluded."
  | (#intent, #volume) => "Payments created, in any status."
  | (#attempt, #volume) => "Attempts made, in any status. Each retry counts as an attempt."
  | (#intent, #successful) => "Payments with status succeeded."
  | (#attempt, #successful) => "Attempts with status charged."
  | (#intent, #failed) => "Payments with status failed."
  | (#attempt, #failed) => "Attempts with status failure."
  | (_, #three_ds_failure_rate) => "Share of 3DS attempts that failed authentication."
  | (_, #not_completed_rate) => "Share of payments awaiting customer or merchant action."
  | (#intent, #processed_amount) => "Amount of succeeded payments, in one currency."
  | (#attempt, #processed_amount) => "Amount of charged attempts, in one currency."
  | (#intent, #avg_ticket) => "Processed amount divided by succeeded payments, in one currency."
  | (#attempt, #avg_ticket) => "Processed amount divided by charged attempts, in one currency."
  }

let unmeasurableNote = (source: source, measure: measure) =>
  switch (source, measure) {
  | (#intent, #success_rate | #failure_rate) => "No completed payments in this period"
  | (#attempt, #failure_rate) => "No eligible attempts in this period"
  | (_, #three_ds_failure_rate) => "No 3DS attempts in this period"
  | _ => "No data in this period"
  }

let unmeasurableReason = (source: source, measure: measure) =>
  switch (source, measure) {
  | (#intent, #success_rate | #failure_rate) => "all awaiting customer or merchant action"
  | (_, #three_ds_failure_rate) => "no 3DS attempts"
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

let dimensionDescription = (source: source, key: dimension) =>
  switch (source, key) {
  | (_, #connector) => "Processor that handled it."
  | (_, #payment_method) => "Broad method, such as card, wallet or bank transfer."
  | (_, #payment_method_type) => "Specific method, such as credit, debit or Apple Pay."
  | (_, #card_network) => "Card scheme, such as Visa or Mastercard."
  | (_, #authentication_type) => "Whether 3DS was requested."
  | (#intent, #status) => "Payment status, such as succeeded, failed or requires payment method."
  | (#attempt, #status) => "Attempt status, such as charged, failure or authentication failed."
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

let outcomeLabel = (source: source, field) =>
  switch (source, field) {
  | (#attempt, Success) => "Charged"
  | (#attempt, Excluded) => "Authentication failed or awaiting action"
  | (#attempt, Other) => "Other (pending, authorized, declined, voided, expired…)"
  | (#intent, Excluded) => "Waiting on customer or merchant"
  | (#intent, Other) => "Other (cancelled, processing, expired…)"
  | (_, Success) => "Succeeded"
  | (_, Failed) => "Failed"
  | (_, AuthFailed) => "Failed 3DS authentication"
  | (_, Total) => "All"
  }

let viewNote = (selection: selection) => {
  let noun = sourceNoun(selection.source)
  switch (selection.view, selection.split->isNonEmptyArray) {
  | (#trend, true) => `Daily in UTC, for the ${topGroupCount->Int.toString} largest groups.`
  | (#trend, false) => "Daily in UTC, against the same days of the previous period."
  | (#breakdown, true) =>
    `Largest groups by number of ${noun}, up to ${maxBreakdownGroups->Int.toString}.`
  | (#breakdown, false) => "Outcomes in these dates."
  | (#mix, true) =>
    `Share of each UTC day's volume by group, for the ${topGroupCount->Int.toString} largest groups.`
  | (#mix, false) => "Share of each UTC day's volume by outcome."
  | (#table, true) => `Sorted by number of ${noun}, highest first.`
  | (#table, false) => "Outcomes in these dates. Add a split to compare groups."
  }
}

let viewTitle = (selection: selection, ~currency) => {
  let {source, measure, split, view} = selection
  let splitText = split->Array.map(dimensionLabel)->Array.joinWith(" and ")
  let mixRecords = isAmount(measure)
    ? `${currency} ${sourceNoun(source)}`
    : measureLabel(source, #volume)
  switch (split->isNonEmptyArray, view) {
  | (true, #mix) => `${mixRecords} by ${splitText}`
  | (false, #mix) => `${mixRecords} by outcome`
  | (true, #trend | #breakdown | #table) => `${measureLabel(source, measure)} by ${splitText}`
  | (false, #trend) => measureLabel(source, measure)
  | (false, #breakdown | #table) => `${measureLabel(source, #volume)} by outcome`
  }
}

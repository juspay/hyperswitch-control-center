open LogicUtils
open ExplorerTypes
open ExplorerUtils

let domainLabel = (domain: domain) =>
  switch domain {
  | #payments => "Payments"
  | #refunds => "Refunds"
  | #disputes => "Disputes"
  }

let sourceLabel = (source: source) =>
  switch source {
  | #intent => "Intents"
  | #attempt => "Attempts"
  | #refund => "Refunds"
  | #dispute => "Disputes"
  }

let sourceDescription = (source: source) =>
  switch source {
  | #intent => "One row per payment, regardless of retries. Use this view for the customer experience and to compare CIT and MIT."
  | #attempt => "One row per attempt; each retry is a separate attempt. Use this view to analyse how attempts perform."
  | #refund => "One row per refund. Use this view to analyse refund failures by connector, reason and error."
  | #dispute => "One row per dispute. Use this view to track win rate and amounts lost to disputes."
  }

let flowLabel = (flow: flow) =>
  switch flow {
  | #all => "All"
  | #cit => "CIT"
  | #cit_saving => "CIT saving card"
  | #mit => "MIT"
  }

let flowDescription = (flow: flow) =>
  switch flow {
  | #all => "Every payment"
  | #cit => "Customer present, card not saved"
  | #cit_saving => "Customer present, card set to be saved"
  | #mit => "Merchant charged a saved card"
  }

let sourceNoun = (source: source) =>
  switch source {
  | #intent => "payments"
  | #attempt => "attempts"
  | #refund => "refunds"
  | #dispute => "disputes"
  }

let measureLabel = (source: source, measure: measure) =>
  switch (source, measure) {
  | (#dispute, #success_rate) => "Win rate"
  | (#dispute, #failure_rate) => "Loss rate"
  | (_, #success_rate) => "Success rate"
  | (_, #failure_rate) => "Failure rate"
  | (#intent, #volume) => "Payments"
  | (#attempt, #volume) => "Attempts"
  | (#refund, #volume) => "Refunds"
  | (#dispute, #volume) => "Disputes"
  | (#intent, #successful) => "Succeeded payments"
  | (#attempt, #successful) => "Successful attempts"
  | (#refund, #successful) => "Successful refunds"
  | (#dispute, #successful) => "Disputes won"
  | (#intent, #failed) => "Failed payments"
  | (#attempt, #failed) => "Failed attempts"
  | (#refund, #failed) => "Failed refunds"
  | (#dispute, #failed) => "Disputes lost"
  | (_, #authorization_rate) => "Authorization rate"
  | (_, #authorization_failure_rate) => "Authorization failure rate"
  | (#refund, #not_completed_rate) => "Pending rate"
  | (_, #not_completed_rate) => "Not completed rate"
  | (#refund, #not_completed) => "Pending refunds"
  | (#attempt, #not_completed) => "Not completed attempts"
  | (_, #not_completed) => "Not completed payments"
  | (#refund, #processed_amount) => "Refunded amount"
  | (#dispute, #processed_amount) => "Amount won"
  | (_, #processed_amount) => "Processed amount"
  | (_, #lost_amount) => "Amount lost"
  }

let measureDefinition = (source: source, measure: measure) =>
  switch (source, measure) {
  | (
      #intent,
      #success_rate,
    ) => "Share of decided payments that were approved. Payments in progress, under review or cancelled are excluded."
  | (
      #attempt,
      #success_rate,
    ) => "Share of decided attempts that were approved. Attempts never submitted, in progress or voided are excluded."
  | (
      #refund,
      #success_rate,
    ) => "Share of decided refunds that succeeded. Refunds pending or in manual review are excluded."
  | (#dispute, #success_rate) => "Share of decided disputes (won or lost) that were won."
  | (
      #intent,
      #failure_rate,
    ) => "Share of decided payments that failed or expired. Payments in progress, under review or cancelled are excluded."
  | (
      #attempt,
      #failure_rate,
    ) => "Share of decided attempts that were declined, failed 3DS authentication or expired. Attempts never submitted, in progress or voided are excluded."
  | (
      #refund,
      #failure_rate,
    ) => "Share of decided refunds that failed. Refunds pending or in manual review are excluded."
  | (
      #dispute,
      #failure_rate,
    ) => "Share of decided disputes (won or lost) that were lost. Accepted disputes are not counted."
  | (#intent, #volume) => "Payments created, in any status."
  | (#attempt, #volume) => "Attempts made, in any status. Each retry counts as an attempt."
  | (#refund, #volume) => "Refunds created, in any status."
  | (#dispute, #volume) => "Disputes opened, in any status."
  | (#intent, #successful) => "Payments that were approved, whether captured or not."
  | (#attempt, #successful) => "Attempts that were approved, whether captured or not."
  | (#refund, #successful) => "Refunds with status success."
  | (#dispute, #successful) => "Disputes with status won."
  | (#intent, #failed) => "Payments that failed or expired."
  | (#attempt, #failed) => "Attempts that were declined, failed 3DS authentication or expired."
  | (#refund, #failed) => "Refunds that failed at the connector or in the transaction."
  | (#dispute, #failed) => "Disputes with status lost."
  | (
      _,
      #authorization_rate,
    ) => "Share of attempts sent for authorization that were approved. Attempts that failed 3DS authentication are left out."
  | (
      _,
      #authorization_failure_rate,
    ) => "Share of attempts sent for authorization that were declined or expired. Attempts that failed 3DS authentication are left out."
  | (
      #refund,
      #not_completed_rate,
    ) => "Share of all refunds with no final outcome: pending or in manual review. These refunds are left out of the success and failure rates."
  | (
      #attempt,
      #not_completed_rate,
    ) => "Share of all attempts with no final outcome: never submitted, in progress or voided. These attempts are left out of the success, failure and authorization rates."
  | (
      _,
      #not_completed_rate,
    ) => "Share of all payments with no final outcome: awaiting customer or merchant action, processing, under review or cancelled. These payments are left out of the success and failure rates."
  | (
      #refund,
      #not_completed,
    ) => "Refunds with no final outcome: pending or in manual review. These refunds are left out of the success and failure rates."
  | (
      #attempt,
      #not_completed,
    ) => "Attempts with no final outcome: never submitted, in progress or voided. These attempts are left out of the success, failure and authorization rates."
  | (
      _,
      #not_completed,
    ) => "Payments with no final outcome: awaiting customer or merchant action, processing, under review or cancelled. These payments are left out of the success and failure rates."
  | (#intent, #processed_amount) => "Amount of succeeded payments, in one currency."
  | (#attempt, #processed_amount) => "Amount of charged attempts, in one currency."
  | (#refund, #processed_amount) => "Amount of successful refunds, in one currency."
  | (#dispute, #processed_amount) => "Amount of disputes won, in one currency."
  | (
      _,
      #lost_amount,
    ) => "Amount of disputes lost, in one currency. Accepted disputes are not counted."
  }

let unmeasurableNote = (source: source, measure: measure) =>
  switch (source, measure) {
  | (#dispute, #success_rate | #failure_rate) => "No decided disputes in this period"
  | (#intent, #success_rate | #failure_rate) => "No decided payments in this period"
  | (#attempt, #success_rate | #failure_rate) => "No decided attempts in this period"
  | (#refund, #success_rate | #failure_rate) => "No decided refunds in this period"
  | (
      _,
      #authorization_rate | #authorization_failure_rate,
    ) => "No attempts sent for authorization in this period"
  | _ => "No data in this period"
  }

let unmeasurableReason = (source: source, measure: measure) =>
  switch (source, measure) {
  | (#dispute, #success_rate | #failure_rate) => "no decided disputes"
  | (#intent, #success_rate | #failure_rate) => "no decided payments"
  | (#attempt, #success_rate | #failure_rate) => "no decided attempts"
  | (#refund, #success_rate | #failure_rate) => "no decided refunds"
  | (_, #authorization_rate | #authorization_failure_rate) => "none sent for authorization"
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
  | #refund_status => "Refund status"
  | #refund_type => "Refund type"
  | #refund_reason => "Refund reason"
  | #refund_error_message => "Refund error"
  | #dispute_stage => "Dispute stage"
  | #off_session => "Off session"
  | #setup_future_usage => "Setup future usage"
  | #flow => "Flow"
  }

let dimensionDescription = (source: source, key: dimension) =>
  switch (source, key) {
  | (_, #connector) => "Processor that handled it."
  | (_, #payment_method) => "Broad method, such as card, wallet or bank transfer."
  | (_, #payment_method_type) => "Specific method, such as credit, debit or Apple Pay."
  | (_, #card_network) => "Card scheme, such as Visa or Mastercard."
  | (_, #authentication_type) => "Whether 3DS was requested."
  | (#intent, #status) => "Payment status, such as succeeded, failed or requires payment method."
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
  | (
      _,
      #flow,
    ) => "Who started the payment: the customer (CIT), the customer saving the card, or the merchant (MIT)."
  }

let outcomeLabel = (source: source, field) =>
  switch (source, field) {
  | (#attempt, Success) => "Approved"
  | (#attempt, Excluded) => "Not submitted, in progress or voided"
  | (#intent, Success) => "Approved"
  | (#intent, Excluded) => "In progress, under review or cancelled"
  | (#refund, Excluded) => "Pending or in review"
  | (#attempt | #intent | #refund, Other) => "Other"
  | (#dispute, Success) => "Won"
  | (#dispute, Failed) => "Lost"
  | (#dispute, Excluded) => "Challenged"
  | (#dispute, Other) => "Open, accepted, expired or cancelled"
  | (_, Success) => "Succeeded"
  | (_, Failed) => "Failed"
  | (_, AuthenticationFailed) => "Failed 3DS authentication"
  | (_, AuthorizationFailed) => "Declined or expired"
  | (_, Total) => "All"
  }

let viewNote = (selection: selection) => {
  let noun = sourceNoun(selection.source)
  switch (selection.view, selection.split->getGrouping) {
  | (#trend, Split) => `Daily in UTC, for the ${topGroupCount->Int.toString} largest groups.`
  | (#trend, Overall) => "Daily in UTC, against the same days of the previous period."
  | (#breakdown, Split) =>
    `Largest groups by number of ${noun}, up to ${maxBreakdownGroups->Int.toString}.`
  | (#breakdown, Overall) => "Outcomes in these dates."
  | (#mix, Split) =>
    `Share of each UTC day's volume by group, for the ${topGroupCount->Int.toString} largest groups.`
  | (#mix, Overall) => "Share of each UTC day's volume by outcome."
  | (#table, Split) =>
    `Sorted by number of ${noun}, highest first. Click a row to focus on it. Rows with a blank value can't be focused.`
  | (#table, Overall) => "Outcomes in these dates. Add a split to compare groups."
  }
}

let viewTitle = (selection: selection, ~currency) => {
  let {source, measure, split, view} = selection
  let splitText = split->Array.map(dimensionLabel)->Array.joinWith(" and ")
  let mixRecords = isAmount(measure)
    ? `${currency} ${sourceNoun(source)}`
    : measureLabel(source, #volume)
  switch (view, split->getGrouping) {
  | (#mix, Split) => `${mixRecords} by ${splitText}`
  | (#mix, Overall) => `${mixRecords} by outcome`
  | (#trend | #breakdown | #table, Split) => `${measureLabel(source, measure)} by ${splitText}`
  | (#trend, Overall) => measureLabel(source, measure)
  | (#breakdown | #table, Overall) => `${measureLabel(source, #volume)} by outcome`
  }
}

let getDimensionValueLabel = (
  key: dimension,
  value,
  ~profileList: array<OMPSwitchTypes.ompListTypes>,
) =>
  switch (key, value) {
  | (_, "") => `No ${dimensionLabel(key)->String.toLowerCase}`
  | (#flow, _) => value->flowFromString->flowLabel
  | (#profile_id, _) =>
    profileList
    ->Array.find(profile => profile.id == value)
    ->mapOptionOrDefault(value, profile => profile.name)
  | (#status | #refund_status | #refund_type | #dispute_stage, _) => value->snakeToTitle
  | (#connector, _) => value->ConnectorUtils.getDisplayNameForConnector
  | _ => value
  }

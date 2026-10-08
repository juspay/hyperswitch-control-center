open ExplorerTypes

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
  | (#attempt, #failure_rate) => "Share of attempts that failed."
  | (#intent, #volume) => "Payments created, in any status."
  | (#attempt, #volume) => "Attempts made, in any status. Each retry counts as an attempt."
  | (#intent, #successful) => "Payments with status succeeded."
  | (#attempt, #successful) => "Attempts with status charged."
  | (#intent, #failed) => "Payments with status failed."
  | (
      #attempt,
      #failed,
    ) => "Attempts that failed, as the backend counts terminal failures: declined, authentication or authorization failed, router declined, capture or void failed, or expired."
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
  | (_, #three_ds_failure_rate) => "No 3DS attempts in this period"
  | _ => "No data in this period"
  }

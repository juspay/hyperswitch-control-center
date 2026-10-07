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

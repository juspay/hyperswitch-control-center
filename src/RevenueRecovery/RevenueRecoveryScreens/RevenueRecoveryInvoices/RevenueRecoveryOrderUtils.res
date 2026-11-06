let statusVariantMapper: string => RevenueRecoveryOrderTypes.recoveryInvoiceStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "RECOVERED" | "SUCCEEDED" => Succeeded
  | "CANCELLED" => Cancelled
  | "SCHEDULED" => Scheduled
  | "FAILED" | "TERMINATED" => Terminated
  | "PROCESSING" => Processing
  | "QUEUED" => Queued
  | "MONITORING" => Monitoring
  | "PARTIALLYCAPTURED" | "PARTIALLY_RECOVERED" => PartiallyRecovered
  | "PARTIALLYCAPTUREDANDPROCESSING" => PartiallyCapturedAndProcessing
  | _ => Other(statusLabel)
  }

let isHiddenStatus = status => ["no_picked", "pending"]->Array.includes(status->String.toLowerCase)

// Set on invoices the merchant retries, which have no process tracker entries. It keeps the last
// retry it was told about, so only use it for the retry time. `status` is the current state.
let getExternalTriggerNextRetry = dict => {
  open LogicUtils
  dict
  ->getDictfromDict("feature_metadata")
  ->getDictfromDict("revenue_recovery")
  ->getDictfromDict("external_trigger_state")
  ->getDictfromDict("next_retry")
}

// Returned in the shape of the process tracker response, which the details page reads it from
let getNextRetrySchedule = dict => {
  open LogicUtils
  let scheduleTime = dict->getExternalTriggerNextRetry->getString("schedule_time", "")
  scheduleTime->isNonEmptyString
    ? [("schedule_time_for_payment", scheduleTime->JSON.Encode.string)]->Dict.fromArray
    : Dict.make()
}

let statusStringMapper: RevenueRecoveryOrderTypes.recoveryInvoiceStatus => string = statusLabel =>
  switch statusLabel {
  | Succeeded => "Succeeded"
  | Cancelled => "Cancelled"
  | Scheduled => "Scheduled"
  | Processing => "Processing"
  | Terminated => "Terminated"
  | Monitoring => "Monitoring"
  | Queued => "Queued"
  | PartiallyRecovered => "PartiallyRecovered"
  | PartiallyCapturedAndProcessing => "PartiallyCapturedAndProcessing"
  | Other(status) => status
  }

let schedulerStatusVariantMapper: string => RevenueRecoveryOrderTypes.recoverySchedulerStatusType = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "finish" => Finish
  | "scheduled" | _ => Scheduled
  }

let schedulerStatusStringMapper: RevenueRecoveryOrderTypes.recoverySchedulerStatusType => string = statusLabel =>
  switch statusLabel {
  | Finish => "finish"
  | Scheduled => "scheduled"
  }

let attemptTriggeredByVariantMapper: string => RevenueRecoveryOrderTypes.attemptTriggeredByType = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "INTERNAL" => INTERNAL
  | _ => EXTERNAL
  }

let attemptTriggeredByStringMapper: RevenueRecoveryOrderTypes.attemptTriggeredByType => string = statusLabel =>
  switch statusLabel {
  | INTERNAL => "INTERNAL"
  | EXTERNAL => "EXTERNAL"
  }

// Alternative: Simple conversion for your specific format
let convertScheduleTimeToUTC = (scheduleTime: string) => {
  if scheduleTime->String.includes(" ") {
    // "2025-08-15 19:24:18.375771" -> "2025-08-15T19:24:18.375Z"
    scheduleTime->String.replace(" ", "T") ++ "Z"
  } else {
    scheduleTime
  }
}

// Invoices in these statuses have no retries left to show
let finalStatuses: array<RevenueRecoveryOrderTypes.recoveryInvoiceStatus> = [
  Succeeded,
  Cancelled,
  Terminated,
]

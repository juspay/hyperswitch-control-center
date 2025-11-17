let statusVariantMapper: string => RevenueRecoveryOrderTypes.recoveryInvoiceStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "SUCCEEDED" | "RECOVERED" => Recovered
  | "SCHEDULED" => Scheduled
  | "FAILED" | "TERMINATED" | "CANCELLED" => Terminated
  | "PROCESSING" => Processing
  | "QUEUED" => Queued
  | "NOPICKED" => NoPicked
  | "MONITORING" => Monitoring
  | "PARTIALLY_CAPTURED" => PartiallyRecovered
  | _ => Other(statusLabel)
  }

let statusStringMapper: RevenueRecoveryOrderTypes.recoveryInvoiceStatus => string = statusLabel =>
  switch statusLabel {
  | Recovered => "Recovered"
  | Scheduled => "Scheduled"
  | Terminated => "Terminated"
  | Processing => "Processing"
  | Queued => "Queued"
  | NoPicked => "NoPicked"
  | PartiallyRecovered => "PartiallyRecovered"
  | Monitoring => "Monitoring"
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

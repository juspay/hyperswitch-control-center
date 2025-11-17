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

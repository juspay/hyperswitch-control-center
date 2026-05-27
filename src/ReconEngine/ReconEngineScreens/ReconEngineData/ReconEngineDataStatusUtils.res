open ReconEngineTypes

/* ============================== Relative time ============================== */
/* Self-contained so the Data section doesn't reach into the Transactions module. */
let formatRelativeTime = (timestamp: string): string => {
  let date = Js.Date.fromString(timestamp)
  let now = Js.Date.now()
  let diffMs = now -. date->Js.Date.getTime
  let diffMin = diffMs /. 60000.0
  let diffHour = diffMin /. 60.0
  let diffDay = diffHour /. 24.0

  if diffMs < 0.0 {
    "just now"
  } else if diffMin < 1.0 {
    "just now"
  } else if diffMin < 60.0 {
    `${diffMin->Float.toInt->Int.toString}m`
  } else if diffHour < 24.0 {
    `${diffHour->Float.toInt->Int.toString}h`
  } else if diffDay < 7.0 {
    `${diffDay->Float.toInt->Int.toString}d`
  } else {
    let months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ]
    let m = months->Array.get(date->Js.Date.getMonth->Float.toInt)->Option.getOr("")
    let d = date->Js.Date.getDate->Float.toInt->Int.toString
    `${m} ${d}`
  }
}

let ageInHours = (timestamp: string): float => {
  let date = Js.Date.fromString(timestamp)
  let diffMs = Js.Date.now() -. date->Js.Date.getTime
  diffMs /. (1000.0 *. 60.0 *. 60.0)
}

/* ============================== Ingestion / Transformation status ============================== */

type ingestionKind =
  | IngestionDone
  | IngestionInFlight
  | IngestionFailed
  | IngestionStale

let getIngestionKind = (status: ingestionTransformationStatusType): ingestionKind =>
  switch status {
  | Processed => IngestionDone
  | Pending | Processing => IngestionInFlight
  | Failed => IngestionFailed
  | Discarded | UnknownIngestionTransformationStatus => IngestionStale
  }

let getIngestionTagColor = (status: ingestionTransformationStatusType): TagBinding.tagColor =>
  switch status->getIngestionKind {
  | IngestionDone => Success
  | IngestionInFlight => Primary
  | IngestionFailed => Error
  | IngestionStale => Neutral
  }

let getIngestionLabel = (status: ingestionTransformationStatusType): string =>
  switch status {
  | Pending => "Pending"
  | Processing => "Processing"
  | Processed => "Processed"
  | Failed => "Failed"
  | Discarded => "Superseded"
  | UnknownIngestionTransformationStatus => "Unknown"
  }

let getIngestionDescription = (status: ingestionTransformationStatusType): string =>
  switch status {
  | Pending => "File received, queued for processing"
  | Processing => "Reading and validating the file"
  | Processed => "File parsed and entries created"
  | Failed => "File could not be processed"
  | Discarded => "Replaced by a newer version of this file"
  | UnknownIngestionTransformationStatus => ""
  }

/* ============================== Processing-entry status (transformed entries) ============================== */

type entryKind =
  | EntryProcessed
  | EntryInFlight
  | EntryNeedsReview
  | EntryInactive

let getEntryKind = (status: processingEntryStatus): entryKind =>
  switch status {
  | Processed => EntryProcessed
  | Pending => EntryInFlight
  | NeedsManualReview => EntryNeedsReview
  | Archived | Void | UnknownProcessingEntryStatus => EntryInactive
  }

let getEntryTagColor = (status: processingEntryStatus): TagBinding.tagColor =>
  switch status->getEntryKind {
  | EntryProcessed => Success
  | EntryInFlight => Primary
  | EntryNeedsReview => Warning
  | EntryInactive => Neutral
  }

let getEntryLabel = (status: processingEntryStatus): string =>
  switch status {
  | Pending => "Pending"
  | Processed => "Processed"
  | NeedsManualReview => "Needs review"
  | Archived => "Archived"
  | Void => "Void"
  | UnknownProcessingEntryStatus => "Unknown"
  }

let entryStatusToWire = (status: processingEntryStatus): string =>
  switch status {
  | Pending => "pending"
  | Processed => "processed"
  | NeedsManualReview => "needs_manual_review"
  | Archived => "archived"
  | Void => "void"
  | UnknownProcessingEntryStatus => "unknown"
  }

/* Plain-English translation of the manual-review reason — backend codes mean nothing
 to a merchant. Each line is one sentence the merchant can act on. */
let getNeedsReviewExplanation = (reason: needsManualReviewType): string =>
  switch reason {
  | NoRulesFound => "No reconciliation rule matched this entry — create or update a rule that targets this account."
  | StagingEntryCurrencyMismatch => "Entry currency doesn't match the account's currency."
  | MissingSearchIdentifierValue => "The unique identifier on this row is empty — check the source file."
  | DuplicateEntry => "Another row with the same identifier already exists in this run."
  | NoExpectationEntryFound => "Reconciliation could not find a matching expected entry."
  | MultipleExceptedEntriesFound => "Reconciliation found more than one matching expected entry."
  | MissingMatchField => "A field required for matching is missing on this entry."
  | MissingUniqueField => "The unique-constraint field is missing on this entry."
  | MissingGroupingField => "A grouping field expected by the rule is missing."
  | UnknownNeedsManualReviewType => "Needs manual review."
  }

let getNeedsReviewShort = (reason: needsManualReviewType): string =>
  switch reason {
  | NoRulesFound => "No rule"
  | StagingEntryCurrencyMismatch => "Currency mismatch"
  | MissingSearchIdentifierValue => "Missing identifier"
  | DuplicateEntry => "Duplicate"
  | NoExpectationEntryFound => "No expected entry"
  | MultipleExceptedEntriesFound => "Multiple matches"
  | MissingMatchField => "Missing match field"
  | MissingUniqueField => "Missing unique field"
  | MissingGroupingField => "Missing grouping field"
  | UnknownNeedsManualReviewType => "Manual review"
  }

/* ============================== Source-type recognition ============================== */
/* The ingestion config's `data` JSON carries an `ingestion_type` string. We don't ship
 exhaustive enums here — we recognise the common ones and gracefully fall back. */

type sourceTypeKind =
  | ManualUpload
  | S3Bucket
  | SftpServer
  | PspWebhook
  | OtherSource(string)

let parseSourceTypeKind = (raw: string): sourceTypeKind => {
  let lc = raw->String.toLowerCase
  if lc === "manual" {
    ManualUpload
  } else if lc->String.includes("s3") {
    S3Bucket
  } else if lc->String.includes("sftp") {
    SftpServer
  } else if lc === "" || lc === "unknown" {
    OtherSource("Source")
  } else {
    /* Treat anything we don't explicitly recognise as a PSP-style webhook source
     (Adyen, Stripe, etc.) — usually a named external party. */
    PspWebhook
  }
}

let sourceTypeFromConfig = (config: ingestionConfigType): sourceTypeKind => {
  open LogicUtils
  let raw =
    config.data
    ->getDictFromJsonObject
    ->getOptionString("ingestion_type")
    ->Option.getOr("")
  parseSourceTypeKind(raw)
}

let sourceTypeFromRawString = (raw: string): sourceTypeKind => parseSourceTypeKind(raw)

let sourceTypeLabel = (kind: sourceTypeKind): string =>
  switch kind {
  | ManualUpload => "Manual upload"
  | S3Bucket => "S3 bucket"
  | SftpServer => "SFTP"
  | PspWebhook => "Webhook"
  | OtherSource(name) => name
  }

let sourceTypeIcon = (kind: sourceTypeKind): string =>
  switch kind {
  | ManualUpload => "nd-upload-up"
  | S3Bucket => "nd-cloud"
  | SftpServer => "nd-server"
  | PspWebhook => "nd-external-link-square"
  | OtherSource(_) => "nd-reports"
  }

/* ============================== Sources smart-views ============================== */

type sourcesSmartView =
  | AllFiles
  | Today
  | NeedsAttentionFiles
  | InProgressFiles
  | FailedFiles

let allSourcesSmartViews: array<sourcesSmartView> = [
  AllFiles,
  Today,
  NeedsAttentionFiles,
  InProgressFiles,
  FailedFiles,
]

/* Backend returns every (ingestion_history_id, version) row, including the discarded
   earlier versions. The list view only ever wants the latest non-discarded version per
   file — older versions live inside the detail pane's timeline. */
let dedupeToLatest = (items: array<ingestionHistoryType>): array<ingestionHistoryType> => {
  let bestByFile: Dict.t<ingestionHistoryType> = Dict.make()
  items->Array.forEach(it => {
    switch it.status {
    | Discarded => ()
    | _ =>
      switch bestByFile->Dict.get(it.ingestion_history_id) {
      | Some(existing) =>
        if it.version > existing.version {
          bestByFile->Dict.set(it.ingestion_history_id, it)
        }
      | None => bestByFile->Dict.set(it.ingestion_history_id, it)
      }
    }
  })
  bestByFile->Dict.valuesToArray
}

let sourcesSmartViewLabel = (v: sourcesSmartView): string =>
  switch v {
  | AllFiles => "All files"
  | Today => "Today"
  | NeedsAttentionFiles => "Needs attention"
  | InProgressFiles => "In progress"
  | FailedFiles => "Failed"
  }

let sourcesSmartViewMatches = (v: sourcesSmartView, ingestion: ingestionHistoryType): bool =>
  switch v {
  | AllFiles => true
  | Today => ageInHours(ingestion.created_at) < 24.0
  | NeedsAttentionFiles =>
    switch ingestion.status {
    | Failed => true
    | _ => false
    }
  | InProgressFiles =>
    switch ingestion.status {
    | Pending | Processing => true
    | _ => false
    }
  | FailedFiles =>
    switch ingestion.status {
    | Failed => true
    | _ => false
    }
  }

/* ============================== Transformed-entries smart-views ============================== */

type entriesSmartView =
  | AllEntries
  | NeedsReview
  | EntriesPending
  | EntriesProcessed
  | EntriesVoid

let allEntriesSmartViews: array<entriesSmartView> = [
  AllEntries,
  NeedsReview,
  EntriesPending,
  EntriesProcessed,
  EntriesVoid,
]

let entriesSmartViewLabel = (v: entriesSmartView): string =>
  switch v {
  | AllEntries => "All entries"
  | NeedsReview => "Needs manual review"
  | EntriesPending => "Pending"
  | EntriesProcessed => "Processed"
  | EntriesVoid => "Void"
  }

let entriesSmartViewStatuses = (v: entriesSmartView): array<processingEntryStatus> =>
  switch v {
  | AllEntries => [Pending, Processed, NeedsManualReview, Void]
  | NeedsReview => [NeedsManualReview]
  | EntriesPending => [Pending]
  | EntriesProcessed => [Processed]
  | EntriesVoid => [Void]
  }

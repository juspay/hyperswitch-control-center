open ReconEngineTypes
open ReconEngineExceptionTransactionTypes

/* Re-export the shared status kind / colour helpers used everywhere in the revamp.
   The domainTransactionStatus is the same domain object across Transactions and
   Exceptions screens; only the smart-view bucketing differs. */
let getStatusKind = ReconEngineTransactionsStatusUtils.getStatusKind
let getStatusLabel = ReconEngineTransactionsStatusUtils.getStatusLabel
let getStatusDescription = ReconEngineTransactionsStatusUtils.getStatusDescription
let getTagColor = ReconEngineTransactionsStatusUtils.getTagColor
let getStripeClass = ReconEngineTransactionsStatusUtils.getStripeClass
let formatRelativeTime = ReconEngineTransactionsStatusUtils.formatRelativeTime
let ageInDays = ReconEngineTransactionsStatusUtils.ageInDays

/* Pre-built triage buckets for the left-rail tabs on the Exceptions listing.
   Each maps to a status set + an aging rule; bucketing is what merchants think
   in ("what needs my action?"), not "which rule produced this." */
type smartView =
  | AllOpen
  | NeedsAttention
  | AwaitingConfirmation
  | Missing
  | StaleOpen

let allSmartViews: array<smartView> = [
  AllOpen,
  NeedsAttention,
  AwaitingConfirmation,
  Missing,
  StaleOpen,
]

let smartViewLabel = (view: smartView): string =>
  switch view {
  | AllOpen => "All Open"
  | NeedsAttention => "Needs Attention"
  | AwaitingConfirmation => "Awaiting"
  | Missing => "Missing"
  | StaleOpen => "Stale (>7d)"
  }

let smartViewIcon = (view: smartView): string =>
  switch view {
  | AllOpen => "nd-alert-octagon"
  | NeedsAttention => "nd-alert-circle"
  | AwaitingConfirmation => "nd-clock"
  | Missing => "nd-cross-circle"
  | StaleOpen => "nd-clock-snooze"
  }

/* The 8 exception statuses surfaced on the listing — same set the legacy screen
 queried. Drop anything terminal (Matched/Posted/Void/Archived). */
let allExceptionStatuses: array<domainTransactionStatus> = [
  Expected,
  Missing,
  OverAmount(Mismatch),
  UnderAmount(Mismatch),
  OverAmount(Expected),
  UnderAmount(Expected),
  DataMismatch,
  PartiallyReconciled,
]

let mismatchStatuses: array<domainTransactionStatus> = [
  OverAmount(Mismatch),
  UnderAmount(Mismatch),
  DataMismatch,
]

let awaitingStatuses: array<domainTransactionStatus> = [
  Expected,
  OverAmount(Expected),
  UnderAmount(Expected),
  PartiallyReconciled,
]

let smartViewStatuses = (view: smartView): array<domainTransactionStatus> =>
  switch view {
  | AllOpen => allExceptionStatuses
  | NeedsAttention => mismatchStatuses
  | AwaitingConfirmation => awaitingStatuses
  | Missing => [Missing]
  | StaleOpen => awaitingStatuses /* additional aging filter applied client-side */
  }

let isStaleView = (view: smartView): bool =>
  switch view {
  | StaleOpen => true
  | _ => false
  }

/* Pick the action we surface as the "recommended" card in the right pane and
   on the detail page. Falls back to NoResolutionActionNeeded when no relevant
   action makes sense (the detail screen still shows the catalogue of options). */
let getRecommendedResolution = (status: domainTransactionStatus): resolvingException =>
  switch status {
  | DataMismatch
  | OverAmount(Mismatch)
  | UnderAmount(Mismatch) =>
    EditEntry
  | Expected
  | OverAmount(Expected)
  | UnderAmount(Expected) =>
    MarkAsReceived
  | Missing => CreateNewEntry
  | PartiallyReconciled => ForceReconcile
  | _ => NoResolutionActionNeeded
  }

let resolutionLabel = (action: resolvingException): string =>
  switch action {
  | ForceReconcile => "Force Match"
  | VoidTransaction => "Ignore Transaction"
  | EditEntry => "Edit Entry"
  | MarkAsReceived => "Mark as Received"
  | CreateNewEntry => "Create New Entry"
  | LinkStagingEntriesToTransaction => "Replace with Transformed Entry"
  | NoResolutionActionNeeded => ""
  }

let resolutionIcon = (action: resolvingException): string =>
  switch action {
  | ForceReconcile => "nd-check-circle-outline"
  | VoidTransaction => "nd-delete-dustbin-02"
  | EditEntry => "nd-pencil-edit-line"
  | MarkAsReceived => "nd-check-circle-outline"
  | CreateNewEntry => "nd-plus"
  | LinkStagingEntriesToTransaction => "nd-swap-arrow-horizontal"
  | NoResolutionActionNeeded => ""
  }

let resolutionHint = (action: resolvingException): string =>
  switch action {
  | ForceReconcile => "Mark this transaction as matched, bypassing validation."
  | VoidTransaction => "Remove this transaction from reconciliation."
  | EditEntry => "Fix the data on one of the entries to bring the transaction in line."
  | MarkAsReceived => "Mark the expected entry as received without editing it."
  | CreateNewEntry => "Add a missing entry manually."
  | LinkStagingEntriesToTransaction => "Match this transaction with an existing transformed entry."
  | NoResolutionActionNeeded => ""
  }

/* Bucket totals for the rail count pills:
 (mismatch, awaiting, missing, stale, allOpen) */
let countByView = (exceptions: array<transactionType>): (int, int, int, int, int) => {
  exceptions->Array.reduce((0, 0, 0, 0, 0), ((m, a, miss, stale, all), txn) => {
    let isStale = txn.created_at->ageInDays > 7.0
    let status = txn.transaction_status
    let isAwaiting = awaitingStatuses->Array.includes(status)
    let isMismatch = mismatchStatuses->Array.includes(status)
    let isMissing = status === Missing
    (
      m + (isMismatch ? 1 : 0),
      a + (isAwaiting ? 1 : 0),
      miss + (isMissing ? 1 : 0),
      stale + (isAwaiting && isStale ? 1 : 0),
      all + 1,
    )
  })
}

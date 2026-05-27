open ReconEngineTypes

type statusKind =
  | MatchedKind
  | AwaitingKind
  | MismatchKind
  | PartialKind
  | InactiveKind

let getStatusKind = (status: domainTransactionStatus): statusKind =>
  switch status {
  | Posted(_) | Matched(_) => MatchedKind
  | Expected | OverAmount(Expected) | UnderAmount(Expected) | Missing => AwaitingKind
  | OverAmount(Mismatch) | UnderAmount(Mismatch) | DataMismatch => MismatchKind
  | PartiallyReconciled => PartialKind
  | Archived | Void | _ => InactiveKind
  }

let getStripeClass = (status: domainTransactionStatus): string =>
  switch status->getStatusKind {
  | MatchedKind => "bg-nd_green-500"
  | AwaitingKind => "bg-nd_primary_blue-500"
  | MismatchKind => "bg-nd_red-500"
  | PartialKind => "bg-nd_orange-400"
  | InactiveKind => "bg-nd_gray-300"
  }

let getTagColor = (status: domainTransactionStatus): TagBinding.tagColor =>
  switch status->getStatusKind {
  | MatchedKind => Success
  | AwaitingKind => Primary
  | MismatchKind => Error
  | PartialKind => Warning
  | InactiveKind => Neutral
  }

let getStatusLabel = (status: domainTransactionStatus): string =>
  switch status {
  | Posted(Manual) => "Posted"
  | Matched(Auto) => "Matched"
  | Matched(Manual) => "Matched (Manual)"
  | Matched(Force) => "Force Matched"
  | OverAmount(Expected) => "Positive Variance"
  | OverAmount(Mismatch) => "Positive Mismatch"
  | UnderAmount(Expected) => "Negative Variance"
  | UnderAmount(Mismatch) => "Negative Mismatch"
  | DataMismatch => "Data Mismatch"
  | PartiallyReconciled => "Partially Matched"
  | Expected => "Expected"
  | Missing => "Missing"
  | Archived => "Archived"
  | Void => "Void"
  | _ => "Unknown"
  }

let getStatusDescription = (status: domainTransactionStatus): string =>
  switch status {
  | Posted(Manual) => "Manually posted to the ledger"
  | Matched(Auto) => "Reconciled automatically by a rule"
  | Matched(Manual) => "Reconciled by a manual action"
  | Matched(Force) => "Force matched (validation bypassed)"
  | Expected => "Awaiting confirmation from the other side"
  | OverAmount(Expected) => "Awaiting match; amount higher than expected so far"
  | OverAmount(Mismatch) => "Confirmed amount is higher than expected"
  | UnderAmount(Expected) => "Awaiting match; amount lower than expected so far"
  | UnderAmount(Mismatch) => "Confirmed amount is lower than expected"
  | DataMismatch => "Amount matches but other fields don't"
  | PartiallyReconciled => "Some entries matched, others still pending"
  | Missing => "Expected entry never arrived"
  | Archived => "Superseded by a newer version"
  | Void => "Ignored, excluded from the ledger"
  | _ => ""
  }

/* Smart-view buckets — pre-built filtered views for the left rail. */
type smartView =
  | AllTransactions
  | Matched
  | AwaitingConfirmation
  | NeedsAttention
  | StaleAwaiting

let smartViewLabel = (view: smartView): string =>
  switch view {
  | AllTransactions => "All Transactions"
  | Matched => "Matched"
  | AwaitingConfirmation => "Awaiting Confirmation"
  | NeedsAttention => "Needs Attention"
  | StaleAwaiting => "Stale (>7d)"
  }

let smartViewIcon = (view: smartView): string =>
  switch view {
  | AllTransactions => "nd-reports"
  | Matched => "nd-check-circle-outline"
  | AwaitingConfirmation => "nd-clock"
  | NeedsAttention => "nd-alert-circle"
  | StaleAwaiting => "nd-clock-snooze"
  }

let smartViewStatuses = (view: smartView): array<domainTransactionStatus> =>
  switch view {
  | AllTransactions => [
      Expected,
      Missing,
      OverAmount(Mismatch),
      UnderAmount(Mismatch),
      OverAmount(Expected),
      UnderAmount(Expected),
      Posted(Manual),
      Matched(Auto),
      Matched(Manual),
      Matched(Force),
      PartiallyReconciled,
      DataMismatch,
    ]
  | Matched => [Posted(Manual), Matched(Auto), Matched(Manual), Matched(Force)]
  | AwaitingConfirmation => [Expected, OverAmount(Expected), UnderAmount(Expected)]
  | NeedsAttention => [OverAmount(Mismatch), UnderAmount(Mismatch), DataMismatch, Missing]
  | StaleAwaiting => [Expected, OverAmount(Expected), UnderAmount(Expected)]
  }

let isStaleView = (view: smartView): bool =>
  switch view {
  | StaleAwaiting => true
  | _ => false
  }

let allSmartViews: array<smartView> = [
  AllTransactions,
  Matched,
  AwaitingConfirmation,
  NeedsAttention,
  StaleAwaiting,
]

let countByStatusKind = (transactions: array<transactionType>): (int, int, int, int) => {
  /* (matched, awaiting, mismatch, partial) */
  transactions->Array.reduce((0, 0, 0, 0), ((m, a, x, p), txn) =>
    switch txn.transaction_status->getStatusKind {
    | MatchedKind => (m + 1, a, x, p)
    | AwaitingKind => (m, a + 1, x, p)
    | MismatchKind => (m, a, x + 1, p)
    | PartialKind => (m, a, x, p + 1)
    | InactiveKind => (m, a, x, p)
    }
  )
}

/* Relative time formatter — "20m", "2h", "3d", "Jan 4" — for compact list rows. */
let formatRelativeTime = (timestamp: string): string => {
  let date = Js.Date.fromString(timestamp)
  let now = Js.Date.now()
  let diffMs = now -. date->Js.Date.getTime
  let diffMin = diffMs /. 60000.0
  let diffHour = diffMin /. 60.0
  let diffDay = diffHour /. 24.0

  if diffMin < 1.0 {
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

let ageInDays = (timestamp: string): float => {
  let date = Js.Date.fromString(timestamp)
  let diffMs = Js.Date.now() -. date->Js.Date.getTime
  diffMs /. (1000.0 *. 60.0 *. 60.0 *. 24.0)
}

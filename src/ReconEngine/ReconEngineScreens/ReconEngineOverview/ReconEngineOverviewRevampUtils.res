open ReconEngineTypes

/* ============================== Status bucketing ==============================
   The Overview cares about three buckets, regardless of the exact backend status
   subtype. Anything Archived/Void/unknown is excluded so it doesn't dilute the
   reconciliation rate. */

type bucket = Matched | Mismatched | Awaiting | Other

let bucketOf = (status: domainTransactionStatus): bucket =>
  switch status {
  | Posted(_) | Matched(_) => Matched
  | OverAmount(Mismatch) | UnderAmount(Mismatch) | DataMismatch => Mismatched
  | Expected
  | OverAmount(Expected)
  | UnderAmount(Expected)
  | Missing
  | PartiallyReconciled =>
    Awaiting
  | Archived | Void | UnknownDomainTransactionStatus => Other
  | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnderAmount(UnknownDomainTransactionAmountMismatchStatus) =>
    Other
  }

type bucketCounts = {
  matched: int,
  mismatched: int,
  awaiting: int,
}

let bucketCount = (transactions: array<transactionType>): bucketCounts =>
  transactions->Array.reduce({matched: 0, mismatched: 0, awaiting: 0}, (acc, t) =>
    switch t.transaction_status->bucketOf {
    | Matched => {...acc, matched: acc.matched + 1}
    | Mismatched => {...acc, mismatched: acc.mismatched + 1}
    | Awaiting => {...acc, awaiting: acc.awaiting + 1}
    | Other => acc
    }
  )

let reconciliationRate = (counts: bucketCounts): option<float> => {
  let total = counts.matched + counts.mismatched + counts.awaiting
  total === 0 ? None : Some(counts.matched->Int.toFloat *. 100.0 /. total->Int.toFloat)
}

/* ============================== Money helpers ============================== */

let sumCreditWhere = (
  transactions: array<transactionType>,
  predicate: transactionType => bool,
): float =>
  transactions->Array.reduce(0.0, (acc, t) => predicate(t) ? acc +. t.credit_amount.value : acc)

let matchedPredicate = (t: transactionType): bool =>
  switch t.transaction_status->bucketOf {
  | Matched => true
  | _ => false
  }

let mismatchedPredicate = (t: transactionType): bool =>
  switch t.transaction_status->bucketOf {
  | Mismatched => true
  | _ => false
  }

let awaitingPredicate = (t: transactionType): bool =>
  switch t.transaction_status->bucketOf {
  | Awaiting => true
  | _ => false
  }

/* The page works in mixed currencies — we surface the most common one as the
 "headline" currency for the KPI cards and group anything else into "+N more". */
let primaryCurrency = (transactions: array<transactionType>): string => {
  let counts: Dict.t<int> = Dict.make()
  transactions->Array.forEach(t => {
    let c = t.credit_amount.currency
    if c !== "" {
      let prev = counts->Dict.get(c)->Option.getOr(0)
      counts->Dict.set(c, prev + 1)
    }
  })
  let entries = counts->Dict.toArray
  entries
  ->Array.toSorted(((_, a), (_, b)) => (b - a)->Int.toFloat)
  ->Array.get(0)
  ->Option.map(((c, _)) => c)
  ->Option.getOr("")
}

/* ============================== Time helpers ============================== */

let daysSince = (timestamp: string): float => {
  let date = Js.Date.fromString(timestamp)
  let now = Js.Date.now()
  let diffMs = now -. date->Js.Date.getTime
  diffMs /. (1000.0 *. 60.0 *. 60.0 *. 24.0)
}

let isWithinDays = (timestamp: string, days: float): bool => {
  let d = daysSince(timestamp)
  d >= 0.0 && d <= days
}

let isOlderThanDays = (timestamp: string, days: float): bool => daysSince(timestamp) > days

let dateKey = (timestamp: string): string => timestamp->String.slice(~start=0, ~end=10)

let todayKey = (): string => Js.Date.toISOString(Js.Date.make())->String.slice(~start=0, ~end=10)

/* ============================== Number formatting ============================== */

let pct1 = (p: float): string => {
  let rounded = (p *. 10.0)->Float.toInt->Int.toFloat /. 10.0
  rounded >= 100.0 ? "100%" : `${rounded->Float.toString}%`
}

/* Compact integer ("1.2k", "3.4M") — used inside small cards. */
let compactInt = (n: int): string => {
  let f = n->Int.toFloat
  if f >= 1_000_000.0 {
    let v = (f /. 100_000.0)->Float.toInt->Int.toFloat /. 10.0
    `${v->Float.toString}M`
  } else if f >= 10_000.0 {
    let v = (f /. 1_000.0)->Float.toInt->Int.toFloat
    `${v->Float.toString}k`
  } else if f >= 1_000.0 {
    let v = (f /. 100.0)->Float.toInt->Int.toFloat /. 10.0
    `${v->Float.toString}k`
  } else {
    n->Int.toString
  }
}

/* ============================== Day-grouped counts (for sparklines) ============================== */

/* Returns an array of (dateKey, count) sorted ascending over the last `days` days,
 filling missing days with zero. */
let dailyCountsLast = (
  transactions: array<transactionType>,
  ~days: int,
  ~predicate: transactionType => bool=_t => true,
): array<(string, int)> => {
  let buckets: Dict.t<int> = Dict.make()
  let now = Js.Date.now()
  let dayMs = 1000.0 *. 60.0 *. 60.0 *. 24.0
  let keys = []
  for i in days - 1 downto 0 {
    let d = Js.Date.fromFloat(now -. i->Int.toFloat *. dayMs)
    let key = d->Js.Date.toISOString->String.slice(~start=0, ~end=10)
    buckets->Dict.set(key, 0)
    keys->Array.push(key)
  }
  transactions->Array.forEach(t => {
    if predicate(t) {
      let key = t.effective_at->String.slice(~start=0, ~end=10)
      switch buckets->Dict.get(key) {
      | Some(v) => buckets->Dict.set(key, v + 1)
      | None => ()
      }
    }
  })
  keys->Array.map(k => (k, buckets->Dict.get(k)->Option.getOr(0)))
}

/* Day-grouped sum-of-credit for sparklines of money matched / at risk. */
let dailySumLast = (
  transactions: array<transactionType>,
  ~days: int,
  ~predicate: transactionType => bool,
): array<(string, float)> => {
  let buckets: Dict.t<float> = Dict.make()
  let now = Js.Date.now()
  let dayMs = 1000.0 *. 60.0 *. 60.0 *. 24.0
  let keys = []
  for i in days - 1 downto 0 {
    let d = Js.Date.fromFloat(now -. i->Int.toFloat *. dayMs)
    let key = d->Js.Date.toISOString->String.slice(~start=0, ~end=10)
    buckets->Dict.set(key, 0.0)
    keys->Array.push(key)
  }
  transactions->Array.forEach(t => {
    if predicate(t) {
      let key = t.effective_at->String.slice(~start=0, ~end=10)
      switch buckets->Dict.get(key) {
      | Some(v) => buckets->Dict.set(key, v +. t.credit_amount.value)
      | None => ()
      }
    }
  })
  keys->Array.map(k => (k, buckets->Dict.get(k)->Option.getOr(0.0)))
}

/* Delta (period-over-period) given a sorted series. Compares the last half to the
 first half — a simple but informative directional read for the KPI cards. */
let halfOverHalfDelta = (series: array<float>): option<float> => {
  let n = series->Array.length
  if n < 4 {
    None
  } else {
    let half = n / 2
    let firstHalf = series->Array.slice(~start=0, ~end=half)
    let secondHalf = series->Array.slice(~start=half, ~end=n)
    let sum = arr => arr->Array.reduce(0.0, (a, b) => a +. b)
    let a = firstHalf->sum
    let b = secondHalf->sum
    a === 0.0 ? None : Some((b -. a) *. 100.0 /. a)
  }
}

let halfOverHalfDeltaInt = (series: array<int>): option<float> =>
  series->Array.map(Int.toFloat)->halfOverHalfDelta

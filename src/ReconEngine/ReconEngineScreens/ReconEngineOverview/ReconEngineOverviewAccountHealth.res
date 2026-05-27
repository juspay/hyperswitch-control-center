open Typography
open ReconEngineTypes
open ReconEngineOverviewRevampUtils

/* Each account exposes per-side amounts. We collapse debit+credit per status
   to a single number for the proportional bar — merchants want to know "how
   much of this account is matched" without parsing direction. */

type segmentColor = MatchedSeg | PendingSeg | ExpectedSeg | MismatchedSeg

let segmentBgClass = (s: segmentColor): string =>
  switch s {
  | MatchedSeg => "bg-nd_green-500"
  | PendingSeg => "bg-nd_primary_blue-300"
  | ExpectedSeg => "bg-nd_primary_blue-500"
  | MismatchedSeg => "bg-nd_red-500"
  }

let segmentTextColor = (s: segmentColor): string =>
  switch s {
  | MatchedSeg => "text-nd_green-600"
  | PendingSeg => "text-nd_primary_blue-500"
  | ExpectedSeg => "text-nd_primary_blue-600"
  | MismatchedSeg => "text-nd_red-600"
  }

type segmentVal = {
  color: segmentColor,
  label: string,
  amount: float,
}

let totalAccountFlow = (acct: accountType): float => {
  acct.matched_debits.value +.
  acct.matched_credits.value +.
  acct.posted_debits.value +.
  acct.posted_credits.value +.
  acct.pending_debits.value +.
  acct.pending_credits.value +.
  acct.expected_debits.value +.
  acct.expected_credits.value +.
  acct.mismatched_debits.value +.
  acct.mismatched_credits.value
}

let getSegments = (acct: accountType): array<segmentVal> => [
  {
    color: MatchedSeg,
    label: "Matched",
    amount: acct.matched_debits.value +.
    acct.matched_credits.value +.
    acct.posted_debits.value +.
    acct.posted_credits.value,
  },
  {
    color: PendingSeg,
    label: "Pending",
    amount: acct.pending_debits.value +. acct.pending_credits.value,
  },
  {
    color: ExpectedSeg,
    label: "Expected",
    amount: acct.expected_debits.value +. acct.expected_credits.value,
  },
  {
    color: MismatchedSeg,
    label: "Mismatched",
    amount: acct.mismatched_debits.value +. acct.mismatched_credits.value,
  },
]

module Row = {
  @react.component
  let make = (~account: accountType) => {
    let total = totalAccountFlow(account)
    let segments = getSegments(account)
    let matchedAmt = (
      segments->Array.get(0)->Option.getOr({color: MatchedSeg, label: "", amount: 0.0})
    ).amount
    let healthPct = total === 0.0 ? 0.0 : matchedAmt *. 100.0 /. total
    let healthTone =
      healthPct >= 90.0
        ? "text-nd_green-600"
        : healthPct >= 60.0
        ? "text-nd_primary_blue-600"
        : healthPct >= 30.0
        ? "text-nd_orange-600"
        : "text-nd_red-600"

    let accountTypeLabel = switch account.account_type {
    | Credit => "Credit"
    | Debit => "Debit"
    | UnknownAccountTypeVariant => "—"
    }
    let accountTypeColor: TagBinding.tagColor = switch account.account_type {
    | Credit => Success
    | Debit => Primary
    | UnknownAccountTypeVariant => Neutral
    }

    <button
      type_="button"
      onClick={_ =>
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/sources/${account.account_id}`),
        )}
      className="text-left w-full rounded-xl border border-nd_gray-150 bg-white hover:border-nd_gray-300 hover:bg-nd_gray-25 transition-colors px-4 py-3.5 flex flex-col gap-3">
      <div className="flex flex-row items-center gap-2.5">
        <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
          {account.account_name->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {`(${account.currency})`->React.string}
        </span>
        <TagBinding text=accountTypeLabel color=accountTypeColor variant=Subtle size=Xs />
        <span className="flex-1" />
        <span className={`${body.sm.semibold} ${healthTone} tabular-nums`}>
          {`${pct1(healthPct)} health`->React.string}
        </span>
      </div>
      {total === 0.0
        ? <span className={`${body.xs.medium} text-nd_gray-400`}>
            {"No activity in this period."->React.string}
          </span>
        : <>
            <div className="w-full h-2.5 rounded-full overflow-hidden bg-nd_gray-100 flex flex-row">
              {segments
              ->Array.mapWithIndex((s, i) => {
                let widthPct = s.amount *. 100.0 /. total
                widthPct === 0.0
                  ? React.null
                  : <span
                      key={i->Int.toString}
                      className={s.color->segmentBgClass}
                      style={ReactDOMStyle.make(~width=`${widthPct->Float.toString}%`, ())}
                    />
              })
              ->React.array}
            </div>
            <div className="flex flex-row flex-wrap gap-x-5 gap-y-1">
              {segments
              ->Array.mapWithIndex((s, i) =>
                s.amount === 0.0
                  ? React.null
                  : <span
                      key={i->Int.toString}
                      className={`${body.xs.medium} text-nd_gray-500 inline-flex items-center gap-1.5`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${s.color->segmentBgClass}`} />
                      <span className={`${body.xs.semibold} ${s.color->segmentTextColor}`}>
                        {s.label->React.string}
                      </span>
                      <span className="font-mono tabular-nums text-nd_gray-700">
                        {`${CurrencyFormatUtils.valueFormatter(
                            s.amount,
                            AmountWithSuffix,
                          )} ${account.currency}`->React.string}
                      </span>
                    </span>
              )
              ->React.array}
            </div>
          </>}
    </button>
  }
}

@react.component
let make = (~accounts: array<accountType>) => {
  /* Show accounts with the most activity first. */
  let sorted = accounts->Array.toSorted((a, b) => {
    let totalA = totalAccountFlow(a)
    let totalB = totalAccountFlow(b)
    if totalB > totalA {
      1.0
    } else if totalB < totalA {
      -1.0
    } else {
      0.0
    }
  })

  <div className="flex flex-col gap-3 px-6">
    <div className="flex flex-row items-baseline justify-between">
      <span className={`${body.sm.semibold} text-nd_gray-700 uppercase tracking-wider`}>
        {`Account health · ${accounts
          ->Array.length
          ->Int.toString} account${accounts->Array.length === 1 ? "" : "s"}`->React.string}
      </span>
      <button
        type_="button"
        onClick={_ =>
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/sources"))}
        className={`${body.sm.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 flex flex-row items-center gap-1`}>
        {"View all sources"->React.string}
        <Icon name="nd-external-link-square" size=12 customIconColor="#2B6FFF" />
      </button>
    </div>
    {sorted->Array.length === 0
      ? <div
          className={`${body.sm.medium} text-nd_gray-400 px-4 py-6 rounded-xl border border-dashed border-nd_gray-200 text-center`}>
          {"No accounts configured."->React.string}
        </div>
      : <div className="flex flex-col gap-2">
          {sorted
          ->Array.map(acc => <Row key={acc.account_id} account=acc />)
          ->React.array}
        </div>}
  </div>
}

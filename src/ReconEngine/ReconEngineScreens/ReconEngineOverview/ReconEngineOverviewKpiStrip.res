open Typography
open ReconEngineTypes
open ReconEngineOverviewRevampUtils

type tone = Neutral | Success | Warning | Danger | Info

let toneClass = (t: tone): string =>
  switch t {
  | Neutral => "text-nd_gray-800"
  | Success => "text-nd_green-600"
  | Warning => "text-nd_orange-600"
  | Danger => "text-nd_red-600"
  | Info => "text-nd_primary_blue-600"
  }

let toneStroke = (t: tone): string =>
  switch t {
  | Neutral => "#606B85"
  | Success => "#7AB891"
  | Warning => "#F39B45"
  | Danger => "#EA8A8F"
  | Info => "#2B6FFF"
  }

let toneFill = (t: tone): string =>
  switch t {
  | Neutral => "rgba(96,107,133,0.08)"
  | Success => "rgba(122,184,145,0.10)"
  | Warning => "rgba(243,155,69,0.10)"
  | Danger => "rgba(234,138,143,0.10)"
  | Info => "rgba(43,111,255,0.10)"
  }

module DeltaPill = {
  @react.component
  let make = (~delta: option<float>, ~inverted: bool=false) =>
    switch delta {
    | None =>
      <span className={`${body.xs.medium} text-nd_gray-400 tabular-nums`}>
        {"— no change"->React.string}
      </span>
    | Some(d) =>
      let up = d >= 0.0
      /* For "inverted" metrics (at-risk, exceptions, stale), up is bad. */
      let isGood = inverted ? !up : up
      let arrow = up ? "↑" : "↓"
      let color = isGood ? "text-nd_green-600" : "text-nd_red-600"
      let abs = if d < 0.0 {
        -.d
      } else {
        d
      }
      let display = (abs *. 10.0)->Float.toInt->Int.toFloat /. 10.0
      <span className={`${body.xs.semibold} ${color} tabular-nums`}>
        {`${arrow} ${display->Float.toString}%`->React.string}
      </span>
    }
}

module Card = {
  @react.component
  let make = (
    ~label: string,
    ~value: string,
    ~tone: tone=Neutral,
    ~series: array<float>,
    ~delta: option<float>,
    ~invertedDelta: bool=false,
    ~onClick: option<ReactEvent.Mouse.t => unit>=?,
    ~footnote: string="",
  ) => {
    let clickable = onClick !== None
    let baseCls = `flex-1 min-w-0 rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5 flex flex-col gap-2 text-left transition-colors`
    let interactiveCls = clickable
      ? `${baseCls} cursor-pointer hover:border-nd_gray-300 hover:bg-nd_gray-25`
      : baseCls

    <button type_="button" ?onClick className=interactiveCls>
      <div className="flex flex-row items-baseline justify-between gap-2">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
          {label->React.string}
        </span>
        <DeltaPill delta inverted=invertedDelta />
      </div>
      <div className="flex flex-row items-end justify-between gap-2">
        <span className={`${heading.xl.semibold} ${tone->toneClass} tabular-nums tracking-tight`}>
          {value->React.string}
        </span>
        <div className="flex-shrink-0 opacity-90">
          <ReconEngineOverviewSparkline
            data=series stroke={tone->toneStroke} fill={tone->toneFill} width=120 height=32
          />
        </div>
      </div>
      {footnote === ""
        ? React.null
        : <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
            {footnote->React.string}
          </span>}
    </button>
  }
}

@react.component
let make = (~transactions: array<transactionType>) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let counts = bucketCount(transactions)
  let recRate = reconciliationRate(counts)

  let primaryCcy = primaryCurrency(transactions)
  let matchedMoney = sumCreditWhere(transactions, matchedPredicate)
  let atRiskMoney = sumCreditWhere(transactions, mismatchedPredicate)

  let staleCount =
    transactions
    ->Array.filter(t => awaitingPredicate(t) && isOlderThanDays(t.effective_at, 7.0))
    ->Array.length

  /* Sparkline series — last 14 days. */
  let days = 14
  let matchedDaily = dailyCountsLast(transactions, ~days, ~predicate=matchedPredicate)
  let mismatchedDaily = dailyCountsLast(transactions, ~days, ~predicate=mismatchedPredicate)
  let awaitingDaily = dailyCountsLast(transactions, ~days, ~predicate=awaitingPredicate)
  let matchedMoneyDaily = dailySumLast(transactions, ~days, ~predicate=matchedPredicate)
  let atRiskMoneyDaily = dailySumLast(transactions, ~days, ~predicate=mismatchedPredicate)

  let rateDaily = matchedDaily->Array.mapWithIndex(((_, m), idx) => {
    let (_, ms) = mismatchedDaily->Array.get(idx)->Option.getOr(("", 0))
    let (_, aw) = awaitingDaily->Array.get(idx)->Option.getOr(("", 0))
    let total = m + ms + aw
    total === 0 ? 0.0 : m->Int.toFloat *. 100.0 /. total->Int.toFloat
  })

  let rateSeries = rateDaily
  let matchedMoneySeries = matchedMoneyDaily->Array.map(((_, v)) => v)
  let atRiskMoneySeries = atRiskMoneyDaily->Array.map(((_, v)) => v)
  let mismatchedCountSeries = mismatchedDaily->Array.map(((_, c)) => c->Int.toFloat)
  /* Stale items don't have a meaningful daily series (it's a snapshot), but we
   can show count of awaiting items per day as a directional proxy. */
  let staleProxySeries = awaitingDaily->Array.map(((_, c)) => c->Int.toFloat)

  /* Deltas — half-over-half within the 14-day window. */
  let rateDelta = halfOverHalfDelta(rateSeries)
  let matchedMoneyDelta = halfOverHalfDelta(matchedMoneySeries)
  let atRiskMoneyDelta = halfOverHalfDelta(atRiskMoneySeries)
  let mismatchDelta = halfOverHalfDelta(mismatchedCountSeries)
  let staleDelta = halfOverHalfDelta(staleProxySeries)

  let goto = (path: string) => {
    mixpanelEvent(~eventName="recon_engine_overview_kpi_clicked")
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=path))
  }

  let recValue = switch recRate {
  | Some(p) => pct1(p)
  | None => "—"
  }

  let moneyMatchedValue =
    primaryCcy === ""
      ? CurrencyFormatUtils.valueFormatter(matchedMoney, AmountWithSuffix)
      : `${CurrencyFormatUtils.valueFormatter(matchedMoney, AmountWithSuffix)} ${primaryCcy}`

  let atRiskValue =
    primaryCcy === ""
      ? CurrencyFormatUtils.valueFormatter(atRiskMoney, AmountWithSuffix)
      : `${CurrencyFormatUtils.valueFormatter(atRiskMoney, AmountWithSuffix)} ${primaryCcy}`

  <div
    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 px-6 pt-4 pb-2 flex-shrink-0">
    <Card
      label="Reconciliation rate"
      value=recValue
      tone=Info
      series=rateSeries
      delta=rateDelta
      onClick={_ => goto("/v1/recon-engine/transactions")}
      footnote={`${counts.matched->Int.toString} of ${(counts.matched +
        counts.mismatched +
        counts.awaiting)->Int.toString} matched`}
    />
    <Card
      label="Money matched"
      value=moneyMatchedValue
      tone=Success
      series=matchedMoneySeries
      delta=matchedMoneyDelta
      onClick={_ =>
        goto(
          "/v1/recon-engine/transactions?status=matched_auto,matched_manual,matched_force,posted_manual",
        )}
      footnote={`${compactInt(counts.matched)} transactions`}
    />
    <Card
      label="Money at risk"
      value=atRiskValue
      tone=Danger
      series=atRiskMoneySeries
      delta=atRiskMoneyDelta
      invertedDelta=true
      onClick={_ => goto("/v1/recon-engine/exceptions/recon")}
      footnote={`${compactInt(counts.mismatched)} mismatched`}
    />
    <Card
      label="Open exceptions"
      value={counts.mismatched->Int.toString}
      tone=Warning
      series=mismatchedCountSeries
      delta=mismatchDelta
      invertedDelta=true
      onClick={_ => goto("/v1/recon-engine/exceptions/recon")}
      footnote="across all rules"
    />
    <Card
      label="Stale (> 7d)"
      value={staleCount->Int.toString}
      tone=Neutral
      series=staleProxySeries
      delta=staleDelta
      invertedDelta=true
      onClick={_ =>
        goto(
          "/v1/recon-engine/transactions?status=expected,over_amount_expected,under_amount_expected",
        )}
      footnote="awaiting > 7 days"
    />
  </div>
}

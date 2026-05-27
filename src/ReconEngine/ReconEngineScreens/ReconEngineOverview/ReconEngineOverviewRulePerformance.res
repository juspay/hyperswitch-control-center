@@warning("-45")
/* Disabled warning 45 (shadowed-label): the strategy helpers below pattern-match
   on variants from ReconEngineRulesTypes, so accessing `account_id` on the
   matched value is unambiguous even though ReconEngineTypes also exposes a
   field with that name. */

open Typography
open ReconEngineTypes
open ReconEngineOverviewRevampUtils
let plainStrategySummary = (strategy: ReconEngineRulesTypes.reconStrategyType): string => {
  open ReconEngineRulesTypes
  switch strategy {
  | OneToOne(SingleSingle(_)) => "Match one source row to one target row"
  | OneToOne(SingleMany(_)) => "Match one source row to many target rows"
  | OneToOne(ManySingle(_)) => "Group source rows, then match to one target row"
  | OneToOne(ManyMany(_)) => "Group source rows, then match to many target rows"
  | OneToMany(SingleSingle(_)) => "Split one source across multiple target accounts"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "Strategy not recognised"
  }
}

let strategyBackendCaption = (strategy: ReconEngineRulesTypes.reconStrategyType): string => {
  open ReconEngineRulesTypes
  switch strategy {
  | OneToOne(SingleSingle(_)) => "one_to_one · single_single"
  | OneToOne(SingleMany(_)) => "one_to_one · single_many"
  | OneToOne(ManySingle(_)) => "one_to_one · many_single"
  | OneToOne(ManyMany(_)) => "one_to_one · many_many"
  | OneToMany(SingleSingle(_)) => "one_to_many · single_single"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "unknown"
  }
}

let getSourceAccountId = (strategy: ReconEngineRulesTypes.reconStrategyType): string => {
  open ReconEngineRulesTypes
  switch strategy {
  | OneToOne(SingleSingle(d)) => d.source_account.account_id
  | OneToOne(SingleMany(d)) => d.source_account.account_id
  | OneToOne(ManySingle(d)) => d.source_account.account_id
  | OneToOne(ManyMany(d)) => d.source_account.account_id
  | OneToMany(SingleSingle(d)) => d.source_account.account_id
  | _ => ""
  }
}

let getTargetAccountIds = (strategy: ReconEngineRulesTypes.reconStrategyType): array<string> => {
  open ReconEngineRulesTypes
  switch strategy {
  | OneToOne(SingleSingle(d)) => [d.target_account.account_id]
  | OneToOne(SingleMany(d)) => [d.target_account.account_id]
  | OneToOne(ManySingle(d)) => [d.target_account.account_id]
  | OneToOne(ManyMany(d)) => [d.target_account.account_id]
  | OneToMany(SingleSingle(d)) =>
    switch d.target_accounts {
    | Percentage({targets}) | Fixed({targets}) => targets->Array.map(((t, _)) => t.account_id)
    | UnknownTargetsType => []
    }
  | _ => []
  }
}

let accountNameOf = (accounts: array<accountType>, id: string): string =>
  accounts
  ->Array.find(a => a.account_id === id)
  ->Option.map(a => a.account_name)
  ->Option.getOr("—")

module Card = {
  @react.component
  let make = (
    ~rule: ReconEngineRulesTypes.rulePayload,
    ~accounts: array<accountType>,
    ~transactions: array<transactionType>,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    /* Transactions for this rule only. */
    let ruleTxns = transactions->Array.filter(t => t.rule.rule_id === rule.rule_id)
    let counts = bucketCount(ruleTxns)
    let total = counts.matched + counts.mismatched + counts.awaiting
    let rate = total === 0 ? None : Some(counts.matched->Int.toFloat *. 100.0 /. total->Int.toFloat)

    /* 14-day match count series for sparkline. */
    let matchedSeries =
      dailyCountsLast(ruleTxns, ~days=14, ~predicate=matchedPredicate)->Array.map(((_, c)) =>
        c->Int.toFloat
      )
    let delta = halfOverHalfDelta(matchedSeries)

    let sourceName = accountNameOf(accounts, rule.strategy->getSourceAccountId)
    let targetNames =
      rule.strategy
      ->getTargetAccountIds
      ->Array.map(id => accountNameOf(accounts, id))

    let targetLabel = switch targetNames {
    | [] => "—"
    | [t] => t
    | many =>
      `${many->Array.get(0)->Option.getOr("—")} +${(many->Array.length - 1)->Int.toString} more`
    }

    let statusDot = rule.is_active ? "bg-nd_green-500" : "bg-nd_gray-300"
    let statusLabel = rule.is_active ? "ACTIVE" : "INACTIVE"
    let statusLabelCls = rule.is_active ? "text-nd_green-600" : "text-nd_gray-500"
    let strokeColor = rule.is_active ? "#2B6FFF" : "#A1A8B8"

    let rateText = switch rate {
    | Some(p) => pct1(p)
    | None => "—"
    }

    let onCardClick = (_: ReactEvent.Mouse.t) => {
      mixpanelEvent(~eventName="recon_engine_overview_rule_card_clicked")
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/rules/${rule.rule_id}`),
      )
    }

    let onViewTxns = (ev: ReactEvent.Mouse.t) => {
      ev->ReactEvent.Mouse.stopPropagation
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/transactions?rule_id=${rule.rule_id}`,
        ),
      )
    }

    let deltaPill = switch delta {
    | None =>
      <span className={`${body.xs.medium} text-nd_gray-400 tabular-nums`}>
        {"— no change"->React.string}
      </span>
    | Some(d) =>
      let up = d >= 0.0
      let arrow = up ? "↑" : "↓"
      let color = up ? "text-nd_green-600" : "text-nd_red-600"
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

    <button
      type_="button"
      onClick={onCardClick}
      className="text-left rounded-xl border border-nd_gray-150 bg-white px-4 py-4 flex flex-col gap-3 hover:border-nd_gray-300 hover:bg-nd_gray-25 transition-colors min-w-0">
      <div className="flex flex-row items-center gap-2">
        <span className={`w-2 h-2 rounded-full flex-shrink-0 ${statusDot}`} />
        <span className={`${body.xs.semibold} ${statusLabelCls} uppercase tracking-wider`}>
          {statusLabel->React.string}
        </span>
        <span
          className={`${body.xs.semibold} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 uppercase tracking-wider`}>
          {`Priority ${rule.priority->Int.toString}`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.md.semibold} text-nd_gray-800 truncate`}>
          {rule.rule_name->React.string}
        </span>
        <div className="flex flex-row items-center gap-1.5 min-w-0">
          <span className={`${body.sm.medium} text-nd_gray-600 truncate`}>
            {sourceName->React.string}
          </span>
          <Icon name="arrow-right" size=10 customIconColor="#A1A8B8" />
          <span className={`${body.sm.medium} text-nd_gray-600 truncate`}>
            {targetLabel->React.string}
          </span>
        </div>
      </div>
      <div className="flex flex-col gap-0.5">
        <span className={`${body.sm.medium} text-nd_gray-700`}>
          {plainStrategySummary(rule.strategy)->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-400 font-mono tracking-tight`}>
          {strategyBackendCaption(rule.strategy)->React.string}
        </span>
      </div>
      <div className="h-px bg-nd_gray-100" />
      <div className="flex flex-row items-end justify-between gap-2">
        <div className="flex flex-col gap-0.5 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Match rate"->React.string}
          </span>
          <span
            className={`${heading.lg.semibold} ${rule.is_active
                ? "text-nd_gray-800"
                : "text-nd_gray-400"} tabular-nums tracking-tight`}>
            {rateText->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-500 tabular-nums`}>
            {`${counts.matched->compactInt} of ${total->compactInt}`->React.string}
          </span>
        </div>
        <div className="flex flex-col items-end gap-1">
          <ReconEngineOverviewSparkline data=matchedSeries stroke=strokeColor width=120 height=32 />
          {deltaPill}
        </div>
      </div>
      <div className="flex flex-row items-center justify-between gap-2">
        <button
          type_="button"
          onClick=onViewTxns
          className={`${body.sm.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 flex flex-row items-center gap-1`}>
          {"View transactions"->React.string}
          <Icon name="nd-external-link-square" size=12 customIconColor="#2B6FFF" />
        </button>
        <span className={`${body.xs.medium} text-nd_gray-400`}>
          {"View rule details →"->React.string}
        </span>
      </div>
    </button>
  }
}

@react.component
let make = (
  ~rules: array<ReconEngineRulesTypes.rulePayload>,
  ~accounts: array<accountType>,
  ~transactions: array<transactionType>,
) =>
  <div className="flex flex-col gap-3 px-6">
    <div className="flex flex-row items-baseline justify-between">
      <span className={`${body.sm.semibold} text-nd_gray-700 uppercase tracking-wider`}>
        {`Per-rule performance · ${rules
          ->Array.length
          ->Int.toString} rule${rules->Array.length === 1 ? "" : "s"}`->React.string}
      </span>
      <button
        type_="button"
        onClick={_ =>
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/rules"))}
        className={`${body.sm.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 flex flex-row items-center gap-1`}>
        {"Open rule library"->React.string}
        <Icon name="nd-external-link-square" size=12 customIconColor="#2B6FFF" />
      </button>
    </div>
    {rules->Array.length === 0
      ? <div
          className={`${body.sm.medium} text-nd_gray-400 px-4 py-6 rounded-xl border border-dashed border-nd_gray-200 text-center`}>
          {"No recon rules configured."->React.string}
        </div>
      : <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
          {rules
          ->Array.map(rule => <Card key={rule.rule_id} rule accounts transactions />)
          ->React.array}
        </div>}
  </div>

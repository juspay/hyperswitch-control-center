@@warning("-45")

open Typography
open ReconEngineTypes
open ReconEngineRulesRevampUtils

/* ============================== Filter state ============================== */

type statusView = AllStatus | ActiveOnly | InactiveOnly

let statusViewLabel = (v: statusView): string =>
  switch v {
  | AllStatus => "All rules"
  | ActiveOnly => "Active"
  | InactiveOnly => "Inactive"
  }

let allStatusViews: array<statusView> = [AllStatus, ActiveOnly, InactiveOnly]

type strategyView = AllStrategy | OneToOneStrategy | OneToManyStrategy

let strategyViewLabel = (v: strategyView): string =>
  switch v {
  | AllStrategy => "All strategies"
  | OneToOneStrategy => "One-to-one"
  | OneToManyStrategy => "One-to-many"
  }

let allStrategyViews: array<strategyView> = [AllStrategy, OneToOneStrategy, OneToManyStrategy]

let strategyKindMatches = (v: strategyView, s: ReconEngineRulesTypes.reconStrategyType): bool =>
  switch (v, s) {
  | (AllStrategy, _) => true
  | (OneToOneStrategy, OneToOne(_)) => true
  | (OneToManyStrategy, OneToMany(_)) => true
  | _ => false
  }

/* ============================== KPI strip ============================== */

module KpiCard = {
  @react.component
  let make = (
    ~label: string,
    ~value: string,
    ~tone: string="text-nd_gray-800",
    ~hint: string="",
    ~valueIsName: bool=false,
    ~onValueClick: option<unit => unit>=?,
  ) => {
    let clickable = onValueClick->Option.isSome
    let valueTypography = valueIsName ? body.md.semibold : heading.lg.semibold
    let valueCls = `${valueTypography} ${tone} tabular-nums tracking-tight truncate block ${clickable
        ? "cursor-pointer hover:underline"
        : ""}`
    <div
      className="min-w-0 rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5 flex flex-col gap-0.5 overflow-hidden">
      <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
        {label->React.string}
      </span>
      <span className=valueCls title=value onClick={_ => onValueClick->Option.forEach(fn => fn())}>
        {value->React.string}
      </span>
      {hint === ""
        ? React.null
        : <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
            {hint->React.string}
          </span>}
    </div>
  }
}

module KpiStrip = {
  @react.component
  let make = (
    ~rules: array<ReconEngineRulesTypes.rulePayload>,
    ~transactions: array<transactionType>,
  ) => {
    let total = rules->Array.length
    let active = rules->Array.filter(r => r.is_active)->Array.length
    let inactive = total - active

    /* Top performer = highest match rate among active rules with ≥1 transaction. */
    let topPerf =
      rules
      ->Array.filter(r => r.is_active)
      ->Array.map(r => (r, computePerformance(transactions, r.rule_id)))
      ->Array.filter(((_, p)) => p.matched + p.mismatched + p.awaiting > 0)
      ->Array.toSorted(((_, a), (_, b)) =>
        switch (a.rate, b.rate) {
        | (Some(ra), Some(rb)) =>
          if rb > ra {
            1.0
          } else if rb < ra {
            -1.0
          } else {
            0.0
          }
        | (Some(_), None) => -1.0
        | (None, Some(_)) => 1.0
        | (None, None) => 0.0
        }
      )
      ->Array.get(0)

    let (topName, topHint, topClick) = switch topPerf {
    | Some((r, p)) => (
        r.rule_name,
        switch p.rate {
        | Some(rate) => `${formatPct(rate)} match · ${p.matched->Int.toString} matched`
        | None => ""
        },
        Some(
          () =>
            RescriptReactRouter.push(
              GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/rules/${r.rule_id}`),
            ),
        ),
      )
    | None => ("—", "", None)
    }

    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 px-6 pt-2 pb-2">
      <KpiCard label="Total rules" value={total->Int.toString} hint="configured" />
      <KpiCard
        label="Active" value={active->Int.toString} tone="text-nd_green-600" hint="currently firing"
      />
      <KpiCard
        label="Inactive"
        value={inactive->Int.toString}
        tone={inactive === 0 ? "text-nd_gray-800" : "text-nd_orange-600"}
        hint={inactive === 0 ? "none paused" : "paused or disabled"}
      />
      <KpiCard
        label="Top performer"
        value=topName
        tone="text-nd_primary_blue-600"
        hint=topHint
        valueIsName=true
        onValueClick=?topClick
      />
    </div>
  }
}

/* ============================== Status tabs (underline) ============================== */

module StatusTabs = {
  @react.component
  let make = (
    ~statusView: statusView,
    ~setStatusView: (statusView => statusView) => unit,
    ~counts: (int, int, int),
  ) => {
    let (allC, activeC, inactiveC) = counts
    let countFor = (v: statusView) =>
      switch v {
      | AllStatus => allC
      | ActiveOnly => activeC
      | InactiveOnly => inactiveC
      }

    let tab = (v: statusView) => {
      let active = v === statusView
      let labelColor = active ? "text-nd_gray-800" : "text-nd_gray-500 hover:text-nd_gray-700"
      let underline = active ? "border-nd_primary_blue-500" : "border-transparent"
      let countPill = active
        ? "bg-nd_primary_blue-50 text-nd_primary_blue-600"
        : "bg-nd_gray-100 text-nd_gray-500"
      <button
        key={v->statusViewLabel}
        type_="button"
        onClick={_ => setStatusView(_ => v)}
        className={`flex flex-row items-center gap-2 px-3.5 py-3 -mb-px border-b-2 ${underline} ${labelColor} transition-colors`}>
        <span className={`${body.sm.medium} whitespace-nowrap`}>
          {v->statusViewLabel->React.string}
        </span>
        <span
          className={`${body.xs.medium} px-1.5 h-[18px] min-w-[22px] inline-flex items-center justify-center rounded-full tabular-nums ${countPill}`}>
          {v->countFor->Int.toString->React.string}
        </span>
      </button>
    }

    <div
      className="flex flex-row items-end gap-1 px-6 border-b border-nd_gray-150 bg-white flex-shrink-0 overflow-x-auto">
      {allStatusViews->Array.map(tab)->React.array}
    </div>
  }
}

/* ============================== Toolbar (search + strategy chips) ============================== */

module Toolbar = {
  @react.component
  let make = (
    ~strategyView: strategyView,
    ~setStrategyView: (strategyView => strategyView) => unit,
    ~searchText: string,
    ~setSearchText: (string => string) => unit,
    ~stratCounts: (int, int, int),
    ~visibleCount: int,
    ~totalCount: int,
  ) => {
    let (allC, oneOneC, oneManyC) = stratCounts
    let countFor = (v: strategyView) =>
      switch v {
      | AllStrategy => allC
      | OneToOneStrategy => oneOneC
      | OneToManyStrategy => oneManyC
      }

    let chip = (v: strategyView) => {
      let active = v === strategyView
      let cls = active
        ? "bg-nd_primary_blue-50 text-nd_primary_blue-600 border-nd_primary_blue-200"
        : "bg-white text-nd_gray-500 border-nd_gray-150 hover:bg-nd_gray-25 hover:text-nd_gray-700"
      let pillCls = active ? "bg-white text-nd_primary_blue-600" : "bg-nd_gray-100 text-nd_gray-500"
      <button
        key={v->strategyViewLabel}
        type_="button"
        onClick={_ => setStrategyView(_ => v)}
        className={`${body.sm.medium} px-3 py-1.5 rounded-lg border transition-colors flex flex-row items-center gap-1.5 ${cls}`}>
        <span> {v->strategyViewLabel->React.string} </span>
        {v === AllStrategy
          ? React.null
          : <span
              className={`${body.xs.medium} px-1.5 min-w-[18px] h-[16px] inline-flex items-center justify-center rounded-full tabular-nums ${pillCls}`}>
              {v->countFor->Int.toString->React.string}
            </span>}
      </button>
    }

    <div
      className="flex flex-row flex-wrap items-center gap-2 px-6 py-3 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <div
        className="flex flex-row items-center gap-2 px-3 h-9 max-w-80 min-w-[320px] rounded-lg border border-nd_gray-150 bg-white">
        <Icon name="search" size=14 customIconColor="#A1A8B8" />
        <input
          type_="text"
          value={searchText}
          onChange={ev => {
            let value = (ev->ReactEvent.Form.target)["value"]
            setSearchText(_ => value)
          }}
          placeholder="Search by rule name or description"
          className={`flex-1 bg-transparent outline-none border-none placeholder:text-nd_gray-400 ${body.sm.medium} text-nd_gray-800`}
        />
      </div>
      <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider ml-2`}>
        {"Strategy"->React.string}
      </span>
      <div className="flex flex-row gap-1.5">
        {allStrategyViews->Array.map(chip)->React.array}
      </div>
      <span className="flex-1" />
      <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
        {`${visibleCount->Int.toString} of ${totalCount->Int.toString}`->React.string}
      </span>
    </div>
  }
}

/* ============================== Table row ============================== */

module Row = {
  @react.component
  let make = (
    ~rule: ReconEngineRulesTypes.rulePayload,
    ~accounts: array<accountType>,
    ~transactions: array<transactionType>,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let perf = computePerformance(transactions, rule.rule_id)
    let total = perf.matched + perf.mismatched + perf.awaiting
    let pctOpt = perf.rate
    let pct = pctOpt->Option.getOr(0.0)
    let pctText = switch pctOpt {
    | Some(p) => formatPct(p)
    | None => "—"
    }

    let sourceName = accountName(accounts, rule.strategy->getSourceAccountId)
    let targetSpecs = rule.strategy->getTargetSpecs
    let targetLabel = switch targetSpecs {
    | [] => "—"
    | [t] => accountName(accounts, t.account_id)
    | many =>
      let head =
        many
        ->Array.get(0)
        ->Option.map(t => accountName(accounts, t.account_id))
        ->Option.getOr("—")
      `${head} +${(many->Array.length - 1)->Int.toString} more`
    }

    let barColor = if pct >= 90.0 {
      "bg-nd_green-500"
    } else if pct >= 50.0 {
      "bg-nd_orange-300"
    } else if total === 0 {
      "bg-nd_gray-200"
    } else {
      "bg-nd_red-500"
    }

    let statusDot = rule.is_active ? "bg-nd_green-500" : "bg-nd_gray-300"
    let statusLabel = rule.is_active ? "Active" : "Inactive"
    let statusBg = rule.is_active
      ? "bg-nd_green-50 text-nd_green-600"
      : "bg-nd_gray-100 text-nd_gray-500"

    let onRowClick = _ => {
      mixpanelEvent(~eventName="recon_engine_rules_row_clicked")
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/rules/${rule.rule_id}`),
      )
    }

    <tr
      className="group hover:bg-nd_gray-25 border-b border-nd_gray-100 cursor-pointer transition-colors"
      onClick=onRowClick>
      <td className="py-3.5 pl-6 pr-2 w-12 align-middle">
        <span
          className={`${body.xs.semibold} text-nd_gray-600 bg-nd_gray-50 border border-nd_gray-150 rounded-md inline-flex items-center justify-center min-w-[28px] h-[22px] px-1.5 tabular-nums`}>
          {rule.priority->Int.toString->React.string}
        </span>
      </td>
      <td className="py-3.5 px-4 align-middle min-w-0">
        <div className="flex flex-col gap-0.5 min-w-0">
          <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {rule.rule_name->React.string}
          </span>
          {rule.rule_description === ""
            ? React.null
            : <span className={`${body.xs.medium} text-nd_gray-500 truncate max-w-[480px]`}>
                {rule.rule_description->React.string}
              </span>}
        </div>
      </td>
      <td className="py-3.5 px-4 align-middle whitespace-nowrap">
        <span className="inline-flex flex-row items-center gap-2">
          <span
            className={`${body.xs.medium} text-nd_gray-700 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5`}>
            {sourceName->React.string}
          </span>
          <Icon name="arrow-right" size=10 customIconColor="#A1A8B8" />
          <span
            className={`${body.xs.medium} text-nd_gray-700 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5`}>
            {targetLabel->React.string}
          </span>
        </span>
      </td>
      <td className="py-3.5 px-4 align-middle whitespace-nowrap">
        <div className="flex flex-col gap-0.5">
          <span className={`${body.sm.medium} text-nd_gray-700`}>
            {plainStrategyShortSummary(rule.strategy)->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-400 font-mono tracking-tight`}>
            {strategyBackendCaption(rule.strategy)->React.string}
          </span>
        </div>
      </td>
      <td className="py-3.5 px-4 align-middle w-[200px]">
        <div className="flex flex-col gap-1 min-w-[150px]">
          <div className="flex flex-row items-center gap-2.5">
            <div className="flex-1 h-1.5 rounded-full bg-nd_gray-100 overflow-hidden">
              <div
                className={`h-full rounded-full ${barColor}`}
                style={ReactDOMStyle.make(~width=`${pct->Float.toString}%`, ())}
              />
            </div>
            <span className={`${body.xs.semibold} text-nd_gray-700 tabular-nums w-12 text-right`}>
              {pctText->React.string}
            </span>
          </div>
          <span className={`${body.xs.medium} text-nd_gray-400 tabular-nums`}>
            {`${perf.matched->Int.toString} / ${total->Int.toString} matched`->React.string}
          </span>
        </div>
      </td>
      <td className="py-3.5 px-4 align-middle">
        <span
          className={`${body.xs.medium} inline-flex flex-row items-center gap-1.5 px-2.5 py-0.5 rounded-full ${statusBg}`}>
          <span className={`w-1.5 h-1.5 rounded-full ${statusDot}`} />
          {statusLabel->React.string}
        </span>
      </td>
      <td className="py-3.5 px-4 align-middle whitespace-nowrap">
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {relativeDate(rule.last_modified_at)->React.string}
        </span>
      </td>
      <td className="py-3.5 pr-6 pl-2 align-middle w-8 text-right">
        <Icon name="chevron-right" size=14 customIconColor="#A1A8B8" />
      </td>
    </tr>
  }
}

/* ============================== Table head ============================== */

module ColumnHeader = {
  @react.component
  let make = () => {
    let thBase = `py-2.5 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider bg-nd_gray-25 sticky top-0 z-10 border-b border-nd_gray-150`
    <thead>
      <tr>
        <th className={`${thBase} pl-6 pr-2 w-12`}> {"Pri"->React.string} </th>
        <th className={`${thBase} px-4`}> {"Rule"->React.string} </th>
        <th className={`${thBase} px-4`}> {"Flow"->React.string} </th>
        <th className={`${thBase} px-4`}> {"Strategy"->React.string} </th>
        <th className={`${thBase} px-4 w-[200px]`}> {"Match rate"->React.string} </th>
        <th className={`${thBase} px-4`}> {"Status"->React.string} </th>
        <th className={`${thBase} px-4`}> {"Modified"->React.string} </th>
        <th className={`${thBase} pr-6 pl-2 w-8`} />
      </tr>
    </thead>
  }
}

/* ============================== Main listing ============================== */

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRulesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getTransactions = ReconEngineHooks.useGetTransactions()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rules, setRules) = React.useState(_ => [])
  let (accounts, setAccounts) = React.useState(_ => [])
  let (transactions, setTransactions) = React.useState(_ => [])
  let (statusView, setStatusView) = React.useState(_ => AllStatus)
  let (strategyView, setStrategyView) = React.useState(_ => AllStrategy)
  let (searchText, setSearchText) = React.useState(_ => "")

  let fetchAll = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let rulesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#RECON_RULES,
        ~methodType=Get,
      )

      let rulesP = async () => {
        try {
          let res = await fetchDetails(rulesUrl)
          let sortedRules =
            res
            ->getArrayDataFromJson(ruleItemToObjMapper)
            ->Array.toSorted((a, b) => (a.priority - b.priority)->Int.toFloat)
          setRules(_ => sortedRules)
        } catch {
        | _ => ()
        }
      }
      let accountsP = async () => {
        try {
          let res = await getAccounts()
          setAccounts(_ => res)
        } catch {
        | _ => ()
        }
      }
      let txP = async () => {
        try {
          let res = await getTransactions()
          setTransactions(_ => res)
        } catch {
        | _ => ()
        }
      }

      let _ = await Promise.all([rulesP(), accountsP(), txP()])
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load rules"))
    }
  }

  React.useEffect0(() => {
    fetchAll()->ignore
    None
  })

  let statusCounts = React.useMemo(() => {
    let all = rules->Array.length
    let active = rules->Array.filter(r => r.is_active)->Array.length
    (all, active, all - active)
  }, [rules])

  let strategyCounts = React.useMemo(() => {
    let all = rules->Array.length
    let oneOne =
      rules
      ->Array.filter(r =>
        switch r.strategy {
        | OneToOne(_) => true
        | _ => false
        }
      )
      ->Array.length
    let oneMany =
      rules
      ->Array.filter(r =>
        switch r.strategy {
        | OneToMany(_) => true
        | _ => false
        }
      )
      ->Array.length
    (all, oneOne, oneMany)
  }, [rules])

  let visibleRules = React.useMemo(() => {
    rules->Array.filter(r => {
      let statusMatches = switch statusView {
      | AllStatus => true
      | ActiveOnly => r.is_active
      | InactiveOnly => !r.is_active
      }
      let strategyMatches = strategyKindMatches(strategyView, r.strategy)
      let q = searchText->String.trim->String.toLowerCase
      let searchMatches =
        q === "" ||
        r.rule_name->String.toLowerCase->String.includes(q) ||
        r.rule_description->String.toLowerCase->String.includes(q)
      statusMatches && strategyMatches && searchMatches
    })
  }, (rules, statusView, strategyView, searchText))

  let header =
    <div className="flex flex-col gap-1 px-6 pt-5 pb-3 bg-white flex-shrink-0">
      <div className="flex flex-row justify-between items-baseline gap-2.5">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Rules library"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${visibleRules->Array.length->Int.toString} of ${rules
              ->Array.length
              ->Int.toString} rule${rules->Array.length === 1 ? "" : "s"}`->React.string}
          </span>
        </div>
      </div>
      <span className={`${body.sm.medium} text-nd_gray-500 max-w-3xl`}>
        {"Reconciliation rules that match source rows against target accounts. Lower priority numbers run first."->React.string}
      </span>
    </div>

  let emptyState =
    <div className="px-6 py-12 bg-white">
      <div
        className={`${body.sm.medium} text-nd_gray-400 px-6 py-12 rounded-xl border border-dashed border-nd_gray-200 text-center bg-white`}>
        {rules->Array.length === 0
          ? "No recon rules configured."->React.string
          : "No rules match these filters."->React.string}
      </div>
    </div>

  let tableBody =
    visibleRules->Array.length === 0
      ? emptyState
      : <div className="bg-white w-full overflow-auto">
          <table className="w-full border-separate border-spacing-0">
            <ColumnHeader />
            <tbody>
              {visibleRules
              ->Array.map(rule => <Row key={rule.rule_id} rule accounts transactions />)
              ->React.array}
            </tbody>
          </table>
        </div>

  <div
    className="absolute left-0 min-w-full max-w-full flex flex-col h-[calc(100vh-4rem)] bg-nd_gray-25">
    {header}
    <PageLoaderWrapper screenState>
      <div className="flex flex-col flex-1 min-h-0 overflow-y-auto">
        <KpiStrip rules transactions />
        <StatusTabs statusView setStatusView counts=statusCounts />
        <Toolbar
          strategyView
          setStrategyView
          searchText
          setSearchText
          stratCounts=strategyCounts
          visibleCount={visibleRules->Array.length}
          totalCount={rules->Array.length}
        />
        {tableBody}
      </div>
    </PageLoaderWrapper>
  </div>
}

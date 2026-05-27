@@warning("-45")

open Typography
open ReconEngineTypes
open ReconEngineRulesRevampUtils
open ReconEngineRulesTypes

/* ============================== Shared step chrome ============================== */

let stepNumberCls = "w-7 h-7 rounded-full bg-nd_primary_blue-50 text-nd_primary_blue-600 grid place-items-center flex-shrink-0"

module VersionChip = {
  @react.component
  let make = (~label: string, ~version: string) =>
    <span
      className={`${body.xs.semibold} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono tracking-tight`}>
      {`${label} · ${version}`->React.string}
    </span>
}

module StepCard = {
  @react.component
  let make = (
    ~stepNumber: string,
    ~label: string,
    ~helper: string="",
    ~rightSlot: option<React.element>=?,
    ~children: React.element,
  ) =>
    <div
      className="rounded-xl border border-nd_gray-150 bg-white px-6 py-5 flex flex-col gap-4 w-full">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <div className={stepNumberCls}>
          <span className={`${body.sm.semibold}`}> {stepNumber->React.string} </span>
        </div>
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {`STEP ${stepNumber} · ${label}`->React.string}
        </span>
        <span className="flex-1" />
        {helper === ""
          ? React.null
          : <span className={`${body.xs.medium} text-nd_gray-500`}> {helper->React.string} </span>}
        {switch rightSlot {
        | Some(node) => node
        | None => React.null
        }}
      </div>
      {children}
    </div>
}

module Connector = {
  @react.component
  let make = () =>
    <div className="flex flex-col items-center w-full">
      <div className="w-px h-3 bg-nd_gray-200" />
      <Icon name="nd-arrow-down" size=14 customIconColor="#A1A8B8" />
      <div className="w-px h-1 bg-nd_gray-200" />
    </div>
}

/* ============================== Account block (big) ============================== */

module AccountBlock = {
  @react.component
  let make = (~accounts: array<accountType>, ~accountId: string) => {
    let name = accountName(accounts, accountId)
    let currency = accountCurrency(accounts, accountId)
    let account = accounts->Array.find(a => a.account_id === accountId)
    let (sideLabel, sideCls) = switch account {
    | Some(a) =>
      switch a.account_type {
      | Credit => ("CREDIT", "bg-nd_green-50 text-nd_green-600")
      | Debit => ("DEBIT", "bg-nd_red-50 text-nd_red-600")
      | UnknownAccountTypeVariant => ("—", "bg-nd_gray-50 text-nd_gray-500")
      }
    | None => ("—", "bg-nd_gray-50 text-nd_gray-500")
    }

    <div
      className="rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5 flex flex-row items-center gap-3.5 w-full">
      <div
        className="w-10 h-10 rounded-lg bg-nd_gray-25 border border-nd_gray-150 grid place-items-center flex-shrink-0">
        <Icon name="nd-bank" size=20 customIconColor="#606B85" />
      </div>
      <div className="flex flex-col gap-0.5 min-w-0 flex-1">
        <span className={`${body.md.semibold} text-nd_gray-800 truncate`}>
          {name->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-400 truncate font-mono`}>
          {(accountId === "" ? "—" : accountId)->React.string}
        </span>
      </div>
      <div className="flex flex-col items-end gap-1 flex-shrink-0">
        <span className={`${body.xs.semibold} ${sideCls} rounded-md px-2 py-0.5 tracking-wider`}>
          {sideLabel->React.string}
        </span>
        {currency === ""
          ? React.null
          : <span className={`${body.xs.medium} text-nd_gray-500 tabular-nums`}>
              {currency->React.string}
            </span>}
      </div>
    </div>
  }
}

/* ============================== Operator glyph ============================== */

module OpGlyph = {
  @react.component
  let make = (~op: string) =>
    <div className="inline-flex flex-row items-center gap-2">
      <span
        className={`${body.sm.semibold} font-mono inline-flex items-center justify-center w-7 h-7 rounded-md bg-nd_primary_blue-50 text-nd_primary_blue-600`}>
        {operatorSymbol(op)->React.string}
      </span>
      <span className={`${body.xs.medium} text-nd_gray-500`}> {op->React.string} </span>
    </div>
}

/* ============================== Field cell with pretty + raw path ============================== */

module FieldCell = {
  @react.component
  let make = (~path: string) =>
    <div className="flex flex-col gap-0.5 min-w-0">
      <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
        {displayField(path)->React.string}
      </span>
      <span className={`${body.xs.medium} text-nd_gray-400 truncate font-mono`}>
        {(path === "" ? "—" : path)->React.string}
      </span>
    </div>
}

/* ============================== Step 1 · Source ============================== */

module SourceStep = {
  @react.component
  let make = (~accounts: array<accountType>, ~rule: rulePayload) => {
    let sourceId = rule.strategy->getSourceAccountId
    let trigger = rule.strategy->getTrigger
    let groupingField = rule.strategy->getGroupingField

    let conditions = switch trigger {
    | Some(t) => triggerConditions(t)
    | None => []
    }
    let logicLabel = switch trigger {
    | Some(t) => triggerLogicLabel(t)
    | None => "—"
    }
    let versionLabel = switch trigger {
    | Some(t) => triggerVersionLabel(t)
    | None => "—"
    }
    let logicSentence = switch trigger {
    | Some(t) => triggerLogicSentence(t, conditions->Array.length)
    | None => ""
    }

    <StepCard stepNumber="1" label="SOURCE">
      <AccountBlock accounts accountId=sourceId />
      <div className="flex flex-row items-center gap-2 flex-wrap pt-1">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Filter rows where"->React.string}
        </span>
        <VersionChip label="trigger" version=versionLabel />
        <span
          className={`${body.xs.semibold} text-nd_primary_blue-600 bg-nd_primary_blue-50 rounded-md px-2 py-0.5 font-mono tracking-tight`}>
          {`logic · ${logicLabel}`->React.string}
        </span>
        <span className="flex-1" />
        {logicSentence === ""
          ? React.null
          : <span className={`${body.xs.medium} text-nd_gray-500`}>
              {logicSentence->React.string}
            </span>}
      </div>
      {conditions->Array.length === 0
        ? <div
            className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-3 rounded-lg border border-dashed border-nd_gray-200 text-center`}>
            {"No filter conditions — every row passes through."->React.string}
          </div>
        : <div className="rounded-lg border border-nd_gray-150 bg-white overflow-hidden">
            <div
              className="grid grid-cols-[1fr_auto_1fr_auto] items-center gap-2 px-3.5 py-2 bg-nd_gray-25 border-b border-nd_gray-150">
              <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                {"Field"->React.string}
              </span>
              <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                {"Operator"->React.string}
              </span>
              <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                {"Value"->React.string}
              </span>
              <span
                className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider text-right`}>
                {"Op v."->React.string}
              </span>
            </div>
            {conditions
            ->Array.mapWithIndex((c, idx) =>
              <div
                key={idx->Int.toString}
                className="grid grid-cols-[1fr_auto_1fr_auto] items-center gap-2 px-3.5 py-2.5 border-b border-nd_gray-100 last:border-b-0">
                <FieldCell path=c.field />
                <OpGlyph op=c.operator.value />
                <span
                  className={`${body.sm.medium} text-nd_gray-700 font-mono bg-nd_gray-50 border border-nd_gray-150 rounded-md inline-flex items-center px-2 py-0.5 self-center truncate`}>
                  {(c.value === "" ? "—" : c.value)->React.string}
                </span>
                <span
                  className={`${body.xs.medium} text-nd_gray-400 font-mono text-right truncate`}>
                  {(
                    c.operator.operator_version === "" ? "—" : c.operator.operator_version
                  )->React.string}
                </span>
              </div>
            )
            ->React.array}
          </div>}
      {switch groupingField {
      | Some(field) =>
        <div
          className="rounded-lg border border-nd_primary_blue-100 bg-nd_primary_blue-50/30 px-3.5 py-3 flex flex-col gap-1.5">
          <span className={`${body.xs.semibold} text-nd_primary_blue-600 uppercase tracking-wider`}>
            {"Grouping field"->React.string}
          </span>
          <span className={`${body.sm.semibold} text-nd_gray-800 font-mono`}>
            {field->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-500`}>
            {"Source rows sharing this value will be grouped before matching."->React.string}
          </span>
        </div>
      | None => React.null
      }}
    </StepCard>
  }
}

/* ============================== Step 2 · Search by ============================== */

module SearchStep = {
  @react.component
  let make = (
    ~stepNumber: string,
    ~accounts: array<accountType>,
    ~rule: rulePayload,
    ~targetAccountId: string,
    ~spec: searchSpec,
  ) => {
    let sourceName = accountName(accounts, rule.strategy->getSourceAccountId)
    let targetName = accountName(accounts, targetAccountId)

    <StepCard
      stepNumber
      label="SEARCH BY"
      helper="Find a matching row in target by"
      rightSlot={<VersionChip label="search" version=spec.version />}>
      <div
        className="grid grid-cols-[1fr_auto_1fr] rounded-lg border border-nd_gray-150 bg-white overflow-hidden">
        <div className="px-4 py-3.5 flex flex-col gap-1 min-w-0">
          <span
            className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
            {sourceName->React.string}
          </span>
          <span className={`${body.md.semibold} text-nd_gray-800 truncate`}>
            {displayField(spec.source_field)->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-400 truncate font-mono`}>
            {(spec.source_field === "" ? "—" : spec.source_field)->React.string}
          </span>
        </div>
        <div
          className="grid place-items-center px-4 bg-nd_primary_blue-50 border-l border-r border-nd_gray-150 text-nd_primary_blue-600">
          <Icon name="nd-arrow-right" size=18 customIconColor="#2B6FFF" />
        </div>
        <div className="px-4 py-3.5 flex flex-col gap-1 min-w-0">
          <span
            className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
            {targetName->React.string}
          </span>
          <span className={`${body.md.semibold} text-nd_gray-800 truncate`}>
            {displayField(spec.target_field)->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-400 truncate font-mono`}>
            {(spec.target_field === "" ? "—" : spec.target_field)->React.string}
          </span>
        </div>
      </div>
      <span className={`${body.xs.medium} text-nd_gray-500`}>
        {"We compare these two fields to identify the same record on both sides."->React.string}
      </span>
    </StepCard>
  }
}

/* ============================== Step 3 · Confirm match if ============================== */

module MatchStep = {
  @react.component
  let make = (
    ~stepNumber: string,
    ~accounts: array<accountType>,
    ~rule: rulePayload,
    ~targetAccountId: string,
    ~version: string,
    ~rules: array<matchSpec>,
  ) => {
    let sourceName = accountName(accounts, rule.strategy->getSourceAccountId)
    let targetName = accountName(accounts, targetAccountId)
    let count = rules->Array.length

    <StepCard
      stepNumber
      label="CONFIRM MATCH IF"
      helper="After identifying the row, confirm it matches when"
      rightSlot={<VersionChip label="match" version />}>
      {rules->Array.length === 0
        ? <div
            className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-3 rounded-lg border border-dashed border-nd_gray-200 text-center`}>
            {"No extra checks. By default amount and currency are matched."->React.string}
          </div>
        : <div className="rounded-lg border border-nd_gray-150 bg-white overflow-hidden">
            <div
              className="grid grid-cols-[1fr_auto_1fr] items-center gap-2 px-3.5 py-2 bg-nd_gray-25 border-b border-nd_gray-150">
              <span
                className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
                {`${sourceName} field`->React.string}
              </span>
              <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                {"Operator"->React.string}
              </span>
              <span
                className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider truncate`}>
                {`${targetName} field`->React.string}
              </span>
            </div>
            {rules
            ->Array.mapWithIndex((r, idx) =>
              <div
                key={idx->Int.toString}
                className="grid grid-cols-[1fr_auto_1fr] items-center gap-2 px-3.5 py-2.5 border-b border-nd_gray-100 last:border-b-0">
                <FieldCell path=r.source_field />
                <OpGlyph op=r.operator />
                <FieldCell path=r.target_field />
              </div>
            )
            ->React.array}
          </div>}
      {count === 0
        ? React.null
        : <span className={`${body.xs.medium} text-nd_gray-500`}>
            {`${count->Int.toString} condition${count === 1
                ? ""
                : "s"} — all must be true.`->React.string}
          </span>}
    </StepCard>
  }
}

/* ============================== Step 4 · Target ============================== */

module TargetStep = {
  @react.component
  let make = (~stepNumber: string, ~accounts: array<accountType>, ~spec: targetSpec) => {
    let chip = splitChipLabel(spec)
    <StepCard stepNumber label="TARGET">
      <AccountBlock accounts accountId=spec.account_id />
      {chip === ""
        ? React.null
        : <div className="flex flex-row items-center gap-2 flex-wrap pt-1">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
              {"Allocation"->React.string}
            </span>
            <span
              className={`${body.xs.semibold} text-nd_primary_blue-600 bg-nd_primary_blue-50 rounded-md px-2 py-0.5 tracking-wider tabular-nums font-mono`}>
              {chip->React.string}
            </span>
            <span className={`${body.xs.medium} text-nd_gray-500`}>
              {(
                spec.split_type === Some("percentage")
                  ? "share of source amount"
                  : "fixed amount from source"
              )->React.string}
            </span>
          </div>}
    </StepCard>
  }
}

/* ============================== Right rail metadata ============================== */

module MetaRow = {
  @react.component
  let make = (~label: string, ~children: React.element, ~last: bool=false) =>
    <div className={`flex flex-col gap-1 px-5 py-3.5 ${last ? "" : "border-b border-nd_gray-100"}`}>
      <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
        {label->React.string}
      </span>
      {children}
    </div>
}

module Metadata = {
  @react.component
  let make = (~rule: rulePayload) => {
    let statusLabel = rule.is_active ? "Active" : "Inactive"
    let statusDotCls = rule.is_active ? "bg-nd_green-500" : "bg-nd_gray-300"
    let statusBg = rule.is_active
      ? "bg-nd_green-50 text-nd_green-600"
      : "bg-nd_gray-100 text-nd_gray-500"

    <aside
      className="hidden lg:flex flex-shrink-0 w-[320px] flex-col bg-white border border-nd_gray-150 rounded-xl self-start sticky top-4">
      <MetaRow label="Status">
        <span
          className={`${body.xs.medium} inline-flex flex-row items-center gap-1.5 px-2.5 py-0.5 rounded-full ${statusBg} self-start`}>
          <span className={`w-1.5 h-1.5 rounded-full ${statusDotCls}`} />
          {statusLabel->React.string}
        </span>
      </MetaRow>
      <MetaRow label="Rule ID">
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 truncate font-mono break-all`}
          displayValue={Some(rule.rule_id === "" ? "—" : rule.rule_id)}
        />
      </MetaRow>
      <MetaRow label="Profile ID">
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 truncate font-mono break-all`}
          displayValue={Some(rule.profile_id === "" ? "—" : rule.profile_id)}
        />
      </MetaRow>
      <MetaRow label="Priority">
        <span className={`${body.sm.semibold} text-nd_gray-800 tabular-nums`}>
          {rule.priority->Int.toString->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {"Lower priority numbers run first."->React.string}
        </span>
      </MetaRow>
      <MetaRow label="Strategy">
        <span className={`${body.sm.medium} text-nd_gray-700`}>
          {plainStrategySummary(rule.strategy)->React.string}
        </span>
        <div className="flex flex-row gap-1.5 flex-wrap pt-0.5">
          <span
            className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
            {`recon · ${strategyHigherKind(rule.strategy)}`->React.string}
          </span>
          <span
            className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
            {`sub · ${strategySubKind(rule.strategy)}`->React.string}
          </span>
        </div>
      </MetaRow>
      <MetaRow label="Aging">
        <span className={`${body.sm.medium} text-nd_gray-700`}>
          {agingShort(rule.aging_config)->React.string}
        </span>
        <div className="flex flex-row gap-1.5 flex-wrap pt-0.5">
          <span
            className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
            {`type · ${agingTypeBackend(rule.aging_config)}`->React.string}
          </span>
          {agingThresholdTypeBackend(rule.aging_config) === ""
            ? React.null
            : <span
                className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
                {`threshold · ${agingThresholdTypeBackend(rule.aging_config)}`->React.string}
              </span>}
        </div>
      </MetaRow>
      <MetaRow label="Created">
        <span className={`${body.sm.medium} text-nd_gray-700`}>
          {absoluteDate(rule.created_at)->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-400`}>
          {relativeDate(rule.created_at)->React.string}
        </span>
      </MetaRow>
      <MetaRow label="Last modified" last=true>
        <span className={`${body.sm.medium} text-nd_gray-700`}>
          {absoluteDate(rule.last_modified_at)->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-400`}>
          {relativeDate(rule.last_modified_at)->React.string}
        </span>
      </MetaRow>
    </aside>
  }
}

/* ============================== Hero block ============================== */

module Hero = {
  @react.component
  let make = (~rule: rulePayload, ~accounts: array<accountType>) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let statusDot = rule.is_active ? "bg-nd_green-500" : "bg-nd_gray-300"
    let statusLabel = rule.is_active ? "Active" : "Inactive"
    let statusBg = rule.is_active
      ? "bg-nd_green-50 text-nd_green-600"
      : "bg-nd_gray-100 text-nd_gray-500"

    let sourceName = accountName(accounts, rule.strategy->getSourceAccountId)
    let targetNames =
      rule.strategy->getTargetSpecs->Array.map(s => accountName(accounts, s.account_id))
    let targetLabel = switch targetNames {
    | [] => "—"
    | [t] => t
    | many =>
      let head = many->Array.get(0)->Option.getOr("—")
      `${head} +${(many->Array.length - 1)->Int.toString} more`
    }

    let onViewTxns = (_: ReactEvent.Mouse.t) => {
      mixpanelEvent(~eventName="recon_engine_rule_detail_view_transactions_clicked")
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/transactions?rule_id=${rule.rule_id}`,
        ),
      )
    }

    <div className="flex flex-col gap-4 bg-white border border-nd_gray-150 rounded-xl px-6 py-6">
      <div className="flex flex-row items-center gap-2 flex-wrap">
        <span
          className={`${body.xs.medium} inline-flex flex-row items-center gap-1.5 px-2.5 py-0.5 rounded-full ${statusBg}`}>
          <span className={`w-1.5 h-1.5 rounded-full ${statusDot}`} />
          {statusLabel->React.string}
        </span>
        <span
          className={`${body.xs.semibold} text-nd_gray-600 bg-nd_gray-50 border border-nd_gray-150 rounded-full px-2.5 py-0.5 uppercase tracking-wider`}>
          {`Priority ${rule.priority->Int.toString}`->React.string}
        </span>
        <span
          className={`${body.xs.semibold} text-nd_gray-600 bg-nd_gray-50 border border-nd_gray-150 rounded-full px-2.5 py-0.5`}>
          {agingShort(rule.aging_config)->React.string}
        </span>
        <span className="flex-1" />
        <Button
          text="View transactions"
          buttonType=Secondary
          buttonSize=Small
          leftIcon={CustomIcon(<Icon name="nd-external-link-square" size=14 />)}
          onClick=onViewTxns
        />
      </div>
      <div className="flex flex-col gap-1.5 min-w-0">
        <h1 className={`${heading.xl.semibold} text-nd_gray-800 tracking-tight`}>
          {rule.rule_name->React.string}
        </h1>
        {rule.rule_description === ""
          ? React.null
          : <p className={`${body.md.medium} text-nd_gray-500 max-w-3xl`}>
              {rule.rule_description->React.string}
            </p>}
      </div>
      <div className="flex flex-row items-center gap-3 flex-wrap pt-1">
        <span
          className={`${body.sm.semibold} text-nd_gray-800 bg-nd_gray-25 border border-nd_gray-150 rounded-lg px-3 py-1.5`}>
          {sourceName->React.string}
        </span>
        <Icon name="nd-arrow-right" size=16 customIconColor="#A1A8B8" />
        <span
          className={`${body.sm.semibold} text-nd_gray-800 bg-nd_gray-25 border border-nd_gray-150 rounded-lg px-3 py-1.5`}>
          {targetLabel->React.string}
        </span>
      </div>
      <div className="flex flex-row items-center gap-2 flex-wrap pt-0.5">
        <span className={`${body.sm.medium} text-nd_gray-600`}>
          {plainStrategySummary(rule.strategy)->React.string}
        </span>
        <span
          className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
          {strategyHigherKind(rule.strategy)->React.string}
        </span>
        <span
          className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded-md px-2 py-0.5 font-mono`}>
          {strategySubKind(rule.strategy)->React.string}
        </span>
      </div>
    </div>
  }
}

/* ============================== Flow assembly ============================== */

module Flow = {
  @react.component
  let make = (~rule: rulePayload, ~accounts: array<accountType>) => {
    let expansions = rule.strategy->getTargetExpansions
    let multiTarget = expansions->Array.length > 1

    <div className="flex flex-col items-stretch gap-0 w-full">
      <SourceStep accounts rule />
      <Connector />
      {multiTarget
        ? <div
            className="rounded-xl border border-nd_primary_blue-200 bg-nd_primary_blue-50/40 px-4 py-3 flex flex-row items-center gap-2">
            <Icon name="nd-graph-chart-gantt" size=14 customIconColor="#2B6FFF" />
            <span className={`${body.sm.semibold} text-nd_gray-800`}>
              {`${expansions
                ->Array.length
                ->Int.toString} targets — each runs its own search and match`->React.string}
            </span>
          </div>
        : React.null}
      {expansions
      ->Array.mapWithIndex((ex, idx) => {
        let groupNum = (idx + 1)->Int.toString
        let labelSearch = multiTarget ? `${groupNum}.1` : "2"
        let labelMatch = multiTarget ? `${groupNum}.2` : "3"
        let labelTarget = multiTarget ? `${groupNum}.3` : "4"

        <div key={idx->Int.toString} className="flex flex-col items-stretch gap-0 w-full">
          {multiTarget
            ? <>
                <Connector />
                <div
                  className="rounded-lg border border-nd_primary_blue-200 bg-nd_primary_blue-50/40 px-4 py-2.5 flex flex-row items-center gap-2 flex-wrap">
                  <span
                    className={`${body.xs.semibold} text-nd_primary_blue-600 uppercase tracking-wider`}>
                    {`Target ${groupNum}`->React.string}
                  </span>
                  <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
                    {accountName(accounts, ex.spec.account_id)->React.string}
                  </span>
                  <span className="flex-1" />
                  {splitChipLabel(ex.spec) === ""
                    ? React.null
                    : <span
                        className={`${body.xs.semibold} text-nd_primary_blue-600 bg-white border border-nd_primary_blue-100 rounded-md px-2 py-0.5 tracking-wider tabular-nums font-mono`}>
                        {splitChipLabel(ex.spec)->React.string}
                      </span>}
                </div>
              </>
            : React.null}
          {switch ex.search_identifier {
          | Some(spec) =>
            <>
              <Connector />
              <SearchStep
                stepNumber=labelSearch accounts rule targetAccountId=ex.spec.account_id spec
              />
            </>
          | None => React.null
          }}
          <Connector />
          <MatchStep
            stepNumber=labelMatch
            accounts
            rule
            targetAccountId=ex.spec.account_id
            version=ex.match_version
            rules=ex.match_rules
          />
          <Connector />
          <TargetStep stepNumber=labelTarget accounts spec=ex.spec />
        </div>
      })
      ->React.array}
    </div>
  }
}

/* ============================== Main detail page ============================== */

@react.component
let make = (~id: string) => {
  open APIUtils
  open LogicUtils
  open ReconEngineRulesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ruleOpt, setRuleOpt) = React.useState(_ => None)
  let (accounts, setAccounts) = React.useState(_ => [])

  let fetchAll = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RECON_RULES,
        ~id=Some(id),
      )
      let ruleP = async () => {
        try {
          let res = await fetchDetails(url)
          setRuleOpt(_ => Some(res->getDictFromJsonObject->ruleItemToObjMapper))
        } catch {
        | _ => setRuleOpt(_ => None)
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
      let _ = await Promise.all([ruleP(), accountsP()])
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load rule"))
    }
  }

  React.useEffect0(() => {
    fetchAll()->ignore
    None
  })

  <div className="flex flex-col gap-4 px-6 py-5 bg-nd_gray-25 min-h-[calc(100vh-4rem)]">
    <BreadCrumbNavigation
      path=[{title: "Rules Library", link: `/v1/recon-engine/rules`}]
      currentPageTitle={switch ruleOpt {
      | Some(r) => r.rule_name === "" ? id : r.rule_name
      | None => id
      }}
    />
    <PageLoaderWrapper screenState>
      {switch ruleOpt {
      | Some(rule) =>
        <div className="flex flex-row gap-5 items-start">
          <div className="flex-1 min-w-0 flex flex-col gap-3">
            <Hero rule accounts />
            <Flow rule accounts />
          </div>
          <Metadata rule />
        </div>
      | None =>
        <div className="bg-white rounded-xl border border-nd_gray-150 px-6 py-12 text-center">
          <p className={`${body.lg.semibold} text-nd_gray-600`}>
            {"Rule not found"->React.string}
          </p>
          <p className={`${body.sm.medium} text-nd_gray-400 mt-2`}>
            {`No rule with ID "${id}" exists.`->React.string}
          </p>
        </div>
      }}
    </PageLoaderWrapper>
  </div>
}

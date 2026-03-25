open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

// Visual ASCII diagram for each strategy type
module StrategyDiagram = {
  @react.component
  let make = (~strategyType: string) => {
    let (sourceLabel, targetLabel, description) = switch strategyType {
    | "single_single" => (
        "1 Entry",
        "1 Entry",
        "Each source entry matches exactly one target entry. Best for: payment-to-settlement matching where each payment has one bank confirmation.",
      )
    | "single_many" => (
        "1 Entry",
        "N Entries",
        "One source entry matches multiple target entries. Best for: a single payment that appears as multiple partial settlements in the bank.",
      )
    | "many_single" => (
        "N Entries",
        "1 Entry",
        "Multiple source entries match one target entry. Best for: multiple small payments that are grouped into one bank deposit.",
      )
    | "many_many" => (
        "N Entries",
        "N Entries",
        "Multiple source entries match multiple target entries by a grouping field. Best for: daily batch settlements where multiple payments match multiple bank lines for the same date.",
      )
    | _ => ("", "", "")
    }

    <div className="bg-white rounded-lg border border-blue-200 p-4 mt-3">
      // Visual diagram
      <div className="flex items-center justify-center gap-4 mb-3">
        <div className="flex flex-col items-center">
          <div className="text-[10px] font-semibold text-gray-400 uppercase mb-1">
            {"Source"->React.string}
          </div>
          <div
            className="bg-blue-100 border-2 border-blue-300 rounded-lg px-4 py-2 text-sm font-semibold text-blue-800">
            {sourceLabel->React.string}
          </div>
        </div>
        // Arrow with "matches" label
        <div className="flex flex-col items-center">
          <div className="text-[9px] text-gray-400 font-medium mb-0.5">
            {"matches"->React.string}
          </div>
          <div className="flex items-center">
            <div className="w-8 h-0.5 bg-gray-300" />
            <div className="text-gray-400"> {`\u{25B6}`->React.string} </div>
            <div className="w-8 h-0.5 bg-gray-300" />
          </div>
        </div>
        <div className="flex flex-col items-center">
          <div className="text-[10px] font-semibold text-gray-400 uppercase mb-1">
            {"Target"->React.string}
          </div>
          <div
            className="bg-green-100 border-2 border-green-300 rounded-lg px-4 py-2 text-sm font-semibold text-green-800">
            {targetLabel->React.string}
          </div>
        </div>
      </div>
      // Description
      <p className="text-xs text-gray-600 leading-relaxed text-center">
        {description->React.string}
      </p>
    </div>
  }
}

module HelpTooltip = {
  @react.component
  let make = (~text: string) => {
    let (show, setShow) = React.useState(_ => false)
    <div className="relative inline-block ml-1">
      <span
        className="text-gray-400 hover:text-blue-500 cursor-help text-xs"
        onMouseEnter={_ => setShow(_ => true)}
        onMouseLeave={_ => setShow(_ => false)}>
        {`\u{24D8}`->React.string}
      </span>
      <RenderIf condition={show}>
        <div
          className="absolute z-50 bottom-full left-1/2 -translate-x-1/2 mb-2 w-64 p-3 bg-gray-900 text-white text-xs rounded-lg shadow-xl leading-relaxed">
          {text->React.string}
          <div
            className="absolute top-full left-1/2 -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-l-transparent border-r-transparent border-t-gray-900"
          />
        </div>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~state: selfServeState, ~onNext, ~onBack) => {
  let createRule = ReconEngineSelfServeHooks.useCreateReconRule()

  let (ruleName, setRuleName) = React.useState(_ => "")
  let (ruleDescription, setRuleDescription) = React.useState(_ => "")
  let (priority, setPriority) = React.useState(_ => 1)
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  // Strategy type
  let (strategyType, setStrategyType) = React.useState(_ => "one_to_one")
  let (oneToOneType, setOneToOneType) = React.useState(_ => "single_single")

  // Source/Target accounts
  let (sourceAccountId, setSourceAccountId) = React.useState(_ => "")
  let (targetAccountId, setTargetAccountId) = React.useState(_ => "")

  // Trigger
  let (triggerField, setTriggerField) = React.useState(_ => "currency")
  let (triggerOperator, setTriggerOperator) = React.useState(_ => "equals")
  let (triggerValue, setTriggerValue) = React.useState(_ => "")

  // Search identifier
  let (searchSourceField, setSearchSourceField) = React.useState(_ => "order_id")
  let (searchTargetField, setSearchTargetField) = React.useState(_ => "order_id")

  // Match rules
  let (matchRules, setMatchRules) = React.useState(_ => [
    {source_field: "amount", target_field: "amount", operator: "equals"},
  ])

  // Grouping field (for many-source variants)
  let (groupingField, setGroupingField) = React.useState(_ => "effective_at")

  // Aging config
  let (agingType, setAgingType) = React.useState(_ => "no_aging")
  let (agingDays, setAgingDays) = React.useState(_ => 7)

  // Collapsible sections
  let (showAdvanced, setShowAdvanced) = React.useState(_ => false)

  let availableFields = state->getAvailableEntryFields

  let needsGroupingField = oneToOneType === "many_single" || oneToOneType === "many_many"

  let addMatchRule = () => {
    let newRule: matchRuleCreateType = {
      source_field: "amount",
      target_field: "amount",
      operator: "equals",
    }
    setMatchRules(prev => Array.concat(prev, [newRule]))
  }

  let updateMatchRule = (index, rule) => {
    setMatchRules(prev =>
      prev->Array.mapWithIndex((r, i) =>
        if i === index {
          rule
        } else {
          r
        }
      )
    )
  }

  let removeMatchRule = index => {
    setMatchRules(prev => prev->Array.filterWithIndex((_, i) => i !== index))
  }

  let handleSubmit = async () => {
    setIsSubmitting(_ => true)

    let trigger: triggerCreateType = {
      field: triggerField,
      operator: switch triggerOperator {
      | "not_equals" => NotEquals
      | _ => Equals
      },
      value: triggerValue,
    }

    let searchIdentifier: searchIdentifierCreateType = {
      source_field: searchSourceField,
      target_field: searchTargetField,
    }

    let strategy = if strategyType === "one_to_one" {
      let variant = switch oneToOneType {
      | "single_many" =>
        SingleManyCreate({
          search_identifier: searchIdentifier,
          match_rules: matchRules,
          source_account: {account_id: sourceAccountId, trigger},
          target_account: {account_id: targetAccountId},
        })
      | "many_single" =>
        ManySingleCreate({
          search_identifier: searchIdentifier,
          match_rules: matchRules,
          source_account: {
            account_id: sourceAccountId,
            trigger,
            grouping_field: groupingField,
          },
          target_account: {account_id: targetAccountId},
        })
      | "many_many" =>
        ManyManyCreate({
          search_identifier: searchIdentifier,
          match_rules: matchRules,
          source_account: {
            account_id: sourceAccountId,
            trigger,
            grouping_field: groupingField,
          },
          target_account: {account_id: targetAccountId},
        })
      | _ =>
        SingleSingleCreate({
          search_identifier: searchIdentifier,
          match_rules: matchRules,
          source_account: {account_id: sourceAccountId, trigger},
          target_account: {account_id: targetAccountId, tolerance_config: None},
        })
      }
      OneToOneCreate(variant)
    } else {
      OneToOneCreate(
        SingleSingleCreate({
          search_identifier: searchIdentifier,
          match_rules: matchRules,
          source_account: {account_id: sourceAccountId, trigger},
          target_account: {account_id: targetAccountId, tolerance_config: None},
        }),
      )
    }

    let agingConfig = switch agingType {
    | "with_threshold" => WithThresholdCreate({weekdays: agingDays})
    | _ => NoAgingCreate
    }

    let req: reconRuleCreateRequest = {
      rule_name: ruleName,
      rule_description: ruleDescription,
      priority,
      strategy,
      aging_config: agingConfig,
    }

    let result = await createRule(req)
    switch result {
    | Some(_ruleId) => onNext()
    | None => ()
    }
    setIsSubmitting(_ => false)
  }

  <div className="flex flex-col gap-6 max-w-2xl">
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-1">
        {"Define Recon Rules"->React.string}
      </h2>
      <p className="text-sm text-gray-500">
        {"Set up the matching logic that defines how transactions from different accounts get reconciled."->React.string}
      </p>
    </div>
    // How it works explainer
    <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
      <div className="flex items-start gap-3">
        <span className="text-lg"> {`\u{1F4A1}`->React.string} </span>
        <div className="text-xs text-gray-600 leading-relaxed">
          <p className="font-semibold text-gray-700 mb-1">
            {"How recon rules work"->React.string}
          </p>
          <p>
            {"A rule connects two accounts and defines: (1) a "->React.string}
            <span className="font-semibold"> {"trigger"->React.string} </span>
            {" — when the rule fires, (2) a "->React.string}
            <span className="font-semibold"> {"search identifier"->React.string} </span>
            {" — how to find matching entries, and (3) "->React.string}
            <span className="font-semibold"> {"match rules"->React.string} </span>
            {" — what fields must be equal for a match."->React.string}
          </p>
        </div>
      </div>
    </div>
    <div className="border border-gray-200 rounded-lg overflow-hidden">
      // Section 1: Basic Info
      <div className="p-5 bg-white">
        <h4 className="text-sm font-semibold text-gray-800 mb-4 flex items-center gap-2">
          <span
            className="w-5 h-5 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-[10px] font-bold">
            {"1"->React.string}
          </span>
          {"Basic Information"->React.string}
        </h4>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Rule Name"->React.string}
            </label>
            <input
              type_="text"
              value={ruleName}
              onChange={e => setRuleName(_ => ReactEvent.Form.target(e)["value"])}
              placeholder={`e.g., ${(state.accounts->Array.get(0)->Option.map(a => a.account_name)->Option.getOr("Source"))} <-> ${(state.accounts->Array.get(1)->Option.map(a => a.account_name)->Option.getOr("Target"))}`}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Priority"->React.string}
              <HelpTooltip text="Lower number = higher priority. Rules are evaluated in priority order." />
            </label>
            <input
              type_="number"
              value={priority->Int.toString}
              onChange={e => {
                let v = ReactEvent.Form.target(e)["value"]
                setPriority(_ => v->Int.fromString->Option.getOr(1))
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
        <div className="mt-3">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {"Description"->React.string}
          </label>
          <input
            type_="text"
            value={ruleDescription}
            onChange={e => setRuleDescription(_ => ReactEvent.Form.target(e)["value"])}
            placeholder="e.g., Reconciliation between FIUU and Bank"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>
      // Section 2: Strategy & Accounts
      <div className="p-5 bg-white border-t border-gray-100">
        <h4 className="text-sm font-semibold text-gray-800 mb-4 flex items-center gap-2">
          <span
            className="w-5 h-5 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-[10px] font-bold">
            {"2"->React.string}
          </span>
          {"Strategy & Accounts"->React.string}
        </h4>
        // Strategy type cards
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div
            className={`p-4 border-2 rounded-lg cursor-pointer transition-all ${strategyType === "one_to_one"
                ? "border-blue-400 bg-blue-50 shadow-sm"
                : "border-gray-200 hover:border-gray-300"}`}
            onClick={_ => setStrategyType(_ => "one_to_one")}>
            <p className="text-sm font-semibold text-gray-900">
              {"One-to-One"->React.string}
            </p>
            <p className="text-xs text-gray-500 mt-0.5">
              {"Match entries between two accounts"->React.string}
            </p>
          </div>
          <div
            className={`p-4 border-2 rounded-lg cursor-pointer transition-all ${strategyType === "one_to_many"
                ? "border-blue-400 bg-blue-50 shadow-sm"
                : "border-gray-200 hover:border-gray-300"}`}
            onClick={_ => setStrategyType(_ => "one_to_many")}>
            <p className="text-sm font-semibold text-gray-900">
              {"One-to-Many"->React.string}
            </p>
            <p className="text-xs text-gray-500 mt-0.5">
              {"Split one entry across multiple targets"->React.string}
            </p>
          </div>
        </div>
        // OneToOne sub-type selection with visual diagrams
        <RenderIf condition={strategyType === "one_to_one"}>
          <div className="mb-4">
            <label className="block text-xs font-semibold text-gray-600 mb-2 uppercase tracking-wide">
              {"Matching Pattern"->React.string}
              <HelpTooltip text="Defines how many source entries match how many target entries. This depends on your data — e.g., if your bank groups multiple payments into one settlement, use N:1." />
            </label>
            <div className="grid grid-cols-4 gap-2">
              {[
                ("single_single", "1:1"),
                ("single_many", "1:N"),
                ("many_single", "N:1"),
                ("many_many", "N:N"),
              ]
              ->Array.map(((value, badge)) =>
                <button
                  key={value}
                  type_="button"
                  className={`p-3 border-2 rounded-lg transition-all text-center ${oneToOneType === value
                      ? "border-blue-400 bg-blue-50 shadow-sm"
                      : "border-gray-200 hover:border-gray-300"}`}
                  onClick={_ => setOneToOneType(_ => value)}>
                  <span className="text-lg font-bold font-mono text-gray-800 block">
                    {badge->React.string}
                  </span>
                  <span className="text-[10px] text-gray-500 block mt-0.5">
                    {value->LogicUtils.snakeToTitle->React.string}
                  </span>
                </button>
              )
              ->React.array}
            </div>
            // Visual diagram for selected type
            <StrategyDiagram strategyType={oneToOneType} />
          </div>
        </RenderIf>
        // Account selection with visual connector
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1">
              {"Source Account"->React.string}
              <HelpTooltip text="The account whose entries trigger the reconciliation process. New entries in this account will be matched against the target." />
            </label>
            <select
              value={sourceAccountId}
              onChange={e => setSourceAccountId(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-blue-50">
              <option value=""> {"Select source..."->React.string} </option>
              {state.accounts
              ->Array.map(acc =>
                <option key={acc.account_id} value={acc.account_id}>
                  {`${acc.account_name} (${acc.account_type})`->React.string}
                </option>
              )
              ->React.array}
            </select>
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-600 mb-1">
              {"Target Account"->React.string}
              <HelpTooltip text="The account to search for matching entries. When a source entry arrives, the system looks here for its counterpart." />
            </label>
            <select
              value={targetAccountId}
              onChange={e => setTargetAccountId(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-green-50">
              <option value=""> {"Select target..."->React.string} </option>
              {state.accounts
              ->Array.filter(acc => acc.account_id !== sourceAccountId)
              ->Array.map(acc =>
                <option key={acc.account_id} value={acc.account_id}>
                  {`${acc.account_name} (${acc.account_type})`->React.string}
                </option>
              )
              ->React.array}
            </select>
          </div>
        </div>
      </div>
      // Section 3: Trigger
      <div className="p-5 bg-white border-t border-gray-100">
        <h4 className="text-sm font-semibold text-gray-800 mb-1 flex items-center gap-2">
          <span
            className="w-5 h-5 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-[10px] font-bold">
            {"3"->React.string}
          </span>
          {"Trigger Condition"->React.string}
          <HelpTooltip text="Defines when this rule activates. Only entries matching this condition will be processed by the rule. Example: currency equals MYR — only MYR entries trigger this rule." />
        </h4>
        <p className="text-xs text-gray-500 mb-3 ml-7">
          {"When a source entry matches this condition, the rule will attempt to find a match."->React.string}
        </p>
        <div className="flex gap-3 items-end ml-7">
          <div className="flex-1">
            <label className="block text-xs font-medium text-gray-600 mb-1">
              {"Field"->React.string}
            </label>
            <select
              value={triggerField}
              onChange={e => setTriggerField(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
              {availableFields
              ->Array.map(f =>
                <option key={f} value={f}> {f->React.string} </option>
              )
              ->React.array}
            </select>
          </div>
          <div className="w-28">
            <select
              value={triggerOperator}
              onChange={e => setTriggerOperator(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-2 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 text-center font-medium">
              <option value="equals"> {"="->React.string} </option>
              <option value="not_equals"> {`\u{2260}`->React.string} </option>
            </select>
          </div>
          <div className="flex-1">
            <label className="block text-xs font-medium text-gray-600 mb-1">
              {"Value"->React.string}
            </label>
            <input
              type_="text"
              value={triggerValue}
              onChange={e => setTriggerValue(_ => ReactEvent.Form.target(e)["value"])}
              placeholder="e.g., MYR, USD"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
          </div>
        </div>
      </div>
      // Section 4: Search & Match
      <div className="p-5 bg-white border-t border-gray-100">
        <h4 className="text-sm font-semibold text-gray-800 mb-1 flex items-center gap-2">
          <span
            className="w-5 h-5 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-[10px] font-bold">
            {"4"->React.string}
          </span>
          {"Search & Match"->React.string}
        </h4>
        <p className="text-xs text-gray-500 mb-4 ml-7">
          {"Define how to find and verify matching entries between source and target."->React.string}
        </p>
        // Search identifier
        <div className="ml-7 mb-4">
          <label className="block text-xs font-semibold text-gray-600 mb-2">
            {"Search Identifier"->React.string}
            <HelpTooltip text="The field used to FIND potential matches. The system looks for target entries where this field matches the source entry's value. Usually order_id or a unique reference." />
          </label>
          <div className="grid grid-cols-2 gap-3">
            <div className="relative">
              <span className="absolute top-2 left-3 text-[10px] text-blue-500 font-semibold">
                {"SOURCE"->React.string}
              </span>
              <select
                value={searchSourceField}
                onChange={e => setSearchSourceField(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 pt-6 pb-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                {availableFields
                ->Array.map(f =>
                  <option key={f} value={f}> {f->React.string} </option>
                )
                ->React.array}
              </select>
            </div>
            <div className="relative">
              <span className="absolute top-2 left-3 text-[10px] text-green-500 font-semibold">
                {"TARGET"->React.string}
              </span>
              <select
                value={searchTargetField}
                onChange={e => setSearchTargetField(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 pt-6 pb-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                {availableFields
                ->Array.map(f =>
                  <option key={f} value={f}> {f->React.string} </option>
                )
                ->React.array}
              </select>
            </div>
          </div>
        </div>
        // Grouping field
        <RenderIf condition={needsGroupingField}>
          <div className="ml-7 mb-4">
            <label className="block text-xs font-semibold text-gray-600 mb-1">
              {"Grouping Field"->React.string}
              <HelpTooltip text="For N:1 or N:N patterns, multiple source entries are grouped by this field before matching. Typically effective_at (date) to group by day." />
            </label>
            <select
              value={groupingField}
              onChange={e => setGroupingField(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
              {availableFields
              ->Array.map(f =>
                <option key={f} value={f}> {f->React.string} </option>
              )
              ->React.array}
            </select>
          </div>
        </RenderIf>
        // Match rules
        <div className="ml-7">
          <div className="flex items-center justify-between mb-2">
            <label className="text-xs font-semibold text-gray-600">
              {"Match Rules"->React.string}
              <HelpTooltip text="After finding a potential match via search identifier, these rules VERIFY the match. All rules must pass. Typically you match on amount and/or date." />
            </label>
            <button
              type_="button"
              onClick={_ => addMatchRule()}
              className="text-xs text-blue-600 hover:text-blue-700 font-semibold">
              {"+ Add Rule"->React.string}
            </button>
          </div>
          <div className="flex flex-col gap-2">
            {matchRules
            ->Array.mapWithIndex((rule, index) =>
              <div
                key={index->Int.toString}
                className="flex items-center gap-2 p-2.5 border border-gray-200 rounded-lg bg-gray-50">
                <div className="relative flex-1">
                  <span
                    className="absolute top-1 left-2 text-[9px] text-blue-500 font-semibold">
                    {"SRC"->React.string}
                  </span>
                  <select
                    value={rule.source_field}
                    onChange={e => {
                      let v = ReactEvent.Form.target(e)["value"]
                      updateMatchRule(index, {...rule, source_field: v})
                    }}
                    className="w-full px-2 pt-4 pb-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 bg-white">
                    {availableFields
                    ->Array.map(f =>
                      <option key={f} value={f}> {f->React.string} </option>
                    )
                    ->React.array}
                  </select>
                </div>
                <span
                  className="text-xs font-bold text-gray-400 bg-white px-2 py-1 rounded border border-gray-200">
                  {"="->React.string}
                </span>
                <div className="relative flex-1">
                  <span
                    className="absolute top-1 left-2 text-[9px] text-green-500 font-semibold">
                    {"TGT"->React.string}
                  </span>
                  <select
                    value={rule.target_field}
                    onChange={e => {
                      let v = ReactEvent.Form.target(e)["value"]
                      updateMatchRule(index, {...rule, target_field: v})
                    }}
                    className="w-full px-2 pt-4 pb-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 bg-white">
                    {availableFields
                    ->Array.map(f =>
                      <option key={f} value={f}> {f->React.string} </option>
                    )
                    ->React.array}
                  </select>
                </div>
                <RenderIf condition={matchRules->Array.length > 1}>
                  <button
                    type_="button"
                    onClick={_ => removeMatchRule(index)}
                    className="p-1 text-gray-400 hover:text-red-500 transition-colors text-lg">
                    {`\u{00D7}`->React.string}
                  </button>
                </RenderIf>
              </div>
            )
            ->React.array}
          </div>
        </div>
      </div>
      // Section 5: Advanced (collapsible)
      <div className="border-t border-gray-100">
        <button
          type_="button"
          className="w-full p-4 flex items-center justify-between text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors"
          onClick={_ => setShowAdvanced(prev => !prev)}>
          <span className="flex items-center gap-2">
            <span
              className="w-5 h-5 rounded-full bg-gray-100 text-gray-500 flex items-center justify-center text-[10px] font-bold">
              {"5"->React.string}
            </span>
            {"Advanced Settings"->React.string}
          </span>
          <span className="text-gray-400">
            {(showAdvanced ? `\u{25B2}` : `\u{25BC}`)->React.string}
          </span>
        </button>
        <RenderIf condition={showAdvanced}>
          <div className="px-5 pb-5">
            <div className="ml-7">
              <label className="block text-xs font-semibold text-gray-600 mb-2">
                {"Aging Configuration"->React.string}
                <HelpTooltip text="How long to wait for a match before marking an entry as aged/unmatched. 'No Aging' means entries wait indefinitely." />
              </label>
              <div className="flex gap-3 items-center">
                <select
                  value={agingType}
                  onChange={e => setAgingType(_ => ReactEvent.Form.target(e)["value"])}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                  <option value="no_aging"> {"No Aging (wait indefinitely)"->React.string} </option>
                  <option value="with_threshold">
                    {"Age after threshold"->React.string}
                  </option>
                </select>
                <RenderIf condition={agingType === "with_threshold"}>
                  <div className="flex items-center gap-2">
                    <input
                      type_="number"
                      value={agingDays->Int.toString}
                      onChange={e => {
                        let v = ReactEvent.Form.target(e)["value"]
                        setAgingDays(_ => v->Int.fromString->Option.getOr(7))
                      }}
                      className="w-20 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 text-center"
                    />
                    <span className="text-sm text-gray-500"> {"weekdays"->React.string} </span>
                  </div>
                </RenderIf>
              </div>
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
    // Submit
    <button
      type_="button"
      disabled={ruleName->String.trim->String.length === 0 ||
        sourceAccountId === "" ||
        targetAccountId === "" ||
        triggerValue->String.length === 0 ||
        isSubmitting}
      onClick={_ => handleSubmit()->ignore}
      className="w-full px-4 py-3 bg-blue-600 text-white rounded-lg text-sm font-semibold hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors shadow-sm">
      {(isSubmitting ? "Creating Rule..." : "Create Rule & Complete Setup")->React.string}
    </button>
    // Navigation
    <div className="flex justify-start">
      <button
        type_="button"
        onClick={_ => onBack()}
        className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
        {`\u{2190} Back`->React.string}
      </button>
    </div>
  </div>
}

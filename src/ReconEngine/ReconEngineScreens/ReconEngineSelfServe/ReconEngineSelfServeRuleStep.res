open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

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
      // OneToMany - placeholder, requires more complex UI
      // For now, creating a basic OneToOne as fallback
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
        {"Set up matching rules that define how transactions from different accounts are reconciled together."->React.string}
      </p>
    </div>
    <div className="border border-gray-200 rounded-lg p-5 bg-gray-50">
      <div className="flex flex-col gap-5">
        // Basic info
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
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {"Description"->React.string}
          </label>
          <input
            type_="text"
            value={ruleDescription}
            onChange={e => setRuleDescription(_ => ReactEvent.Form.target(e)["value"])}
            placeholder="Describe what this rule reconciles"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        // Strategy Type Selection
        <div className="border-t border-gray-200 pt-4">
          <h4 className="text-sm font-semibold text-gray-700 mb-3">
            {"Strategy Type"->React.string}
          </h4>
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div
              className={`p-4 border rounded-lg cursor-pointer transition-colors ${strategyType === "one_to_one"
                  ? "border-blue-300 bg-blue-50"
                  : "border-gray-200 hover:border-gray-300"}`}
              onClick={_ => setStrategyType(_ => "one_to_one")}>
              <p className="text-sm font-medium text-gray-900">
                {"One-to-One"->React.string}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                {"Match entries between two accounts"->React.string}
              </p>
            </div>
            <div
              className={`p-4 border rounded-lg cursor-pointer transition-colors ${strategyType === "one_to_many"
                  ? "border-blue-300 bg-blue-50"
                  : "border-gray-200 hover:border-gray-300"}`}
              onClick={_ => setStrategyType(_ => "one_to_many")}>
              <p className="text-sm font-medium text-gray-900">
                {"One-to-Many"->React.string}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                {"Split one entry across multiple accounts"->React.string}
              </p>
            </div>
          </div>
          // OneToOne sub-types with visual diagrams
          <RenderIf condition={strategyType === "one_to_one"}>
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-2">
                {"Transaction Matching Pattern"->React.string}
              </label>
              <div className="grid grid-cols-2 gap-2">
                {[
                  ("single_single", "1:1", "One source entry matches one target entry"),
                  ("single_many", "1:N", "One source entry matches multiple target entries"),
                  ("many_single", "N:1", "Multiple source entries match one target entry"),
                  ("many_many", "N:N", "Multiple source entries match multiple target entries"),
                ]
                ->Array.map(((value, badge, desc)) =>
                  <div
                    key={value}
                    className={`p-3 border rounded-lg cursor-pointer transition-colors ${oneToOneType === value
                        ? "border-blue-300 bg-blue-50"
                        : "border-gray-200 hover:border-gray-300"}`}
                    onClick={_ => setOneToOneType(_ => value)}>
                    <div className="flex items-center gap-2 mb-1">
                      <span
                        className="text-xs px-1.5 py-0.5 rounded bg-gray-200 font-mono font-semibold text-gray-700">
                        {badge->React.string}
                      </span>
                      <span className="text-xs font-medium text-gray-700">
                        {value->LogicUtils.snakeToTitle->React.string}
                      </span>
                    </div>
                    <p className="text-[11px] text-gray-500"> {desc->React.string} </p>
                  </div>
                )
                ->React.array}
              </div>
            </div>
          </RenderIf>
        </div>
        // Source & Target Account Selection
        <div className="border-t border-gray-200 pt-4">
          <h4 className="text-sm font-semibold text-gray-700 mb-3">
            {"Accounts"->React.string}
          </h4>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"Source Account"->React.string}
              </label>
              <select
                value={sourceAccountId}
                onChange={e => setSourceAccountId(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
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
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"Target Account"->React.string}
              </label>
              <select
                value={targetAccountId}
                onChange={e => setTargetAccountId(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
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
        // Trigger
        <div className="border-t border-gray-200 pt-4">
          <h4 className="text-sm font-semibold text-gray-700 mb-1">
            {"Trigger Condition"->React.string}
          </h4>
          <p className="text-xs text-gray-500 mb-3">
            {"When should this rule activate? Define a condition on source entries."->React.string}
          </p>
          <div className="flex gap-3 items-end">
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
            <div className="w-32">
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"Operator"->React.string}
              </label>
              <select
                value={triggerOperator}
                onChange={e => setTriggerOperator(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                <option value="equals"> {"Equals"->React.string} </option>
                <option value="not_equals"> {"Not Equals"->React.string} </option>
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
                placeholder="e.g., MYR"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>
        // Search Identifier
        <div className="border-t border-gray-200 pt-4">
          <h4 className="text-sm font-semibold text-gray-700 mb-1">
            {"Search Identifier"->React.string}
          </h4>
          <p className="text-xs text-gray-500 mb-3">
            {"Which field to use to find matching entries between source and target."->React.string}
          </p>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"Source Field"->React.string}
              </label>
              <select
                value={searchSourceField}
                onChange={e => setSearchSourceField(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                {availableFields
                ->Array.map(f =>
                  <option key={f} value={f}> {f->React.string} </option>
                )
                ->React.array}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"Target Field"->React.string}
              </label>
              <select
                value={searchTargetField}
                onChange={e => setSearchTargetField(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                {availableFields
                ->Array.map(f =>
                  <option key={f} value={f}> {f->React.string} </option>
                )
                ->React.array}
              </select>
            </div>
          </div>
        </div>
        // Grouping field (for many variants)
        <RenderIf condition={needsGroupingField}>
          <div className="border-t border-gray-200 pt-4">
            <h4 className="text-sm font-semibold text-gray-700 mb-1">
              {"Grouping Field"->React.string}
            </h4>
            <p className="text-xs text-gray-500 mb-3">
              {"Group multiple source entries by this field before matching."->React.string}
            </p>
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
        // Match Rules
        <div className="border-t border-gray-200 pt-4">
          <div className="flex items-center justify-between mb-3">
            <div>
              <h4 className="text-sm font-semibold text-gray-700">
                {"Match Rules"->React.string}
              </h4>
              <p className="text-xs text-gray-500">
                {"Define which fields must match between source and target entries."->React.string}
              </p>
            </div>
            <button
              type_="button"
              onClick={_ => addMatchRule()}
              className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">
              <span> {"+"->React.string} </span>
              {"Add Rule"->React.string}
            </button>
          </div>
          <div className="flex flex-col gap-2">
            {matchRules
            ->Array.mapWithIndex((rule, index) =>
              <div
                key={index->Int.toString}
                className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg bg-white">
                <div className="flex-1">
                  <select
                    value={rule.source_field}
                    onChange={e => {
                      let v = ReactEvent.Form.target(e)["value"]
                      updateMatchRule(index, {...rule, source_field: v})
                    }}
                    className="w-full px-2 py-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                    {availableFields
                    ->Array.map(f =>
                      <option key={f} value={f}> {f->React.string} </option>
                    )
                    ->React.array}
                  </select>
                </div>
                <span className="text-xs text-gray-400 font-medium"> {"equals"->React.string} </span>
                <div className="flex-1">
                  <select
                    value={rule.target_field}
                    onChange={e => {
                      let v = ReactEvent.Form.target(e)["value"]
                      updateMatchRule(index, {...rule, target_field: v})
                    }}
                    className="w-full px-2 py-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
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
                    className="p-1 text-gray-400 hover:text-red-500 transition-colors">
                    <span> {`\u{00D7}`->React.string} </span>
                  </button>
                </RenderIf>
              </div>
            )
            ->React.array}
          </div>
        </div>
        // Aging Config
        <div className="border-t border-gray-200 pt-4">
          <h4 className="text-sm font-semibold text-gray-700 mb-3">
            {"Aging Configuration"->React.string}
          </h4>
          <div className="flex gap-3 items-end">
            <div className="flex-1">
              <select
                value={agingType}
                onChange={e => setAgingType(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                <option value="no_aging"> {"No Aging"->React.string} </option>
                <option value="with_threshold">
                  {"With Threshold (Week Days)"->React.string}
                </option>
              </select>
            </div>
            <RenderIf condition={agingType === "with_threshold"}>
              <div className="w-32">
                <input
                  type_="number"
                  value={agingDays->Int.toString}
                  onChange={e => {
                    let v = ReactEvent.Form.target(e)["value"]
                    setAgingDays(_ => v->Int.fromString->Option.getOr(7))
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              <span className="text-sm text-gray-500 pb-2"> {"days"->React.string} </span>
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
          className="w-full px-4 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
          {(isSubmitting ? "Creating Rule..." : "Create Rule & Complete Setup")->React.string}
        </button>
      </div>
    </div>
    // Navigation
    <div className="flex justify-start pt-2">
      <button
        type_="button"
        onClick={_ => onBack()}
        className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
        {`\u{2190} Back`->React.string}
      </button>
    </div>
  </div>
}

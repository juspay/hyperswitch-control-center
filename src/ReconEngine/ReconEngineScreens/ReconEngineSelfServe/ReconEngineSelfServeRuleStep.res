open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

let defaultRuleForm: ruleFormState = {
  ruleName: "",
  ruleDescription: "",
  priority: 1,
  oneToOneSubtype: SingleSingle,
  sourceAccountId: "",
  targetAccountId: "",
  triggerField: "currency",
  triggerOperator: "equals",
  triggerValue: "",
  searchSourceField: "effective_at",
  searchTargetField: "effective_at",
  matchRules: [
    {
      source_field: "effective_at",
      target_field: "effective_at",
      operator: "equals",
    },
  ],
  groupingField: "effective_at",
  agingEnabled: false,
  agingThresholdDays: 7,
}

module MatchRuleRow = {
  @react.component
  let make = (
    ~rule: ReconEngineRulesTypes.matchRuleType,
    ~index: int,
    ~onUpdate: (int, ReconEngineRulesTypes.matchRuleType) => unit,
    ~onRemove: int => unit,
    ~entryFieldOpts: array<SelectBox.dropdownOption>,
  ) => {
    let setSourceField = (fn: string => string) => {
      let newVal = fn(rule.source_field)
      onUpdate(index, {...rule, source_field: newVal})
    }

    let setOperator = (fn: string => string) => {
      let newVal = fn(rule.operator)
      onUpdate(index, {...rule, operator: newVal})
    }

    let setTargetField = (fn: string => string) => {
      let newVal = fn(rule.target_field)
      onUpdate(index, {...rule, target_field: newVal})
    }

    <div className="flex items-center gap-2 p-3 bg-nd_gray-50 rounded-lg">
      <div className="flex-1 flex flex-col gap-1">
        <label className="text-xs text-blue-600 font-medium">
          {"Source Field"->React.string}
        </label>
        <SelectBox
          input={makeControlledSelectInput(
            ~name=`matchSourceField_${index->Int.toString}`,
            ~value=rule.source_field,
            ~setValue=setSourceField,
          )}
          options={entryFieldOpts}
          deselectDisable=true
          showClearAll=false
        />
      </div>
      <div className="flex flex-col gap-1 w-24">
        <label className="text-xs text-nd_gray-500 font-medium"> {"Operator"->React.string} </label>
        <SelectBox
          input={makeControlledSelectInput(
            ~name=`matchOperator_${index->Int.toString}`,
            ~value=rule.operator,
            ~setValue=setOperator,
          )}
          options={operatorOptions}
          deselectDisable=true
          showClearAll=false
        />
      </div>
      <div className="flex-1 flex flex-col gap-1">
        <label className="text-xs text-green-600 font-medium">
          {"Target Field"->React.string}
        </label>
        <SelectBox
          input={makeControlledSelectInput(
            ~name=`matchTargetField_${index->Int.toString}`,
            ~value=rule.target_field,
            ~setValue=setTargetField,
          )}
          options={entryFieldOpts}
          deselectDisable=true
          showClearAll=false
        />
      </div>
      <div className="mt-4">
        <Button
          text="Remove"
          buttonType=Secondary
          buttonSize=XSmall
          onClick={_ => onRemove(index)}
          customButtonStyle="!text-red-400 !border-0"
        />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~wizardState: wizardState,
  ~onRuleCreated: createdRule => unit,
  ~onNext: unit => unit,
  ~onBack: unit => unit,
) => {
  let createRule = ReconEngineSelfServeHooks.useCreateReconRule()
  let (form, setForm) = React.useState(_ => defaultRuleForm)
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)
  let (showAging, setShowAging) = React.useState(_ => false)

  let setOneToOneSubtype = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.oneToOneSubtype->oneToOneSubtypeToString)
      let subtype = switch newStr {
      | "single_many" => SingleMany
      | "many_single" => ManySingle
      | "many_many" => ManyMany
      | _ => SingleSingle
      }
      {...prev, oneToOneSubtype: subtype}
    })

  let setSourceAccountId = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.sourceAccountId)
      {...prev, sourceAccountId: newVal}
    })

  let setTargetAccountId = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.targetAccountId)
      {...prev, targetAccountId: newVal}
    })

  let setTriggerField = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.triggerField)
      {...prev, triggerField: newVal}
    })

  let setTriggerOperator = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.triggerOperator)
      {...prev, triggerOperator: newVal}
    })

  let setGroupingField = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.groupingField)
      {...prev, groupingField: newVal}
    })

  let setSearchSourceField = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.searchSourceField)
      {...prev, searchSourceField: newVal}
    })

  let setSearchTargetField = (fn: string => string) =>
    setForm(prev => {
      let newVal = fn(prev.searchTargetField)
      {...prev, searchTargetField: newVal}
    })

  let accountOptions: array<SelectBox.dropdownOption> = wizardState.accounts->Array.map(account => {
    let typeLabel = account.account_type === "credit" ? "Credit" : "Debit"
    {SelectBox.label: `${account.account_name} (${typeLabel})`, value: account.account_id}
  })

  let entryFieldOpts = entryFieldOptions

  let needsGroupingField = switch form.oneToOneSubtype {
  | ManySingle | ManyMany => true
  | _ => false
  }

  let addMatchRule = () => {
    setForm(prev => {
      ...prev,
      matchRules: prev.matchRules->Array.concat([
        {source_field: "amount", target_field: "amount", operator: "equals"},
      ]),
    })
  }

  let updateMatchRule = (index, rule) => {
    setForm(prev => {
      let updated = prev.matchRules->Array.mapWithIndex((r, i) => i === index ? rule : r)
      {...prev, matchRules: updated}
    })
  }

  let removeMatchRule = index => {
    setForm(prev => {
      let updated = prev.matchRules->Array.filterWithIndex((_, i) => i !== index)
      {...prev, matchRules: updated}
    })
  }

  let handleSubmit = async () => {
    setIsSubmitting(_ => true)
    let result = await createRule(~form)
    switch result {
    | Some(rule) => {
        onRuleCreated(rule)
        setForm(_ => defaultRuleForm)
      }
    | None => ()
    }
    setIsSubmitting(_ => false)
  }

  <div className="flex flex-col gap-10 max-w-3xl">
    // Context from previous steps
    <RenderIf condition={wizardState.accounts->Array.length > 0}>
      <div
        className="flex flex-col gap-1 px-3 py-2 bg-nd_gray-50 rounded-lg text-xs text-nd_gray-500 ml-10 mb-2">
        <div className="flex items-center gap-2">
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {`Accounts: ${wizardState.accounts
            ->Array.map(a => a.account_name)
            ->Array.joinWith(", ")}`->React.string}
        </div>
        <RenderIf condition={wizardState.ingestions->Array.length > 0}>
          <div className="flex items-center gap-2">
            <Icon name="nd-check" customHeight="10" className="text-green-500" />
            {`Ingestions: ${wizardState.ingestions
              ->Array.map(i => i.name)
              ->Array.joinWith(", ")}`->React.string}
          </div>
        </RenderIf>
        <RenderIf condition={wizardState.transformations->Array.length > 0}>
          <div className="flex items-center gap-2">
            <Icon name="nd-check" customHeight="10" className="text-green-500" />
            {`Transformations: ${wizardState.transformations
              ->Array.map(t => t.name)
              ->Array.joinWith(", ")}`->React.string}
          </div>
        </RenderIf>
      </div>
    </RenderIf>
    // Header
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-sm font-semibold text-blue-600">
          {"4"->React.string}
        </div>
        <h2 className="text-lg font-semibold text-nd_gray-800">
          {"Define Recon Rules"->React.string}
        </h2>
      </div>
      <p className="text-sm text-nd_gray-500 leading-relaxed ml-10">
        {"Rules tell the engine HOW to match entries between accounts. Define the search strategy, match criteria, and which accounts to reconcile."->React.string}
      </p>
    </div>
    // Strategy explainer
    <div className="ml-10 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div className="flex flex-col gap-3">
        <p className="text-sm font-medium text-blue-700"> {"Strategy Types"->React.string} </p>
        <div className="grid grid-cols-2 gap-3">
          <div className="flex flex-col gap-1 p-2 bg-white rounded-md">
            <p className="text-xs font-semibold text-nd_gray-700">
              {"Single:Single"->React.string}
            </p>
            <p className="text-xs text-nd_gray-500">
              {"One source entry matches exactly one target entry."->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-1 p-2 bg-white rounded-md">
            <p className="text-xs font-semibold text-nd_gray-700"> {"Many:Many"->React.string} </p>
            <p className="text-xs text-nd_gray-500">
              {"Multiple sources grouped together match multiple targets. Common for batch settlements."->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-1 p-2 bg-white rounded-md">
            <p className="text-xs font-semibold text-nd_gray-700">
              {"Single:Many"->React.string}
            </p>
            <p className="text-xs text-nd_gray-500">
              {"One source matches many targets — e.g., one payout = multiple orders."->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-1 p-2 bg-white rounded-md">
            <p className="text-xs font-semibold text-nd_gray-700">
              {"Many:Single"->React.string}
            </p>
            <p className="text-xs text-nd_gray-500">
              {"Multiple source entries match one target — e.g., multiple partial payments."->React.string}
            </p>
          </div>
        </div>
      </div>
    </div>
    // Section 1: Basic Info
    <div className="ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"1"->React.string}
        </span>
        {"Rule Info"->React.string}
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Rule Name"->React.string}
          </label>
          <input
            type_="text"
            className="w-full px-3 py-2 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400 placeholder:text-nd_gray-300"
            placeholder="e.g., FIUU <-> Bank"
            value={form.ruleName}
            onChange={e => setForm(prev => {...prev, ruleName: ReactEvent.Form.target(e)["value"]})}
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Description"->React.string}
          </label>
          <input
            type_="text"
            className="w-full px-3 py-2 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400 placeholder:text-nd_gray-300"
            placeholder="e.g., Reconciliation between FIUU and Bank"
            value={form.ruleDescription}
            onChange={e =>
              setForm(prev => {...prev, ruleDescription: ReactEvent.Form.target(e)["value"]})}
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Priority"->React.string}
          </label>
          <p className="text-xs text-nd_gray-400">
            {"Lower number = higher priority. Rules are evaluated in order."->React.string}
          </p>
          <input
            type_="number"
            className="w-24 px-3 py-2 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400"
            value={form.priority->Int.toString}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              setForm(prev => {...prev, priority: v->Int.fromString->Option.getOr(1)})
            }}
          />
        </div>
      </div>
    </div>
    // Section 2: Strategy & Accounts
    <div className="ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"2"->React.string}
        </span>
        {"Strategy & Accounts"->React.string}
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Strategy Type"->React.string}
          </label>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="oneToOneSubtype",
              ~value=form.oneToOneSubtype->oneToOneSubtypeToString,
              ~setValue=setOneToOneSubtype,
            )}
            options={oneToOneSubtypeOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="flex flex-col gap-1.5 p-3 bg-blue-50 rounded-lg border border-blue-100">
            <label className="text-sm font-medium text-blue-700">
              {"Source Account"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="sourceAccountId",
                ~value=form.sourceAccountId,
                ~setValue=setSourceAccountId,
              )}
              options={accountOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <div className="flex flex-col gap-1.5 p-3 bg-green-50 rounded-lg border border-green-100">
            <label className="text-sm font-medium text-green-700">
              {"Target Account"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="targetAccountId",
                ~value=form.targetAccountId,
                ~setValue=setTargetAccountId,
              )}
              options={accountOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
        </div>
        // Grouping field (only for Many* strategies)
        <RenderIf condition={needsGroupingField}>
          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium text-nd_gray-700">
              {"Grouping Field"->React.string}
            </label>
            <p className="text-xs text-nd_gray-400">
              {"The field used to group multiple entries together (e.g., group by date for batch settlements)."->React.string}
            </p>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="groupingField",
                ~value=form.groupingField,
                ~setValue=setGroupingField,
              )}
              options={entryFieldOpts}
              deselectDisable=true
              showClearAll=false
            />
          </div>
        </RenderIf>
      </div>
    </div>
    // Section 3: Trigger
    <div className="ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"3"->React.string}
        </span>
        {"Source Trigger"->React.string}
      </div>
      <p className="text-xs text-nd_gray-400">
        {"A trigger filters which source entries are eligible for this rule. For example, \"currency equals MYR\" means only MYR entries are processed."->React.string}
      </p>
      <div className="grid grid-cols-3 gap-3">
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-nd_gray-600"> {"Field"->React.string} </label>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="triggerField",
              ~value=form.triggerField,
              ~setValue=setTriggerField,
            )}
            options={entryFieldOpts}
            deselectDisable=true
            showClearAll=false
          />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-nd_gray-600">
            {"Operator"->React.string}
          </label>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="triggerOperator",
              ~value=form.triggerOperator,
              ~setValue=setTriggerOperator,
            )}
            options={operatorOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-nd_gray-600"> {"Value"->React.string} </label>
          <input
            type_="text"
            className="w-full px-2.5 py-1.5 text-sm border border-nd_gray-200 rounded-md focus:outline-none focus:border-blue-400 placeholder:text-nd_gray-300"
            placeholder="e.g., MYR, USD"
            value={form.triggerValue}
            onChange={e =>
              setForm(prev => {...prev, triggerValue: ReactEvent.Form.target(e)["value"]})}
          />
        </div>
      </div>
    </div>
    // Section 4: Search & Match
    <div className="ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"4"->React.string}
        </span>
        {"Search & Match Rules"->React.string}
      </div>
      // Search identifier
      <div className="flex flex-col gap-3">
        <p className="text-xs text-nd_gray-500 font-medium">
          {"Search Identifier"->React.string}
        </p>
        <p className="text-xs text-nd_gray-400">
          {"Which fields are used to FIND candidate matches? The engine searches for target entries where the target field matches the source field value."->React.string}
        </p>
        <div className="grid grid-cols-2 gap-3">
          <div className="flex flex-col gap-1 p-2 bg-blue-50 rounded-md">
            <label className="text-xs font-medium text-blue-600">
              {"Source Field"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="searchSourceField",
                ~value=form.searchSourceField,
                ~setValue=setSearchSourceField,
              )}
              options={entryFieldOpts}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <div className="flex flex-col gap-1 p-2 bg-green-50 rounded-md">
            <label className="text-xs font-medium text-green-600">
              {"Target Field"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="searchTargetField",
                ~value=form.searchTargetField,
                ~setValue=setSearchTargetField,
              )}
              options={entryFieldOpts}
              deselectDisable=true
              showClearAll=false
            />
          </div>
        </div>
      </div>
      // Match rules
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <p className="text-xs text-nd_gray-500 font-medium"> {"Match Rules"->React.string} </p>
          <Button
            text="+ Add Rule"
            buttonType=Secondary
            buttonSize=XSmall
            onClick={_ => addMatchRule()}
            customButtonStyle="!text-blue-600 !border-0"
          />
        </div>
        <p className="text-xs text-nd_gray-400">
          {"After finding candidates, these rules determine if entries actually match. All rules must pass."->React.string}
        </p>
        {form.matchRules
        ->Array.mapWithIndex((rule, idx) =>
          <MatchRuleRow
            key={idx->Int.toString}
            rule
            index=idx
            onUpdate=updateMatchRule
            onRemove=removeMatchRule
            entryFieldOpts
          />
        )
        ->React.array}
      </div>
    </div>
    // Section 5: Aging (collapsible)
    <div className="ml-10 flex flex-col gap-3 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div
        className="flex items-center justify-between w-full cursor-pointer"
        onClick={_ => setShowAging(prev => !prev)}>
        <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
          <span
            className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
            {"5"->React.string}
          </span>
          {"Aging Config (Optional)"->React.string}
        </div>
        <Icon
          name={showAging ? "nd-angle-up" : "nd-angle-down"}
          className="text-nd_gray-400"
          customHeight="14"
        />
      </div>
      <RenderIf condition={showAging}>
        <p className="text-xs text-nd_gray-400">
          {"Aging determines when unmatched entries are flagged as exceptions. With a threshold, entries older than the specified days become exceptions."->React.string}
        </p>
        <div className="flex items-center gap-3">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type_="checkbox"
              className="rounded border-nd_gray-300"
              checked={form.agingEnabled}
              onChange={_ => setForm(prev => {...prev, agingEnabled: !prev.agingEnabled})}
            />
            <span className="text-sm text-nd_gray-700">
              {"Enable aging threshold"->React.string}
            </span>
          </label>
        </div>
        <RenderIf condition={form.agingEnabled}>
          <div className="flex items-center gap-2">
            <label className="text-xs font-medium text-nd_gray-600">
              {"Days:"->React.string}
            </label>
            <input
              type_="number"
              className="w-20 px-2.5 py-1.5 text-sm border border-nd_gray-200 rounded-md focus:outline-none focus:border-blue-400"
              value={form.agingThresholdDays->Int.toString}
              onChange={e => {
                let v = ReactEvent.Form.target(e)["value"]
                setForm(prev => {
                  ...prev,
                  agingThresholdDays: v->Int.fromString->Option.getOr(7),
                })
              }}
            />
            <span className="text-xs text-nd_gray-400"> {"week days"->React.string} </span>
          </div>
        </RenderIf>
      </RenderIf>
    </div>
    // Submit
    <div className="ml-10">
      <Button
        text="Create Recon Rule"
        buttonType=Primary
        buttonSize=Small
        onClick={_ => handleSubmit()->ignore}
        buttonState={isSubmitting ? Loading : Normal}
        customButtonStyle="w-full"
      />
    </div>
    // Created rules
    <RenderIf condition={wizardState.rules->Array.length > 0}>
      <div className="ml-10 flex flex-col gap-3">
        <h3 className="text-sm font-semibold text-nd_gray-700">
          {`Created Rules (${wizardState.rules->Array.length->Int.toString})`->React.string}
        </h3>
        {wizardState.rules
        ->Array.mapWithIndex((rule, idx) =>
          <div
            key={idx->Int.toString}
            className="flex items-center justify-between p-3 rounded-lg border border-nd_gray-200 bg-nd_gray-50">
            <div className="flex items-center gap-3">
              <Icon name="nd-check" customHeight="14" className="text-green-500" />
              <span className="text-sm font-medium text-nd_gray-700">
                {rule.rule_name->React.string}
              </span>
            </div>
            <span className="text-xs text-nd_gray-400 font-mono">
              {rule.rule_id->React.string}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
    // Navigation
    <div className="ml-10 flex gap-3">
      <Button
        text="Back"
        buttonType=Secondary
        buttonSize=Small
        onClick={_ => onBack()}
        leftIcon={CustomIcon(<Icon name="nd-arrow-left" customHeight="14" />)}
      />
      <RenderIf condition={wizardState.rules->Array.length > 0}>
        <Button
          text="Complete Setup"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => onNext()}
          rightIcon={CustomIcon(<Icon name="nd-arrow-right" customHeight="14" />)}
          customButtonStyle="flex-1"
        />
      </RenderIf>
    </div>
  </div>
}

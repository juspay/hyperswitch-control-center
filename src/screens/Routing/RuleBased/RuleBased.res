open LogicUtils
open RuleBasedHelper
open RuleBasedUtils
open Typography

@react.component
let make = (~baseUrlForRedirection) => {
  let rulesPath = "algorithm.data.rules"
  let showToast = ToastAdapter.useShowToast()
  let rulesInput = ReactFinalForm.useField(rulesPath).input
  let rules = rulesInput.value->getArrayFromJson([])
  let setRules = arr => rulesInput.onChange(arr->Identity.arrayOfGenericTypeToFormReactEvent)

  let handleAddRule = () =>
    rules->Array.some(isEmptyRule)
      ? showToast(
          ~message="Unable to add a new rule while an empty rule exists!",
          ~toastType=ToastError,
        )
      : addRule(~rules, ~setRules)

  let handleCopyRule = id =>
    switch rules->Array.find(ruleJson => ruleJson->idOfRule === id) {
    | Some(ruleJson) if ruleJson->isEmptyRule =>
      showToast(~message="Unable to copy an empty rule configuration!", ~toastType=ToastError)
    | _ => copyRule(~rules, ~setRules, ~id)
    }

  let renderRule = (index, ruleJson, _isDragging, _isDragDisabled) => {
    let id = ruleJson->idOfRule
    <RuleWrapper
      key=id
      prefix={`${rulesPath}[${index->Int.toString}]`}
      heading={`Rule ${(index + 1)->Int.toString}`}
      onCopy={() => handleCopyRule(id)}
      onRemove={() => removeRule(~rules, ~setRules, ~id)}
    />
  }

  <div className="flex flex-col gap-8">
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
      <DetailsFields />
      <GuideCard />
    </div>
    <div className="bg-white rounded-xl border border-nd_gray-200 px-4 py-6">
      <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Rule Builder"->React.string} </p>
      <p className={`${body.md.regular} text-nd_gray-600 mt-1`}>
        {"Define conditions and the processors traffic should be routed to when they match."->React.string}
      </p>
      <DragDropComponent
        listItems=rules setListItems=setRules keyExtractor=renderRule isHorizontal=false
      />
      <Button
        text="Add new rule"
        buttonType=Secondary
        leftIcon={CustomIcon(<Icon name="nd-plus" size=14 />)}
        onClick={_ => handleAddRule()}
      />
    </div>
    <p className={`${body.md.regular} text-nd_gray-600`}>
      {"In case the above rules fail, the routing will follow fallback routing. You can configure it "->React.string}
      <span
        className={`${body.md.medium} text-nd_primary_blue-500 cursor-pointer`}
        onClick={_ =>
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}/default`),
          )}>
        {"here"->React.string}
      </span>
    </p>
  </div>
}

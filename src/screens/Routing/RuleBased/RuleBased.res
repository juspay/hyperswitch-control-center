open LogicUtils
open RuleBasedHelper
open RuleBasedUtils
open Typography

@react.component
let make = () => {
  let rulesPath = "algorithm.data.rules"
  let rulesInput = ReactFinalForm.useField(rulesPath).input
  let rules = rulesInput.value->getArrayFromJson([])
  let setRules = arr => rulesInput.onChange(arr->Identity.arrayOfGenericTypeToFormReactEvent)

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
      {rules
      ->Array.mapWithIndex((rule, index) => {
        let id = rule->idOfRule
        <RuleWrapper
          key=id
          prefix={`${rulesPath}[${index->Int.toString}]`}
          heading={`Rule ${(index + 1)->Int.toString}`}
          onCopy={() => copyRule(~rules, ~setRules, ~id)}
          onRemove={() => removeRule(~rules, ~setRules, ~id)}
        />
      })
      ->React.array}
      <Button
        text="Add new rule"
        buttonType=Secondary
        leftIcon={CustomIcon(<Icon name="nd-plus" size=14 />)}
        onClick={_ => addRule(~rules, ~setRules)}
      />
    </div>
    <p className={`${body.md.regular} text-nd_gray-600`}>
      {"In case the above rules fail, the routing will follow fallback routing. You can configure it separately."->React.string}
    </p>
  </div>
}

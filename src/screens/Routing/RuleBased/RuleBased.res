open LogicUtils
open RuleBasedHelper
open Typography

@react.component
let make = () => {
  let rulesPath = "algorithm.data.rules"
  let idOfRule = json => json->getDictFromJsonObject->getString("id", "")
  let rulesInput = ReactFinalForm.useField(rulesPath).input
  let rules = rulesInput.value->getArrayFromJson([])
  let setRules = arr => rulesInput.onChange(arr->Identity.arrayOfGenericTypeToFormReactEvent)

  let addRule = () =>
    setRules(rules->Array.concat([RuleBasedUtils.newDefaultRule()->Identity.genericTypeToJson]))
  let copyRule = id =>
    rules
    ->Array.find(rule => rule->idOfRule === id)
    ->mapOptionOrDefault((), rule => {
      let dict = rule->getDictFromJsonObject->Dict.copy
      dict->Dict.set("id", `rule_${randomString(~length=6)}`->JSON.Encode.string)
      setRules(rules->Array.concat([dict->JSON.Encode.object]))
    })
  let removeRule = id => setRules(rules->Array.filter(rule => rule->idOfRule !== id))

  <div className="flex flex-col gap-8">
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
      <DetailsFields />
      <GuideCard />
    </div>
    <div className="bg-white rounded-xl border border-nd_gray-200 px-4 py-6">
      <h2 className={`${body.lg.semibold} text-nd_gray-800`}> {"Rule Builder"->React.string} </h2>
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
          onCopy={() => copyRule(id)}
          onRemove={() => removeRule(id)}
        />
      })
      ->React.array}
      <Button
        text="Add new rule"
        buttonType=Secondary
        leftIcon={CustomIcon(<Icon name="nd-plus" size=14 />)}
        onClick={_ => addRule()}
      />
    </div>
    <p className={`${body.md.regular} text-nd_gray-600`}>
      {"In case the above rules fail, the routing will follow fallback routing. You can configure it separately."->React.string}
    </p>
  </div>
}

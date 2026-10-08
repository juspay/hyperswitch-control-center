open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerQuery
open ExplorerHelper

@react.component
let make = (~viewContext: viewContext, ~onUpdate: Dict.t<string> => unit) => {
  let {question, dataset} = viewContext
  let source = question.source
  let splitOptions = question->splitOptions
  let setSelection = updates => updates->selectionUpdate->onUpdate
  let setSplitAt = (index, key) =>
    setSelection([
      ("split", question->splitAt(index, splitOptions->findDimension(key))->splitValue),
    ])

  <ExplorerCard className="flex flex-col gap-4 px-6 py-5">
    <div className="flex flex-wrap items-center gap-2">
      <QueryText text="Show" />
      <QuerySelect
        value={question.measure->measureToString}
        onChange={id => setSelection([("measure", id)])}
        options={source->measureOptions}
        placeholder="Measure"
      />
      <QueryText text="for" />
      <QueryText text={`all ${sourceNoun(source)},`} strong=true />
      <QueryText text="split by" />
      <QuerySelect
        value={question.split->Array.get(0)->Option.mapOr("", key => (key :> string))}
        onChange={key => setSplitAt(0, key)}
        options={source->dimensionOptions(splitOptions)}
        placeholder="Select"
        allowDeselect=true
        enableSearch=true
      />
      <RenderIf condition={question.split->isNonEmptyArray}>
        <QueryText text="then by" />
        <QuerySelect
          value={question.split->Array.get(1)->Option.mapOr("", key => (key :> string))}
          onChange={key => setSplitAt(1, key)}
          options={source->dimensionOptions(
            splitOptions->Array.filter(key => question.split->Array.get(0) != Some(key)),
          )}
          placeholder="Select"
          allowDeselect=true
          enableSearch=true
        />
      </RenderIf>
      <RenderIf condition={question->needsCurrency && dataset.amountCurrencies->isNonEmptyArray}>
        <QueryText text="in" />
        <QuerySelect
          value=dataset.amountCurrency
          onChange={currency => setSelection([("currency", currency)])}
          options={dataset.amountCurrencies->Array.map((
            currency
          ): MultiSelectBindings.selectMenuItemType => {label: currency, value: currency})}
          placeholder="Currency"
        />
      </RenderIf>
    </div>
    <div className={`flex items-center gap-1.5 ${body.sm.regular} text-nd_gray-500`}>
      <span className={body.sm.medium}>
        {`${measureLabel(source, question.measure)}:`->React.string}
      </span>
      {measureDefinition(source, question.measure)->React.string}
    </div>
  </ExplorerCard>
}

open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerQuery
open ExplorerHelper

@react.component
let make = (~question: question, ~dataset: dataset, ~onUpdate: Dict.t<string> => unit) => {
  let source = question.source
  let setSelection = updates => updates->selectionUpdate->onUpdate

  <ExplorerCard className="flex flex-col gap-4 px-6 py-5">
    <div className="flex flex-wrap items-center gap-x-2 gap-y-2">
      <QueryText text="Show" />
      <QuerySelect
        value={(question.measure :> string)}
        onChange={id => setSelection([(#measure, id)])}
        options={source->measureOptions}
        placeholder="Measure"
      />
      <QueryText text="for" />
      <QueryText text={`all ${sourceNoun(source)}`} strong=true />
      <RenderIf condition={question->needsCurrency && dataset.amountCurrencies->isNonEmptyArray}>
        <QueryText text="in" />
        <QuerySelect
          value=dataset.amountCurrency
          onChange={currency => setSelection([(#currency, currency)])}
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

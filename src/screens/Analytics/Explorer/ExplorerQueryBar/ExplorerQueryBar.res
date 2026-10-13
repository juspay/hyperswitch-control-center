open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerSelection
open ExplorerQueryBarHelper
open ExplorerQueryBarUtils

@react.component
let make = (~selection: selection, ~dataset: dataset, ~onUpdate: Dict.t<string> => unit) => {
  let {source, splitOptions} = selection
  let setSelection = updates => updates->selectionUpdate->onUpdate
  let setSplitAt = (index, key) =>
    setSelection([
      (#split, selection->splitAt(index, splitOptions->findDimension(key))->splitValue),
    ])

  <div
    className="flex flex-col gap-4 rounded-xl border border-nd_br_gray-200 bg-nd_gray-0 px-6 py-5">
    <div className="flex flex-wrap items-center gap-x-2 gap-y-2">
      <QueryText text="Show" />
      <QuerySelect
        value={(selection.measure :> string)}
        onChange={id => setSelection([(#measure, id)])}
        options={source->measureOptions}
        placeholder="Measure"
      />
      <QueryText text="for" />
      <QueryText text={`all ${sourceNoun(source)},`} strong=true />
      <QueryText text="split by" />
      <QuerySelect
        value={selection.split->Array.get(0)->mapOptionOrDefault("", key => (key :> string))}
        onChange={key => setSplitAt(0, key)}
        options={source->dimensionOptions(splitOptions)}
        placeholder="Select"
        allowDeselect=true
        enableSearch=true
      />
      <RenderIf condition={selection.split->isNonEmptyArray}>
        <QueryText text="then by" />
        <QuerySelect
          value={selection.split->Array.get(1)->mapOptionOrDefault("", key => (key :> string))}
          onChange={key => setSplitAt(1, key)}
          options={source->dimensionOptions(
            splitOptions->Array.filter(key => selection.split->Array.get(0) != Some(key)),
          )}
          placeholder="Select"
          allowDeselect=true
          enableSearch=true
        />
      </RenderIf>
      <RenderIf condition={selection->needsCurrency && dataset.amountCurrencies->isNonEmptyArray}>
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
        {`${measureLabel(source, selection.measure)}:`->React.string}
      </span>
      {measureDefinition(source, selection.measure)->React.string}
    </div>
  </div>
}

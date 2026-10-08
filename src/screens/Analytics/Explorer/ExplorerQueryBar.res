open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerQuery
open ExplorerHelper

@react.component
let make = (
  ~viewContext: viewContext,
  ~onUpdate: Dict.t<string> => unit,
  ~onClearFilters,
  ~editing: option<dimension>,
  ~setEditing,
) => {
  let {question, dataset} = viewContext
  let source = question.source
  let splitOptions = question->splitOptions
  let fetchFilterValues = ExplorerHooks.useFetchFilterValues()
  let (filterValuesByKey, setFilterValuesByKey) = React.useState(_ => Dict.make())
  let filterValuesKey =
    [
      source->sourceToString,
      editing->Option.mapOr("", key => (key :> string)),
      question.startTime,
      question.endTime,
    ]->Array.joinWith("|")
  let filterValues = filterValuesByKey->Dict.get(filterValuesKey)->Option.getOr([])
  let selected = editing->Option.mapOr([], key => question->getSelectedFilterValues(key))
  let setSelection = updates => updates->selectionUpdate->onUpdate
  let setSplitAt = (index, key) =>
    setSelection([
      ("split", question->splitAt(index, splitOptions->findDimension(key))->splitValue),
    ])
  let setFilter = (key, values) => getFilterUpdate(key, values)->onUpdate
  let toggleFilterValue = value =>
    editing->Option.forEach(key =>
      setFilter(
        key,
        selected->Array.includes(value)
          ? selected->Array.filter(item => item != value)
          : selected->Array.concat([value]),
      )
    )

  let getFilterValues = async dimension => {
    try {
      let values = await fetchFilterValues(~question, ~dimension)
      setFilterValuesByKey(prev => {
        let valuesByKey = prev->Dict.copy
        valuesByKey->Dict.set(filterValuesKey, values)
        valuesByKey
      })
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    switch (source, editing) {
    | (Intent, Some(#status)) | (_, None) => ()
    | (_, Some(dimension)) => getFilterValues(dimension)->ignore
    }
    None
  }, [filterValuesKey])

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
    <div className="flex flex-wrap items-center gap-2">
      <QueryText text="where" />
      <FilterChips
        viewContext
        editing
        onEdit=setEditing
        onRemove={key => {
          setFilter(key, [])
          if editing == Some(key) {
            setEditing(None)
          }
        }}
      />
      <QuerySelect
        value=""
        onChange={key => setEditing(question.dimensions->findDimension(key))}
        options={source->dimensionOptions(question.dimensions)}
        placeholder={question.filters->isEmptyArray ? "Add a filter" : "Add another"}
        enableSearch=true
      />
      {switch editing {
      | Some(key) =>
        <MultiSelectBindings
          selectedValues=selected
          onChange=toggleFilterValue
          items=[
            {
              items: (
                source == Intent && key == #status
                  ? ExplorerCatalog.intentStatuses->Array.map(status => (status :> string))
                  : filterValues
              )->Array.map((value): MultiSelectBindings.selectMenuItemType => {
                label: viewContext.labelFor(key, value),
                value,
              }),
            },
          ]
          placeholder={`${dimensionLabel(key)} is…`}
          size=Sm
          enableSearch=true
          selectionTagType=Count
          minMenuWidth=260
        />
      | None => React.null
      }}
      <RenderIf condition={question.filters->isNonEmptyArray}>
        <button
          className={`${body.md.medium} text-nd_primary_blue-500 hover:underline`}
          onClick={_ => {
            onClearFilters()
            setEditing(None)
          }}>
          {"Clear filters"->React.string}
        </button>
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

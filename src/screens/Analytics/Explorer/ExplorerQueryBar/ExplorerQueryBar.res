open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerSelection
open ExplorerQueryBarHelper
open ExplorerQueryBarUtils

@react.component
let make = (
  ~selection: selection,
  ~dataset: dataset,
  ~labelFor,
  ~onUpdate: Dict.t<string> => unit,
  ~editing: option<dimension>,
  ~setEditing,
) => {
  let {source, splitOptions} = selection
  let fetchFilterValues = ExplorerHooks.useFetchFilterValues()
  let (filterValuesByKey, setFilterValuesByKey) = React.useState(_ => Dict.make())
  let filterValuesKey =
    [
      (source :> string),
      editing->mapOptionOrDefault("", key => (key :> string)),
      selection.startTime,
      selection.endTime,
    ]->Array.joinWith("|")
  let filterValues = filterValuesByKey->getValueFromDict(filterValuesKey, [])
  let selected = editing->mapOptionOrDefault([], key => selection->getSelectedFilterValues(key))
  let splitIds = selection.split->Array.map(key => (key :> string))
  let thenByOptions =
    splitOptions->Array.filter(key => (key :> string) != splitIds->getValueFromArray(0, ""))
  let setSelection = updates => updates->selectionUpdate->onUpdate
  let setSplitAt = (index, key) =>
    setSelection([
      (#split, selection->splitAt(index, splitOptions->findDimension(key))->splitValue),
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
      let values = await fetchFilterValues(~selection, ~dimension)
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
    switch editing {
    | Some(dimension) if getStaticFilterValues(source, dimension)->Option.isNone =>
      getFilterValues(dimension)->ignore
    | _ => ()
    }
    None
  }, [filterValuesKey])

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
        value={splitIds->getValueFromArray(0, "")}
        onChange={key => setSplitAt(0, key)}
        options={source->dimensionOptions(splitOptions)}
        placeholder="Select"
        allowDeselect=true
        enableSearch=true
      />
      <RenderIf condition={selection.split->isNonEmptyArray}>
        <QueryText text="then by" />
        <QuerySelect
          value={splitIds->getValueFromArray(1, "")}
          onChange={key => setSplitAt(1, key)}
          options={source->dimensionOptions(thenByOptions)}
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
    <div className="flex flex-wrap items-center gap-2">
      <QueryText text="where" />
      <FilterChips
        selection
        labelFor
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
        onChange={key => setEditing(selection.filterOptions->findDimension(key))}
        options={source->dimensionOptions(selection.filterOptions)}
        placeholder={selection.filters->isEmptyArray ? "Add a filter" : "Add another"}
        enableSearch=true
      />
      {switch editing {
      | Some(key) if selection.filterOptions->Array.includes(key) =>
        <MultiSelectBindings
          selectedValues=selected
          onChange=toggleFilterValue
          items=[
            {
              items: getStaticFilterValues(source, key)
              ->Option.getOr(filterValues)
              ->Array.map((value): MultiSelectBindings.selectMenuItemType => {
                label: labelFor(key, value),
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
      | _ => React.null
      }}
      <RenderIf condition={selection.filters->isNonEmptyArray}>
        <Button
          text="Clear filters"
          buttonType=Secondary
          buttonSize=XSmall
          onClick={_ => {
            selection->getClearFiltersUpdate->onUpdate
            setEditing(None)
          }}
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

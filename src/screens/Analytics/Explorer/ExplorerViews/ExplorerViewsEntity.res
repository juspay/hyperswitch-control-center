open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerData
open ExplorerDescriptions

let outcomeColumns = [OutcomeName, OutcomeCount, OutcomeChange, OutcomeShare]

let getOutcomeRows = (selection, dataset) => {
  let hasPrevious = dataset.overallPrevious.total > 0.0
  outcomes->Array.map(field => {
    let current = dataset.overall->getCount(field)
    let previous = hasPrevious ? Some(dataset.overallPrevious->getCount(field)) : None
    {
      outcome: outcomeLabel(selection.source, field),
      count: current,
      change: formatChange(#volume, current, previous),
      share: calculatePercentage(current, dataset.overall.total),
    }
  })
}

let getOutcomeHeading = (source, colType) =>
  switch colType {
  | OutcomeName => Table.makeHeaderInfo(~key="outcome", ~title="Outcome")
  | OutcomeCount => Table.makeHeaderInfo(~key="count", ~title=measureLabel(source, #volume))
  | OutcomeChange => Table.makeHeaderInfo(~key="change", ~title="Change")
  | OutcomeShare => Table.makeHeaderInfo(~key="share", ~title=`Share of ${sourceNoun(source)}`)
  }

let getOutcomeCell = (row: outcomeRow, colType): Table.cell =>
  switch colType {
  | OutcomeName => Text(row.outcome)
  | OutcomeCount => Text(row.count->formatNumberWithCommas)
  | OutcomeChange => Text(row.change)
  | OutcomeShare => Text(row.share->formatPercentage)
  }

let getOutcomeTableEntity = source =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=outcomeColumns,
    ~getHeading=colType => getOutcomeHeading(source, colType),
    ~getCell=getOutcomeCell,
  )

let getGroupColumns = selection =>
  selection.split
  ->Array.map(key => SplitColumn(key))
  ->Array.concat([MeasureColumn, ChangeColumn, VolumeColumn, ShareColumn])

let getGroupRows = (selection, dataset, ~labelFor) => {
  let {source, measure} = selection
  let (totals, _) = dataset->getMeasureCounts(measure)
  dataset.groups->Array.map(group => {
    let current = getMeasureValue(source, measure, group.current)
    let previous =
      group.previous->Option.map(previousCounts => getMeasureValue(source, measure, previousCounts))
    {
      labels: selection.split->Array.mapWithIndex((key, index) => (
        key,
        labelFor(key, group.values->getValueFromArray(index, "")),
      )),
      value: formatValue(source, measure, group.current, ~currency=dataset.amountCurrency),
      change: formatChange(measure, current, previous),
      impact: getChangeImpact(measure, current, previous),
      volume: group.current.total,
      share: calculatePercentage(group.current.total, totals.total),
    }
  })
}

let getGroupHeading = (selection, colType, ~currency) => {
  let {source, measure} = selection
  let records = isAmount(measure) ? `${currency} ${sourceNoun(source)}` : sourceNoun(source)
  switch colType {
  | SplitColumn(key) => Table.makeHeaderInfo(~key=(key :> string), ~title=dimensionLabel(key))
  | MeasureColumn => Table.makeHeaderInfo(~key="value", ~title=measureLabel(source, measure))
  | ChangeColumn => Table.makeHeaderInfo(~key="change", ~title="Change")
  | VolumeColumn =>
    Table.makeHeaderInfo(
      ~key="volume",
      ~title=isAmount(measure) ? records : measureLabel(source, #volume),
    )
  | ShareColumn => Table.makeHeaderInfo(~key="share", ~title=`Share of ${records}`)
  }
}

let getGroupCell = (row: groupRow, colType): Table.cell =>
  switch colType {
  | SplitColumn(key) =>
    Text(
      row.labels
      ->Array.find(((column, _)) => column == key)
      ->mapOptionOrDefault("", ((_, label)) => label),
    )
  | MeasureColumn => Text(row.value)
  | ChangeColumn =>
    let (impactTextClass, _) = row.impact->getImpactClasses
    CustomCell(<span className=impactTextClass> {row.change->React.string} </span>, "")
  | VolumeColumn => Text(row.volume->formatNumberWithCommas)
  | ShareColumn => Text(row.share->formatPercentage)
  }

let getGroupTableEntity = (selection, ~currency) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=getGroupColumns(selection),
    ~getHeading=colType => getGroupHeading(selection, colType, ~currency),
    ~getCell=getGroupCell,
  )

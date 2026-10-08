open Typography
open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerData
open ExplorerDescriptions

let outcomeColumns = [OutcomeName, OutcomeCount, OutcomeChange, OutcomeShare]

let getOutcomeRows = (viewContext: viewContext) => {
  let {question, dataset, hasPrevious} = viewContext
  getSourceOutcomes(question.source)->Array.map(field => {
    let current = dataset.overall->getCount(field)
    let previous = hasPrevious ? Some(dataset.overallPrevious->getCount(field)) : None
    {
      outcome: outcomeLabel(question.source, field),
      count: current,
      change: hasPrevious ? formatChange(Volume, current, previous) : "",
      share: calculatePercentage(current, dataset.overall.total),
    }
  })
}

let getOutcomeHeading = (source, colType) =>
  switch colType {
  | OutcomeName => Table.makeHeaderInfo(~key="outcome", ~title="Outcome")
  | OutcomeCount => Table.makeHeaderInfo(~key="count", ~title=measureLabel(source, Volume))
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

let getGroupColumns = question =>
  question.split
  ->Array.map(key => SplitColumn(key))
  ->Array.concat([MeasureColumn, ChangeColumn, VolumeColumn, ShareColumn])

let getGroupRows = (viewContext: viewContext) => {
  let {question, dataset, hasPrevious} = viewContext
  let {source, measure} = question
  dataset.sorted->Array.map(group => {
    let current = getMeasureValue(source, measure, group.current)
    let previous =
      group.previous->Option.map(previousCounts => getMeasureValue(source, measure, previousCounts))
    {
      group,
      labels: question.split->Array.mapWithIndex((key, index) => (
        key,
        viewContext.labelFor(key, group.values->getValueFromArray(index, "")),
      )),
      value: formatValue(source, measure, group.current, ~currency=viewContext.singleCurrency),
      isLowVolume: question->isSmall(~minimumRateBase=dataset.minimumRateBase, group),
      change: hasPrevious ? formatChange(measure, current, previous) : "",
      impact: getChangeImpact(measure, current, previous),
      volume: group.current.total,
      share: calculatePercentage(group.current.total, dataset.overall.total),
    }
  })
}

let getGroupHeading = (question, colType) => {
  let {source, measure} = question
  switch colType {
  | SplitColumn(key) => Table.makeHeaderInfo(~key=(key :> string), ~title=dimensionLabel(key))
  | MeasureColumn => Table.makeHeaderInfo(~key="value", ~title=measureLabel(source, measure))
  | ChangeColumn => Table.makeHeaderInfo(~key="change", ~title="Change")
  | VolumeColumn => Table.makeHeaderInfo(~key="volume", ~title=measureLabel(source, Volume))
  | ShareColumn => Table.makeHeaderInfo(~key="share", ~title=`Share of ${sourceNoun(source)}`)
  }
}

let getGroupCell = (row: groupRow, colType): Table.cell =>
  switch colType {
  | SplitColumn(key) =>
    Text(
      row.labels
      ->Array.find(((column, _)) => column == key)
      ->Option.mapOr("", ((_, label)) => label),
    )
  | MeasureColumn =>
    row.isLowVolume
      ? CustomCell(
          <span>
            {row.value->React.string}
            <span className={`ml-1 ${body.sm.regular} text-nd_gray-400`}>
              {"low volume"->React.string}
            </span>
          </span>,
          "",
        )
      : Text(row.value)
  | ChangeColumn =>
    CustomCell(
      <span
        className={switch row.impact {
        | Favorable => "text-nd_green-600"
        | Unfavorable => "text-nd_red-600"
        | Neutral => "text-nd_gray-500"
        }}>
        {row.change->React.string}
      </span>,
      "",
    )
  | VolumeColumn => Text(row.volume->formatNumberWithCommas)
  | ShareColumn => Text(row.share->formatPercentage)
  }

let getGroupTableEntity = question =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=getGroupColumns(question),
    ~getHeading=colType => getGroupHeading(question, colType),
    ~getCell=getGroupCell,
  )

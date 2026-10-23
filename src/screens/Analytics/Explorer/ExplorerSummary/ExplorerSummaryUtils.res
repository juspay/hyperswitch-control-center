open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerSelection
open ExplorerData
open ExplorerDescriptions
open ExplorerChartsUtils

let getFilterText = (context: chartContext) =>
  context.selection.filters
  ->Array.map(((key, values)) =>
    `${dimensionLabel(key)->String.toLowerCase} is ${values
      ->Array.map(value => context.labelFor(key, value))
      ->Array.joinWith(" or ")}`
  )
  ->Array.joinWith(" and ")

let getHeadline = (context: chartContext) => {
  let {selection, dataset} = context
  let {source, measure} = selection
  let (counts, previousCounts) = dataset->getMeasureCounts(measure)
  if !measurable(source, measure, counts) {
    unmeasurableNote(source, measure)
  } else {
    let filterText = context->getFilterText
    let scope = `all ${sourceNoun(source)}${filterText->isNonEmptyString
        ? ` where ${filterText}`
        : ""}`
    let (previousStart, previousEnd) = selection->previousWindow
    let comparison =
      context->hasPrevious(~measure)
        ? `, ${getChangeInWords(
              measure,
              getMeasureValue(source, measure, counts),
              getMeasureValue(source, measure, previousCounts),
            )} from ${periodLabel(previousStart, previousEnd)}`
        : ", with nothing to compare in the previous period"
    let value = formatValue(source, measure, counts, ~currency=dataset.amountCurrency)
    measure == #volume
      ? `${scope->capitalizeString} totalled ${value} in ${context->currentLabel}${comparison}.`
      : `${measureLabel(
            source,
            measure,
          )} for ${scope} was ${value} in ${context->currentLabel}${comparison}.`
  }
}

let getCurrencyLine = (context: chartContext) =>
  context.selection->needsCurrency
    ? `Counts and amounts are for ${context.dataset.amountCurrency} only. Other currencies are left out.`
    : ""

let getGroupsByMeasure = (context: chartContext) => {
  let {source, measure} = context.selection
  context.dataset.groups->Array.toSorted((a, b) =>
    getMeasureValue(source, measure, b.current) -. getMeasureValue(source, measure, a.current)
  )
}

let getRateSplitLine = (context: chartContext, ~by) => {
  let {selection, dataset} = context
  let {source, measure} = selection
  let valueText = group =>
    formatValue(source, measure, group.current, ~currency=dataset.amountCurrency)
  let ranked =
    context
    ->getGroupsByMeasure
    ->Array.filter(group => group.values->Array.every(isNonEmptyString))
  let leftOut = dataset.unmeasured->Array.length
  let leftOutText =
    leftOut > 0
      ? ` Left out: ${leftOut->Int.toString} with ${unmeasurableReason(source, measure)}.`
      : ""
  switch (ranked->Array.get(0), ranked->Array.at(-1)) {
  | (Some(top), Some(bottom)) if ranked->Array.length > 1 =>
    `By ${by}, ${context->groupLabel(top)} is highest at ${valueText(
        top,
      )} and ${context->groupLabel(bottom)} is lowest at ${valueText(bottom)}.${leftOutText}`
  | (Some(top), _) =>
    `By ${by}, only ${context->groupLabel(top)} has a value (${valueText(top)}).${leftOutText}`
  | (None, _) => `By ${by}, no group has a value for this measure.`
  }
}

let getAmountSplitLine = (context: chartContext, ~by) => {
  let {selection, dataset} = context
  let {source, measure} = selection
  let (counts, _) = dataset->getMeasureCounts(measure)
  context
  ->getGroupsByMeasure
  ->Array.get(0)
  ->mapOptionOrDefault("", top => {
    let value = formatValue(source, measure, top.current, ~currency=dataset.amountCurrency)
    measure == #avg_ticket
      ? `By ${by}, ${context->groupLabel(top)} is the highest at ${value}.`
      : `By ${by}, ${context->groupLabel(top)} is the largest at ${value}, ${calculatePercentage(
            getMeasureValue(source, measure, top.current),
            getMeasureValue(source, measure, counts),
          )->formatPercentage} of the ${isAmount(measure) ? "total amount" : "total"}.`
  })
}

let getSplitLine = (context: chartContext) => {
  let {selection, dataset} = context
  let {source, measure, split} = selection
  let (counts, _) = dataset->getMeasureCounts(measure)
  if split->isEmptyArray || !measurable(source, measure, counts) {
    ""
  } else {
    let by =
      split->Array.map(key => dimensionLabel(key)->String.toLowerCase)->Array.joinWith(" and ")
    isRate(measure) ? context->getRateSplitLine(~by) : context->getAmountSplitLine(~by)
  }
}

let getOutcomeParts = (context: chartContext): array<StackedBarGraphTypes.dataObj> => {
  let {selection, dataset} = context
  outcomes
  ->Array.filter(field => dataset.overall->getCount(field) > 0.0)
  ->Array.map((field): StackedBarGraphTypes.dataObj => {
    name: outcomeLabel(selection.source, field),
    data: [dataset.overall->getCount(field)],
    color: getOutcomeColor(field),
  })
}

let isExcludedFromRate = (context: chartContext) => {
  let {selection, dataset} = context
  switch getMeasureFormula(selection.source, selection.measure) {
  | Rate(_, EligibleRecords) => dataset.overall.excluded > 0.0
  | _ => false
  }
}

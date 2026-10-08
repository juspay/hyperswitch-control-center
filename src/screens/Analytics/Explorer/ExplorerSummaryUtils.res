open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerQuery
open ExplorerData
open ExplorerDescriptions

let getFilterText = (viewContext: viewContext) =>
  viewContext.question.filters
  ->Array.map(((key, values)) =>
    `${dimensionLabel(key)->String.toLowerCase} is ${values
      ->Array.map(value => viewContext.labelFor(key, value))
      ->Array.joinWith(" or ")}`
  )
  ->Array.joinWith(" and ")

let getHeadline = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  let {source, measure} = question
  if !measurable(source, measure, dataset.overall) {
    unmeasurableNote(source, measure)
  } else {
    let filterText = viewContext->getFilterText
    let scope = `all ${sourceNoun(source)}${filterText->isNonEmptyString
        ? ` where ${filterText}`
        : ""}`
    let comparison =
      viewContext.hasPrevious && measurable(source, measure, dataset.overallPrevious)
        ? `, ${getChangeInWords(
              measure,
              getMeasureValue(source, measure, dataset.overall),
              getMeasureValue(source, measure, dataset.overallPrevious),
            )} from ${viewContext.previousLabel}`
        : ", with nothing to compare in the previous period"
    let value = formatValue(source, measure, dataset.overall, ~currency=viewContext.singleCurrency)
    measure == Volume
      ? `${scope->capitalizeString} totalled ${value} in ${viewContext.currentLabel}${comparison}.`
      : `${measureLabel(
            source,
            measure,
          )} for ${scope} was ${value} in ${viewContext.currentLabel}${comparison}.`
  }
}

let getCurrencyLine = (viewContext: viewContext) =>
  viewContext.question->needsCurrency
    ? `Counts and amounts are for ${viewContext.dataset.amountCurrency} only. Other currencies are left out.`
    : ""

let getSplitLine = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  let {source, measure} = question
  if question.split->isEmptyArray || !measurable(source, measure, dataset.overall) {
    ""
  } else {
    let by =
      question.split
      ->Array.map(key => dimensionLabel(key)->String.toLowerCase)
      ->Array.joinWith(" and ")
    let valueText = group =>
      formatValue(source, measure, group.current, ~currency=viewContext.singleCurrency)
    if isRate(measure) {
      let small = group => question->isSmall(~minimumRateBase=dataset.minimumRateBase, group)
      let byValue =
        dataset.sorted
        ->Array.filter(group => !small(group) && group.values->Array.every(isNonEmptyString))
        ->Array.toSorted((a, b) =>
          getMeasureValue(source, measure, b.current) -. getMeasureValue(source, measure, a.current)
        )
      let left = dataset.sorted->Array.filter(small)->Array.length
      let leftText =
        left > 0
          ? ` ${left->Int.toString} low-volume ${left == 1
                ? "group is"
                : "groups are"} excluded from this comparison.`
          : ""
      switch (byValue->Array.get(0), byValue->Array.at(-1)) {
      | (Some(top), Some(bottom)) if byValue->Array.length > 1 =>
        `By ${by}, ${viewContext.groupLabel(top)} is highest at ${valueText(
            top,
          )} and ${viewContext.groupLabel(bottom)} is lowest at ${valueText(bottom)}.${leftText}`
      | (Some(top), _) =>
        `By ${by}, only ${viewContext.groupLabel(
            top,
          )} has enough volume for a meaningful comparison (${valueText(top)}).${leftText}`
      | (None, _) => `By ${by}, no group has enough volume for a meaningful comparison.`
      }
    } else {
      switch dataset.sorted->Array.get(0) {
      | Some(top) if measure == AvgTicket =>
        `By ${by}, ${viewContext.groupLabel(top)} is the highest at ${valueText(top)}.`
      | Some(top) =>
        `By ${by}, ${viewContext.groupLabel(top)} is the largest at ${valueText(
            top,
          )}, ${calculatePercentage(
            getMeasureValue(source, measure, top.current),
            getMeasureValue(source, measure, dataset.overall),
          )->formatPercentage} of the ${isAmount(measure) ? "total amount" : "total"}.`
      | None => ""
      }
    }
  }
}

let getOutcomeParts = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  getSourceOutcomes(question.source)
  ->Array.map(field => (
    outcomeLabel(question.source, field),
    dataset.overall->getCount(field),
    getOutcomeColor(field),
  ))
  ->Array.filter(((_, value, _)) => value > 0.0)
}

let isAwaitingExcluded = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  switch getMeasureFormula(question.source, question.measure) {
  | Rate(_, CompletedRecords) => dataset.overall.awaiting > 0.0
  | _ => false
  }
}

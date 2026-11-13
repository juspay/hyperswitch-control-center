open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions

let maxUnmeasuredGroupsListed = 5

let getUnmeasuredNote = (selection, dataset, ~labelFor) => {
  let {source, measure, split} = selection
  let names =
    dataset.unmeasured
    ->Array.slice(~start=0, ~end=maxUnmeasuredGroupsListed)
    ->Array.map(((values, counts)) => {
      let labels = values->getValuesLabel(~split, ~labelFor)
      `${labels} (${counts.total->formatNumberWithCommas} ${sourceNoun(
          source,
        )}, ${unmeasurableReason(source, measure)})`
    })
    ->Array.joinWith("; ")
  let remaining = dataset.unmeasured->Array.length - maxUnmeasuredGroupsListed
  let more = remaining > 0 ? ` and ${remaining->Int.toString} more` : ""
  let label = measureLabel(source, measure)
  let label = String.toLowerCase(String.charAt(label, 0)) ++ label->String.sliceToEnd(~start=1)
  `Excluded from the ${label}: ${names}${more}.`
}

let getBlankSplitNote = (selection, dataset) =>
  selection.split
  ->Array.filterWithIndex((_, index) =>
    dataset.groups->isNonEmptyArray &&
      dataset.groups->Array.every(group =>
        group.values->getValueFromArray(index, "")->isEmptyString
      )
  )
  ->Array.map(key =>
    `${dimensionLabel(key)} is blank for everything counted in this measure, so it can't split it.`
  )
  ->Array.joinWith(" ")

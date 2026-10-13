open LogicUtils
open ExplorerTypes
open ExplorerDescriptions

let maxUnmeasuredGroupsListed = 5

let getUnmeasuredNote = (selection, dataset, ~labelFor) => {
  let {source, measure, split} = selection
  let names =
    dataset.unmeasured
    ->Array.slice(~start=0, ~end=maxUnmeasuredGroupsListed)
    ->Array.map(((values, counts)) => {
      let labels =
        split
        ->Array.mapWithIndex((key, index) => labelFor(key, values->getValueFromArray(index, "")))
        ->Array.joinWith(" · ")
      `${labels} (${counts.total->formatNumberWithCommas} ${sourceNoun(
          source,
        )}, ${unmeasurableReason(source, measure)})`
    })
    ->Array.joinWith("; ")
  let remaining = dataset.unmeasured->Array.length - maxUnmeasuredGroupsListed
  let more = remaining > 0 ? ` and ${remaining->Int.toString} more` : ""
  `Excluded from the ${measureLabel(source, measure)->String.toLowerCase}: ${names}${more}.`
}

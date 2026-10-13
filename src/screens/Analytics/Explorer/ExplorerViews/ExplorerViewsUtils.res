open LogicUtils
open ExplorerTypes
open ExplorerDescriptions

let getUnmeasuredNote = (question, dataset, ~labelFor) => {
  let {source, measure, split} = question
  let names =
    dataset.unmeasured
    ->Array.map(((values, counts)) => {
      let labels =
        values
        ->Array.mapWithIndex((value, index) =>
          split->Array.get(index)->mapOptionOrDefault(value, key => labelFor(key, value))
        )
        ->Array.joinWith(" · ")
      `${labels} (${counts.total->formatNumberWithCommas} ${sourceNoun(
          source,
        )}, ${unmeasurableReason(source, measure)})`
    })
    ->Array.joinWith("; ")
  `Excluded from the ${measureLabel(source, measure)->String.toLowerCase}: ${names}.`
}

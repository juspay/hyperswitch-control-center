open ReconEngineOverviewUtils

let getSummaryStackedBarGraphData = (
  ~postedCount: int,
  ~mismatchedCount: int,
  ~expectedCount: int,
) => {
  open StackedBarGraphTypes
  {
    categories: ["Transactions"],
    data: [
      {
        name: "Mismatched",
        data: [mismatchedCount->Int.toFloat],
        color: mismatchedColor,
      },
      {
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: pendingColor,
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: matchedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

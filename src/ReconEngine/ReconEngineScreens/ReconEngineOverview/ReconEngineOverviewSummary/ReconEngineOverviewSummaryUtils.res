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
        color: ReconEngineOverviewUtils.mismatchedColor,
      },
      {
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: ReconEngineOverviewUtils.pendingColor,
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: ReconEngineOverviewUtils.matchedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

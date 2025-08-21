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
        color: "#EA8A8F",
      },
      {
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: "#F3BE8B",
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: "#7AB891",
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

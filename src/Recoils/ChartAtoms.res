// ChartAtoms.res
// Performance optimization for Issue #4559
// Split chart state into granular Recoil atoms to prevent unnecessary re-renders
//
// Migration from ChartContext:
// Before: let {topChartData} = React.useContext(ChartContext.chartContext)
// After:  let topChartData = Recoil.useRecoilValueFromAtom(ChartAtoms.topChartDataAtom)

open AnalyticsTypesUtils

// Separate atoms for each chart data type
// Components only re-render when their specific atom changes

let topChartDataAtom: Recoil.recoilAtom<dataState<JSON.t>> = Recoil.atom("topChartData", Loading)

let bottomChartDataAtom: Recoil.recoilAtom<dataState<JSON.t>> = Recoil.atom(
  "bottomChartData",
  Loading,
)

let topChartLegendDataAtom: Recoil.recoilAtom<dataState<JSON.t>> = Recoil.atom(
  "topChartLegendData",
  Loading,
)

let bottomChartLegendDataAtom: Recoil.recoilAtom<dataState<JSON.t>> = Recoil.atom(
  "bottomChartLegendData",
  Loading,
)

// Configuration atoms - change less frequently
let granularityAtom: Recoil.recoilAtom<option<string>> = Recoil.atom("chartGranularity", None)

let topChartVisibleAtom: Recoil.recoilAtom<bool> = Recoil.atom("topChartVisible", false)

let bottomChartVisibleAtom: Recoil.recoilAtom<bool> = Recoil.atom("bottomChartVisible", false)

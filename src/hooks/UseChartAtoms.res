// UseChartAtoms.res
// Convenience hooks for consuming chart atoms
// Part of Issue #4559 performance optimization
//
// These hooks provide a cleaner API for accessing chart state
// and handle the Recoil boilerplate internally
//
// Migration from ChartContext:
//   Before: let {topChartData} = React.useContext(ChartContext.chartContext)
//   After:  let topChartData = UseChartAtoms.useTopChartData()

// Hook for accessing top chart data
// This component will only re-render when topChartData changes
// Bottom chart updates won't trigger re-renders
let useTopChartData = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.topChartDataAtom)
}

// Hook for accessing bottom chart data
// This component will only re-render when bottomChartData changes
// Top chart updates won't trigger re-renders
let useBottomChartData = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.bottomChartDataAtom)
}

// Hook for accessing top chart legend data
let useTopChartLegendData = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.topChartLegendDataAtom)
}

// Hook for accessing bottom chart legend data
let useBottomChartLegendData = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.bottomChartLegendDataAtom)
}

// Hook for accessing granularity
let useGranularity = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.granularityAtom)
}

// Hook for accessing top chart visibility
let useTopChartVisible = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.topChartVisibleAtom)
}

// Hook for accessing bottom chart visibility
let useBottomChartVisible = () => {
  Recoil.useRecoilValueFromAtom(ChartAtoms.bottomChartVisibleAtom)
}

// Hook for accessing chart action functions
// These are stable and won't cause re-renders
let useChartActions = () => {
  ChartContextOptimized.useChartActions()
}

// Setter hooks for granular updates
let useSetTopChartData = () => {
  Recoil.useSetRecoilState(ChartAtoms.topChartDataAtom)
}

let useSetBottomChartData = () => {
  Recoil.useSetRecoilState(ChartAtoms.bottomChartDataAtom)
}

let useSetTopChartLegendData = () => {
  Recoil.useSetRecoilState(ChartAtoms.topChartLegendDataAtom)
}

let useSetBottomChartLegendData = () => {
  Recoil.useSetRecoilState(ChartAtoms.bottomChartLegendDataAtom)
}

let useSetGranularity = () => {
  Recoil.useSetRecoilState(ChartAtoms.granularityAtom)
}

let useSetTopChartVisible = () => {
  Recoil.useSetRecoilState(ChartAtoms.topChartVisibleAtom)
}

let useSetBottomChartVisible = () => {
  Recoil.useSetRecoilState(ChartAtoms.bottomChartVisibleAtom)
}

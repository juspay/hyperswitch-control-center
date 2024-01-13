open LazyUtils
open HighchartsGanttChart

type props = {
  highcharts: highcharts,
  options?: Js.Json.t,
  constructorType: string,
}

let make: props => React.element = reactLazy(.() => import_("highcharts-react-official"))

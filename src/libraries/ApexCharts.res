type zoom = {enabled: bool}

type display = {show: bool}

type padding = {
  left?: int,
  right?: int,
  top?: int,
  bottom?: int,
}

type chart = {
  height?: int,
  zoom?: zoom,
  toolbar?: display,
  padding?: padding,
  offsetY?: float,
}

type dataLabels = {enabled?: bool}

type stroke = {curve?: string, dashArray?: int}
type title = {
  text?: string,
  align?: string,
}

type axis = {
  labels: display,
  axisBorder: display,
  axisTicks: display,
}

type tooltip = {enabled: bool}

type options = {
  chart?: chart,
  dataLabels: dataLabels,
  stroke?: stroke,
  labels?: array<string>,
  title?: title,
  legend?: display,
  grid?: display,
  xaxis?: axis,
  yaxis?: axis,
  tooltip?: tooltip,
  colors?: array<string>,
  plotOptions?: JSON.t,
  fill?: JSON.t,
}

type point = {
  x: float,
  y: float,
}

type objPoints = {
  name?: string,
  \"type"?: string,
  data: array<point>,
}

external userObjToJson: objPoints => JSON.t = "%identity"

let objToJson = (arr: array<objPoints>) => {
  arr->Array.map(userObjToJson)
}

module ReactApexChart = {
  @module("react-apexcharts") @react.component
  external make: (
    ~options: options,
    ~series: array<JSON.t>,
    ~\"type": string,
    ~height: string,
    ~width: string,
  ) => React.element = "default"
}

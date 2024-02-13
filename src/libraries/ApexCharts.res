type zoom = {enabled: bool}

type chart = {
  height?: int,
  zoom?: zoom,
}

type dataLabels = {enabled?: bool}

type stroke = {curve: string}
type title = {
  text?: string,
  align?: string,
}

type options = {
  chart?: chart,
  dataLabels: dataLabels,
  stroke?: stroke,
  labels?: array<string>,
  title?: title,
}

type objPoints = {
  name?: string,
  \"type"?: string,
  data: array<int>,
}

let intArrToJson = arr => {
  arr->Array.map(Js.Json.number)
}

external userObjToJson: objPoints => JSON.t = "%identity"

let objToJson = (arr: array<objPoints>) => {
  arr->Array.map(userObjToJson)
}

module ReactApexChart = {
  @module("react-apexcharts") @react.component
  external make: (~options: options, ~series: array<Js.Json.t>, ~\"type": string) => React.element =
    "default"
}

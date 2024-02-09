type zoom = {enabled: bool}

type chart = {
  height: int,
  \"type": string,
  zoom: zoom,
}

type dataLabels = {enabled: bool}

type stroke = {curve: string}
type title = {
  text: string,
  align: string,
}

type options = {
  chart: chart,
  dataLabels: dataLabels,
  stroke: stroke,
  title: title,
}

type series = {
  name: string,
  data: array<int>,
}

module ReactApexChart = {
  @module("react-apexcharts") @react.component
  external make: (
    ~options: options,
    ~series: array<series>,
    ~\"type": string,
    ~height: float,
  ) => React.element = "default"
}

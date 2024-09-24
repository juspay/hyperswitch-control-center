type \"type" = string
type spacingLeft = int
type spacingRight = int

type categories = array<string>
type crosshair = bool
type barWidth = int
type align = string
type color = string
type gridLineWidth = int
type gridLineColor = string
type gridLineDashStyle = string
type tickmarkPlacement = string
type endOnTick = bool
type startOnTick = bool
type min = int
type showInLegend = bool
type name = string

type title = {text: string}
type style = {color: color}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}
type exporting = {
  ...enabled,
}
type marker = {
  ...enabled,
}
type bar = {marker: marker}
type plotOptions = {bar: bar}
type labels = {
  align: align,
  style: style,
}
type chart = {
  \"type": \"type",
  spacingLeft: spacingLeft,
  spacingRight: spacingRight,
}

type dataObj = {
  showInLegend: showInLegend,
  name: name,
  data: array<int>,
  color: color,
}

type data = array<dataObj>

type yAxis = {
  title: title,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  gridLineDashStyle: gridLineDashStyle,
  tickmarkPlacement: tickmarkPlacement,
  endOnTick: endOnTick,
  startOnTick: startOnTick,
  min: min,
}

type xAxis = {
  categories: categories,
  crosshair: crosshair,
  barWidth: barWidth,
  labels: labels,
  gridLineDashStyle: gridLineDashStyle,
}

type barGraphOptions = {
  chart: chart,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  plotOptions: plotOptions,
  series: data,
  credits: credits,
}

type barGraphPayload = {categories: categories, data: data, title: title}

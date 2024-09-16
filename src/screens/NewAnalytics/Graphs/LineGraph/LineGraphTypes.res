type \"type" = string
type spacingLeft = int
type spacingRight = int

type categories = array<string>
type crosshair = bool
type lineWidth = int
type tickWidth = int
type align = string
type color = string
type y = int
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
type line = {marker: marker}
type plotOptions = {line: line}
type labels = {
  align: align,
  style: style,
  y: y,
}
type chart = {
  \"type": \"type",
  spacingLeft: spacingLeft,
  spacingRight: spacingRight,
}
type data = {
  showInLegend: showInLegend,
  name: name,
  data: array<int>,
  color: color,
}

type yAxis = {
  title: title,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  gridLineDashStyle: gridLineDashStyle,
  min: min,
}

type xAxis = {
  categories: categories,
  crosshair: crosshair,
  lineWidth: lineWidth,
  tickWidth: tickWidth,
  labels: labels,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  tickmarkPlacement: tickmarkPlacement,
  endOnTick: endOnTick,
  startOnTick: startOnTick,
}

type lineGraphOptions = {
  chart: chart,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  plotOptions: plotOptions,
  series: data,
  credits: credits,
}

type lineGraphPayload = {categories: categories, data: data, title: title}

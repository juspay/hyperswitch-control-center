type \"type" = string
type spacingLeft = int
type spacingRight = int

type categories = array<string>
type align = string
type color = string
type gridLineWidth = int
type gridLineColor = string
type gridLineDashStyle = string
type tickmarkPlacement = string
type endOnTick = bool
type startOnTick = bool
type tickInterval = int
type tickWidth = int
type min = int
type max = int
type showInLegend = bool
type name = string

type title = {text: string}
type style = {color: color}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}
type marker = {
  ...enabled,
}
type pointPadding = float
type bar = {marker: marker, pointPadding: pointPadding}
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
  tickInterval: tickInterval,
  min: min,
  max: max,
}

type xAxis = {
  categories: categories,
  labels: labels,
  tickWidth: tickWidth,
  tickmarkPlacement: tickmarkPlacement,
  endOnTick: endOnTick,
  startOnTick: startOnTick,
  gridLineDashStyle: gridLineDashStyle,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  min: min,
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

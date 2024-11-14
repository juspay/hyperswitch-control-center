type temp = {name: int}
type options = {dataLabels: temp}
type point = {sum: string, id: string, options: options}
type nodeFormatter = {point: point}

external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => nodeFormatter => string = "%identity"

type enabled = {enabled: bool}
type exporting = {
  ...enabled,
}
type credits = {...enabled}
type colors = array<string>
type keys = array<string>
type sankeyGraphData = (string, string, int, string)
type data = array<sankeyGraphData>
type \"type" = string
type name = string
type nodePadding = int
type borderRadius = int
type fontWeight = string
type fontSize = string
type color = string
type allowOverlap = bool
type crop = bool
type overflow = string
type align = string
type verticalAlign = string
type x = int
type nodeDataLabels = {
  align: align,
  x: x,
  name: int,
}

type node = {
  id: string,
  dataLabels: nodeDataLabels,
}
type style = {
  fontWeight: fontWeight,
  fontSize: fontSize,
  color: color,
}
type dataLabels = {
  style: style,
  allowOverlap: allowOverlap,
  crop: crop,
  overflow: overflow,
  align: align,
  verticalAlign: verticalAlign,
  nodeFormatter: nodeFormatter => string,
}
type nodes = array<node>
type chart = {
  spacingLeft: int,
  spacingRight: int,
}
type series = {
  exporting: exporting,
  credits: credits,
  colors: colors,
  keys: keys,
  data: data,
  \"type": \"type",
  nodePadding: nodePadding,
  borderRadius: borderRadius,
  dataLabels: dataLabels,
  nodes: nodes,
}

type title = {text: string}
type sankeyGraphOptions = {title: title, series: array<series>, chart: chart, credits: credits}

type sankeyPayload = {
  title: title,
  data: data,
  nodes: nodes,
  colors: colors,
}

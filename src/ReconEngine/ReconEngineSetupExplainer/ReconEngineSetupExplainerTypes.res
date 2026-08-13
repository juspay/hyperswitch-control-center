type explainerNodeKind =
  | IngestionNode
  | TransformationNode
  | AccountNode
  | RuleNode

type explainerNodeData = {
  kind: explainerNodeKind,
  label: string,
  description: string,
  badgeText: string,
  isActive: bool,
  showStatus: bool,
  onNodeClick: option<unit => unit>,
}

type nodePositionType = {
  x: float,
  y: float,
}

type nodeType = {
  id: string,
  @as("type") nodeType: string,
  position: nodePositionType,
  data: explainerNodeData,
}

type edgeStyleType = {
  stroke: string,
  strokeWidth: float,
}

type edgeMarkerType = {@as("type") edgeMarkerType: string}

type edgePathOptionsType = {
  offset: float,
  borderRadius: float,
}

type edgeType = {
  id: string,
  source: string,
  target: string,
  @as("type") edgeType: string,
  label?: string,
  animated?: bool,
  markerEnd?: edgeMarkerType,
  style?: edgeStyleType,
  pathOptions?: edgePathOptionsType,
}

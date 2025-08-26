// CSS import
%%raw(`import '@xyflow/react/dist/style.css'`)

@module("@xyflow/react") external useNodesState: array<'a> => (array<'a>, 'b, 'c) = "useNodesState"
@module("@xyflow/react") external useEdgesState: array<'a> => (array<'a>, 'b, 'c) = "useEdgesState"
@module("@xyflow/react") external useReactFlow: unit => {..} = "useReactFlow"
@module("@xyflow/react") external handle: React.component<'a> = "Handle"

@module("@xyflow/react") @scope("MarkerType") external markerTypeArrowClosed: string = "ArrowClosed"
@module("@xyflow/react") @scope("Position") external positionLeft: string = "Left"
@module("@xyflow/react") @scope("Position") external positionRight: string = "Right"

type dagreGraph

@module("@dagrejs/dagre") @scope("graphlib") @new external createGraph: unit => dagreGraph = "Graph"

type graphConfig = {
  rankdir: string,
  nodesep: int,
  ranksep: int,
}

@send external setDefaultEdgeLabel: (dagreGraph, unit => {..}) => unit = "setDefaultEdgeLabel"
@send external setGraph: (dagreGraph, graphConfig) => unit = "setGraph"
@send external setEdge: (dagreGraph, string, string) => unit = "setEdge"
@send external setNode: (dagreGraph, string, 'a) => unit = "setNode"
@send external getNode: (dagreGraph, string) => 'a = "node"

// Dagre layout function
@module("@dagrejs/dagre") external layout: dagreGraph => unit = "layout"

let createDagreGraph = () => {
  let graph = createGraph()
  setDefaultEdgeLabel(graph, () => Js.Obj.empty())
  graph
}

let setGraphDirection = (graph, direction) => {
  setGraph(
    graph,
    {
      rankdir: direction,
      nodesep: 100,
      ranksep: 150,
    },
  )
}

let setGraphEdge = (graph, source, target) => {
  setEdge(graph, source, target)
}

let setGraphNode = (graph, nodeId, nodeData) => {
  setNode(graph, nodeId, nodeData)
}

let layoutGraph = graph => {
  layout(graph)
}

let getGraphNode = (graph, nodeId) => {
  getNode(graph, nodeId)
}

module ReactFlowComponent = {
  @react.component @module("@xyflow/react")
  external make: (
    ~nodes: array<'a>,
    ~edges: array<'b>,
    ~nodeTypes: 'c,
    ~onNodesChange: 'd,
    ~onEdgesChange: 'e,
    ~fitView: bool=?,
    ~fitViewOptions: 'f=?,
    ~nodesDraggable: bool=?,
    ~nodesConnectable: bool=?,
    ~elementsSelectable: bool=?,
    ~panOnDrag: bool=?,
    ~translateExtent: array<array<float>>=?,
    ~zoomOnScroll: bool=?,
    ~zoomOnPinch: bool=?,
    ~zoomOnDoubleClick: bool=?,
    ~minZoom: float=?,
    ~maxZoom: float=?,
    ~defaultViewport: 'h=?,
    ~proOptions: 'g=?,
    ~children: React.element=?,
  ) => React.element = "ReactFlow"
}

module Background = {
  @react.component @module("@xyflow/react")
  external make: (~variant: string=?, ~gap: int=?, ~size: int=?) => React.element = "Background"
}

module Controls = {
  @react.component @module("@xyflow/react")
  external make: (
    ~showZoom: bool=?,
    ~showFitView: bool=?,
    ~showInteractive: bool=?,
  ) => React.element = "Controls"
}

module Panel = {
  @react.component @module("@xyflow/react")
  external make: (~position: string=?, ~children: React.element=?) => React.element = "Panel"
}

module ReactFlowProvider = {
  @react.component @module("@xyflow/react")
  external make: (~children: React.element=?) => React.element = "ReactFlowProvider"
}

// Handle component wrapper
module HandleComponent = {
  @react.component @module("@xyflow/react")
  external make: (
    ~\"type": string,
    ~position: string,
    ~style: ReactDOM.Style.t=?,
  ) => React.element = "Handle"
}

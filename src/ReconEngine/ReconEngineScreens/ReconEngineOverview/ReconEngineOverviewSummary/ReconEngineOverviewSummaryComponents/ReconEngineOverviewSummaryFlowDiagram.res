open Typography
open ReconEngineOverviewSummaryTypes
open LogicUtils

module InOutComponent = {
  @react.component
  let make = (~statusItem) => {
    open ReconEngineOverviewSummaryUtils
    open ReconEngineOverviewSummaryHelper

    let (iconName, iconColor) = getStatusIcon(statusItem.statusType)

    <div
      key={(statusItem.statusType :> string)}
      className="bg-nd_gray-25 border rounded-xl border-nd_gray-150 mt-2.5 p-2">
      <div className="flex flex-row items-center">
        <div className="flex flex-row items-center gap-1.5 flex-[1]">
          <Icon name={iconName} className={iconColor} size=12 />
          <p className={`${body.sm.medium} text-nd_gray-500`}>
            {(statusItem.statusType :> string)->React.string}
          </p>
        </div>
        <div className="flex flex-row flex-[1] justify-between items-center">
          <div className="flex flex-1 flex-col items-center justify-center">
            <p className={`${body.md.semibold} text-nd_gray-600`}>
              <AmountCell
                value={Math.abs(statusItem.reconStatusData.inAmount.value)}
                currency={statusItem.reconStatusData.inAmount.currency}
              />
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              <NumberCell value={statusItem.reconStatusData.inTxns} />
            </p>
          </div>
          <div className="flex flex-1 flex-col items-center justify-center">
            <p className={`${body.md.semibold} text-nd_gray-600`}>
              <AmountCell
                value={Math.abs(statusItem.reconStatusData.outAmount.value)}
                currency={statusItem.reconStatusData.outAmount.currency}
              />
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              <NumberCell value={statusItem.reconStatusData.outTxns} />
            </p>
          </div>
        </div>
      </div>
    </div>
  }
}

module ReconNodeComponent = {
  @react.component
  let make = (~data: nodeData) => {
    open ReactFlow

    let borderColor = data.selected ? "border-blue-500" : "border-nd_gray-200"

    let onClick = () => {
      switch data.onNodeClick {
      | Some(clickHandler) => clickHandler()
      | None => ()
      }
    }

    <div
      className={`flex flex-col rounded-xl border ${borderColor} p-4 relative bg-white w-440-px cursor-pointer`}
      onClick={_ => onClick()}>
      <HandleComponent \"type"="target" position={positionLeft} />
      <HandleComponent \"type"="source" position={positionRight} />
      <div className="absolute -top-0 -left-0">
        <div
          className={`${body.xs.medium} text-nd_gray-600 bg-nd_gray-100 px-3 py-1 rounded-tl-xl border border-t-0 border-l-0 border-nd_gray-200 rounded-br-xl `}>
          {`${(data.accountType :> string)->capitalizeString} Account`->React.string}
        </div>
      </div>
      <div className="flex flex-row items-center border-b pb-2.5 pt-6">
        <div className="flex flex-row items-center gap-2 flex-[1]">
          <p className={`${body.md.semibold} text-nd_gray-800`}> {data.label->React.string} </p>
        </div>
        <div className="flex flex-row flex-[1] justify-between items-center">
          <div className="flex flex-1 justify-center">
            <p className={`${body.xs.medium} text-nd_gray-400`}> {"DEBIT"->React.string} </p>
          </div>
          <div className="flex flex-1 justify-center">
            <p className={`${body.xs.medium} text-nd_gray-400`}> {"CREDIT"->React.string} </p>
          </div>
        </div>
      </div>
      <div className="flex flex-col">
        {data.statusData
        ->Array.map(statusItem => <InOutComponent statusItem key={randomString(~length=10)} />)
        ->React.array}
      </div>
    </div>
  }
}

module ReconEdgeComponent = {
  @react.component
  let make = (
    ~sourceX: float,
    ~sourceY: float,
    ~sourcePosition: string,
    ~targetX: float,
    ~targetY: float,
    ~targetPosition: string,
    ~data: edgeData,
    ~markerEnd: option<string>=?,
    ~style: option<ReactDOM.Style.t>=?,
  ) => {
    let (edgePath, labelX, labelY, _, _) = ReactFlow.getSmoothStepPath({
      sourceX,
      sourceY,
      sourcePosition,
      targetX,
      targetY,
      targetPosition,
    })

    <>
      <ReactFlow.BaseEdge path=edgePath ?markerEnd ?style />
      <ReactFlow.EdgeLabelRenderer>
        <div
          className="nodrag nopan absolute -translate-x-1/2 -translate-y-1/2 w-52 rounded-lg border border-nd_gray-200 bg-white px-2.5 py-1.5 text-center shadow-sm"
          style={ReactDOM.Style.make(
            ~left=`${labelX->Float.toString}px`,
            ~top=`${labelY->Float.toString}px`,
            (),
          )}>
          <p className={`break-words ${body.xs.medium} text-nd_gray-500`}>
            {data.ruleType->React.string}
          </p>
          <p className={`mt-0.5 ${body.sm.semibold} text-blue-600`}>
            {data.percentageLabel->React.string}
          </p>
        </div>
      </ReactFlow.EdgeLabelRenderer>
    </>
  }
}

module FlowWithLayoutControls = {
  @react.component
  let make = (~nodes, ~edges, ~onNodesChange, ~onEdgesChange, ~isFullscreen, ~toggleFullscreen) => {
    open ReactFlow

    let reactFlow = useReactFlow()

    React.useEffect(() => {
      let timeoutId = setTimeout(() => reactFlow.fitView()->ignore, 0)
      Some(() => clearTimeout(timeoutId))
    }, [isFullscreen])

    let fullscreenLabel = isFullscreen ? "Exit fullscreen" : "Enter fullscreen"

    <ReactFlowComponent
      nodes={nodes}
      edges={edges}
      nodeTypes={{"reconNode": ReconNodeComponent.make}}
      edgeTypes={{"reconEdge": ReconEdgeComponent.make}}
      onNodesChange={onNodesChange}
      onEdgesChange={onEdgesChange}
      fitView={true}
      fitViewOptions={{"padding": 0.1}}
      nodesDraggable={true}
      nodesConnectable={false}
      elementsSelectable={true}
      panOnDrag={true}
      zoomOnScroll={true}
      zoomOnPinch={true}
      zoomOnDoubleClick={true}
      minZoom={0.5}
      maxZoom={1.5}
      proOptions={{"hideAttribution": true}}>
      <Background variant="dots" gap={20} size={1} />
      <Controls showZoom={true} showFitView={true} showInteractive={true} />
      <Panel position="top-right">
        <div
          className="flex items-center gap-1.5 px-2 py-1 rounded-md bg-white border border-nd_gray-200 shadow-sm cursor-pointer"
          title=fullscreenLabel
          onClick={_ => toggleFullscreen()}>
          <Icon name={isFullscreen ? "compress-alt" : "expand-alt"} size=13 />
          <p className={`${body.sm.semibold} text-nd_gray-500`}>
            {fullscreenLabel->React.string}
          </p>
        </div>
      </Panel>
    </ReactFlowComponent>
  }
}

@react.component
let make = (~reconRulesList: array<ReconEngineRulesTypes.rulePayload>) => {
  open ReconEngineOverviewSummaryUtils
  open ReactFlow

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (selectedNodeId, setSelectedNodeId) = React.useState(_ => None)
  let (allData, setAllData) = React.useState(_ => None)
  let getRuleAccountBreakdown = ReconEngineHooks.useGetRuleAccountBreakdown()
  let (reactFlowNodes, setNodes, onNodesChange) = useNodesState([])
  let (reactFlowEdges, setEdges, onEdgesChange) = useEdgesState([])
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let graphContainerRef = React.useRef(Nullable.null)
  let (isFullscreen, setIsFullscreen) = React.useState(_ => false)

  let syncFullscreenState = _ => {
    let isGraphFullscreen = switch (
      Webapi.Dom.document->Document.Fullscreen.getElement,
      graphContainerRef.current->Nullable.toOption,
    ) {
    | (Some(fullscreenElement), Some(graphElement)) => fullscreenElement === graphElement
    | _ => false
    }
    setIsFullscreen(_ => isGraphFullscreen)
  }

  let toggleFullscreen = () => {
    let fullscreenAction = switch Webapi.Dom.document->Document.Fullscreen.getElement {
    | Some(_) => Webapi.Dom.document->Document.Fullscreen.exit
    | None =>
      switch graphContainerRef.current->Nullable.toOption {
      | Some(graphElement) => graphElement->Document.Fullscreen.request
      | None => Promise.resolve()
      }
    }
    fullscreenAction->Promise.catch(_ => Promise.resolve())->ignore
  }

  React.useEffect(() => {
    Webapi.Dom.document->Webapi.Dom.Document.addEventListener(
      "fullscreenchange",
      syncFullscreenState,
    )
    Some(
      () =>
        Webapi.Dom.document->Webapi.Dom.Document.removeEventListener(
          "fullscreenchange",
          syncFullscreenState,
        ),
    )
  }, [])

  let handleNodeClick = (nodeId: string) => {
    setSelectedNodeId(prev => {
      switch prev {
      | Some(id) if id === nodeId => None
      | _ => Some(nodeId)
      }
    })
  }

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)

      let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
      let ruleAccountsOverview = await getRuleAccountBreakdown(~queryParameters=Some(queryString))

      setAllData(_ => Some(ruleAccountsOverview))

      let (nodes, edges) = generateNodesAndEdgesWithTransactionAmounts(
        reconRulesList,
        ruleAccountsOverview,
        ~selectedNodeId,
        ~onNodeClick=handleNodeClick,
      )

      if nodes->Array.length > 0 && edges->Array.length > 0 {
        setNodes(_ => nodes)->ignore
        setEdges(_ => edges)->ignore
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      getAccountsData()->ignore
    }
    None
  }, [filterValue])

  React.useEffect(() => {
    switch allData {
    | Some(ruleAccountsOverview) => {
        let (nodes, edges) = generateNodesAndEdgesWithTransactionAmounts(
          reconRulesList,
          ruleAccountsOverview,
          ~selectedNodeId,
          ~onNodeClick=handleNodeClick,
        )
        if nodes->Array.length > 0 && edges->Array.length > 0 {
          setNodes(_ => nodes)->ignore
          setEdges(_ => edges)->ignore
        }
      }
    | None => ()
    }
    None
  }, [selectedNodeId])

  let fullScreenClass = isFullscreen ? "h-screen w-screen" : "h-30-rem w-full"

  <div
    ref={graphContainerRef->ReactDOM.Ref.domRef}
    className={`border rounded-xl border-nd_gray-200 overflow-auto bg-white ${fullScreenClass}`}>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-30-rem" message="No data available." />}
      customLoader={<Shimmer styleClass="h-30-rem w-full rounded-b-xl" />}>
      <div className="h-full overflow-hidden">
        <ReactFlowProvider>
          <FlowWithLayoutControls
            nodes={reactFlowNodes}
            edges={reactFlowEdges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            isFullscreen
            toggleFullscreen
          />
        </ReactFlowProvider>
      </div>
    </PageLoaderWrapper>
  </div>
}

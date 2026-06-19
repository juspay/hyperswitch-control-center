open Typography
open ReconEngineOverviewSummaryTypes
open LogicUtils

module InOutComponent = {
  @react.component
  let make = (~statusItem: reconStatusData) => {
    let (iconName, iconColor) = ReconEngineOverviewSummaryUtils.getStatusIcon(statusItem.statusType)

    <div className="bg-nd_gray-25 border rounded-xl border-nd_gray-150 mt-2.5 p-2">
      <div className="flex flex-row items-center">
        <div className="flex flex-row items-center gap-1.5 flex-[1]">
          <Icon name={iconName} className={iconColor} size=12 />
          <p className={`${body.sm.medium} text-nd_gray-500`}>
            {(statusItem.statusType :> string)->React.string}
          </p>
        </div>
        <div className="flex flex-row flex-[1] justify-between items-center">
          <div className="flex flex-1 flex-col items-center justify-center">
            <p className={`${body.md.semibold} text-nd_gray-600 whitespace-nowrap`}>
              {statusItem.reconStatusData.inAmount->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400 whitespace-nowrap`}>
              {statusItem.reconStatusData.inTxns->React.string}
            </p>
          </div>
          <div className="flex flex-1 flex-col items-center justify-center">
            <p className={`${body.md.semibold} text-nd_gray-600 whitespace-nowrap`}>
              {statusItem.reconStatusData.outAmount->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400 whitespace-nowrap`}>
              {statusItem.reconStatusData.outTxns->React.string}
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

    let onClick = () =>
      switch data.onNodeClick {
      | Some(f) => f()
      | None => ()
      }

    <div
      className={`flex flex-col rounded-xl border ${borderColor} p-4 relative bg-white w-[520px] cursor-pointer`}
      onClick={_ => onClick()}>
      <HandleComponent \"type"="target" position={positionLeft} />
      <HandleComponent \"type"="source" position={positionRight} />
      <div className="absolute -top-0 -left-0">
        <div
          className={`${body.xs.medium} text-nd_gray-600 bg-nd_gray-100 px-3 py-1 rounded-tl-xl border border-t-0 border-l-0 border-nd_gray-200 rounded-br-xl`}>
          {switch data.accountType {
          | ReconEngineTypes.UnknownAccountTypeVariant => "Account"
          | t => `${(t :> string)->LogicUtils.capitalizeString} Account`
          }->React.string}
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
        ->Array.map(statusItem =>
          <InOutComponent statusItem key={(statusItem.statusType :> string)} />
        )
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
      let id = setTimeout(() => reactFlow.fitView()->ignore, 0)
      Some(() => clearTimeout(id))
    }, [isFullscreen])

    let label = isFullscreen ? "Exit fullscreen" : "Enter fullscreen"

    <ReactFlowComponent
      nodes
      edges
      nodeTypes={{"reconNode": ReconNodeComponent.make}}
      edgeTypes={{"reconEdge": ReconEdgeComponent.make}}
      onNodesChange
      onEdgesChange
      fitView=true
      fitViewOptions={{"padding": 0.1}}
      nodesDraggable=true
      nodesConnectable=false
      elementsSelectable=true
      panOnDrag=true
      zoomOnScroll=true
      zoomOnPinch=true
      zoomOnDoubleClick=true
      minZoom=0.5
      maxZoom=1.5
      proOptions={{"hideAttribution": true}}>
      <Background variant="dots" gap={20} size={1} />
      <Controls showZoom=true showFitView=true showInteractive=true />
      <Panel position="top-right">
        <div
          className="flex items-center gap-1.5 px-2 py-1 rounded-md bg-white border border-nd_gray-200 shadow-sm cursor-pointer"
          title=label
          onClick={_ => toggleFullscreen()}>
          <Icon name={isFullscreen ? "compress-alt" : "expand-alt"} size=13 />
          <p className={`${body.sm.semibold} text-nd_gray-500`}> {label->React.string} </p>
        </div>
      </Panel>
    </ReactFlowComponent>
  }
}

// ─── Data helpers ──────────────────────────────────────────────────────────

let formatAmount = (v: float, currency: string) => {
  if v == 0.0 {
    "—"
  } else {
    open CurrencyFormatUtils
    `${currency} ${valueFormatter(v, Amount)}`
  }
}

let formatCount = (n: int) => {
  open CurrencyFormatUtils
  `${valueFormatter(n->Int.toFloat, Volume)} txns`
}

let buildStatusData = (entry: ReconEngineRevampedOverviewTypes.overviewAccountEntry): array<
  reconStatusData,
> => {
  let sc = entry.status_counts
  let sa = entry.status_amounts
  let curr = sa.currency

  let matchedTotal = sc.matched
  let pendingTotal = sc.pending + sc.expected
  let mismatchedTotal = sc.mismatched

  [
    {
      statusType: MatchedAmount,
      reconStatusData: {
        inAmount: formatAmount(sa.matched_debit, curr),
        outAmount: formatAmount(sa.matched_credit, curr),
        inTxns: formatCount(matchedTotal),
        outTxns: formatCount(matchedTotal),
      },
    },
    {
      statusType: PendingAmount,
      reconStatusData: {
        inAmount: formatAmount(sa.pending_debit, curr),
        outAmount: formatAmount(sa.pending_credit, curr),
        inTxns: formatCount(pendingTotal),
        outTxns: formatCount(pendingTotal),
      },
    },
    {
      statusType: MismatchedAmount,
      reconStatusData: {
        inAmount: formatAmount(sa.mismatched_debit, curr),
        outAmount: formatAmount(sa.mismatched_credit, curr),
        inTxns: formatCount(mismatchedTotal),
        outTxns: formatCount(mismatchedTotal),
      },
    },
  ]
}

let buildEdges = (
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  ~accountMap: Dict.t<ReconEngineRevampedOverviewTypes.overviewAccountEntry>,
  ~selectedNodeId: option<string>,
) =>
  reconRulesList->Array.flatMap(rule => {
    open ReconEngineRulesTypes
    open ReconEngineOverviewSummaryUtils

    let getMatchRate = (srcId, tgtId) => {
      let srcEntry = accountMap->Dict.get(srcId)
      let tgtEntry = accountMap->Dict.get(tgtId)
      let matched =
        srcEntry->Option.map(e => e.status_counts.matched)->Option.getOr(0) +
          tgtEntry->Option.map(e => e.status_counts.matched)->Option.getOr(0)
      let total =
        srcEntry
        ->Option.map(e =>
          e.status_counts.matched +
          e.status_counts.mismatched +
          e.status_counts.pending +
          e.status_counts.expected
        )
        ->Option.getOr(0) +
          tgtEntry
          ->Option.map(e =>
            e.status_counts.matched +
            e.status_counts.mismatched +
            e.status_counts.pending +
            e.status_counts.expected
          )
          ->Option.getOr(0)
      let rate = total > 0 ? matched->Int.toFloat /. total->Int.toFloat *. 100.0 : 0.0
      `${rate->Float.toFixedWithPrecision(~digits=1)}% Matched`
    }

    let makeEdge = (~srcId, ~tgtId) => {
      let srcNode = `${srcId}-node`
      let tgtNode = `${tgtId}-node`
      let highlighted = Some(srcNode) == selectedNodeId || Some(tgtNode) == selectedNodeId
      {
        id: `${rule.rule_id}-${srcId}-${tgtId}`,
        ReconEngineOverviewSummaryTypes.source: srcNode,
        target: tgtNode,
        edgeType: "reconEdge",
        animated: highlighted,
        markerEnd: {edgeMarkerType: ReactFlow.markerTypeArrowClosed},
        data: {
          ruleType: getCompactRuleType(rule.strategy),
          percentageLabel: getMatchRate(srcId, tgtId),
        },
        style: highlighted
          ? {stroke: "#3b82f6", strokeWidth: 2.0}
          : {stroke: "#6b7280", strokeWidth: 2.0},
      }
    }

    switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(d) => [
          makeEdge(~srcId=d.source_account.account_id, ~tgtId=d.target_account.account_id),
        ]
      | SingleMany(d) => [
          makeEdge(~srcId=d.source_account.account_id, ~tgtId=d.target_account.account_id),
        ]
      | ManySingle(d) => [
          makeEdge(~srcId=d.source_account.account_id, ~tgtId=d.target_account.account_id),
        ]
      | ManyMany(d) => [
          makeEdge(~srcId=d.source_account.account_id, ~tgtId=d.target_account.account_id),
        ]
      | UnknownOneToOneStrategy => []
      }
    | OneToMany(oneToMany) =>
      switch oneToMany {
      | SingleSingle(d) => {
          let targets = switch d.target_accounts {
          | Percentage({targets}) | Fixed({targets}) => targets
          | UnknownTargetsType => []
          }
          targets->Array.map(((t, _)) =>
            makeEdge(~srcId=d.source_account.account_id, ~tgtId=t.account_id)
          )
        }
      | UnknownOneToManyStrategy => []
      }
    | UnknownReconStrategy => []
    }
  })

let layoutElements = (
  nodes: array<ReconEngineOverviewSummaryTypes.nodeType>,
  edges: array<ReconEngineOverviewSummaryTypes.edgeType>,
) => {
  let graph = ReactFlow.createDagreGraph()
  ReactFlow.setGraphDirection(graph, "LR")
  edges->Array.forEach(e =>
    ReactFlow.setGraphEdge(
      graph,
      e.ReconEngineOverviewSummaryTypes.source,
      e.ReconEngineOverviewSummaryTypes.target,
    )
  )
  nodes->Array.forEach(n =>
    ReactFlow.setGraphNode(graph, n.id, {ReactFlow.width: 560.0, height: 420.0})
  )
  ReactFlow.layoutGraph(graph)->ignore
  let layouted = nodes->Array.map(n => {
    let pos = ReactFlow.getGraphNode(graph, n.id)
    {...n, ReconEngineOverviewSummaryTypes.position: {x: pos.x -. 280.0, y: pos.y -. 210.0}}
  })
  (layouted, edges)
}

// ─── Main component ────────────────────────────────────────────────────────

@react.component
let make = () => {
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=180)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)
  let endTime =
    filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, defaultDateRange.end_time)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (allData, setAllData) = React.useState(_ => None)
  let (selectedNodeId, setSelectedNodeId) = React.useState(_ => None)
  let (reactFlowNodes, setNodes, onNodesChange) = ReactFlow.useNodesState([])
  let (reactFlowEdges, setEdges, onEdgesChange) = ReactFlow.useEdgesState([])
  let graphContainerRef = React.useRef(Nullable.null)
  let (isFullscreen, setIsFullscreen) = React.useState(_ => false)

  let syncFullscreen = _ => {
    let isFs = switch (
      Webapi.Dom.document->Document.Fullscreen.getElement,
      graphContainerRef.current->Nullable.toOption,
    ) {
    | (Some(el), Some(container)) => el === container
    | _ => false
    }
    setIsFullscreen(_ => isFs)
  }

  let toggleFullscreen = () => {
    let action = switch Webapi.Dom.document->Document.Fullscreen.getElement {
    | Some(_) => Webapi.Dom.document->Document.Fullscreen.exit
    | None =>
      switch graphContainerRef.current->Nullable.toOption {
      | Some(el) => el->Document.Fullscreen.request
      | None => Promise.resolve()
      }
    }
    action->Promise.catch(_ => Promise.resolve())->ignore
  }

  React.useEffect(() => {
    Webapi.Dom.document->Webapi.Dom.Document.addEventListener("fullscreenchange", syncFullscreen)
    Some(
      () =>
        Webapi.Dom.document->Webapi.Dom.Document.removeEventListener(
          "fullscreenchange",
          syncFullscreen,
        ),
    )
  }, [])

  let handleNodeClick = (nodeId: string) =>
    setSelectedNodeId(prev =>
      switch prev {
      | Some(id) if id === nodeId => None
      | _ => Some(nodeId)
      }
    )

  let buildGraph = (
    reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
    accountMap: Dict.t<ReconEngineRevampedOverviewTypes.overviewAccountEntry>,
    ~selectedNodeId: option<string>,
  ) => {
    let accountIds = ReconEngineOverviewSummaryUtils.getAllAccountIds(reconRulesList)

    let nodes = accountIds->Array.mapWithIndex((accountId, i) => {
      let entry = accountMap->Dict.get(accountId)
      let label = entry->Option.map(e => e.account_name)->Option.getOr(accountId)
      let statusData = switch entry {
      | Some(e) => buildStatusData(e)
      | None =>
        ReconEngineOverviewSummaryUtils.generateStatusDataWithTransactionAmounts(
          Dict.make()->ReconEngineOverviewSummaryUtils.accountTransactionDataToObjMapper,
        )
      }
      let nodeId = `${accountId}-node`
      {
        id: nodeId,
        ReconEngineOverviewSummaryTypes.nodeType: "reconNode",
        position: {x: Int.toFloat(i * 100), y: 0.0},
        data: {
          label,
          accountType: entry
          ->Option.map(e => ReconEngineUtils.getAccountTypeVariantFromString(e.account_type))
          ->Option.getOr(ReconEngineTypes.UnknownAccountTypeVariant),
          statusData,
          selected: Some(nodeId) == selectedNodeId,
          onNodeClick: Some(() => handleNodeClick(nodeId)),
        },
      }
    })

    let edges = buildEdges(~reconRulesList, ~accountMap, ~selectedNodeId)
    layoutElements(nodes, edges)
  }

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)

      let rulesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#RECON_RULES,
        ~methodType=Get,
      )
      let accountsUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_ACCOUNTS,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )

      let results = await Promise.all([fetchDetails(rulesUrl), fetchDetails(accountsUrl)])

      let reconRulesList =
        results
        ->Array.get(0)
        ->Option.getExn
        ->getArrayDataFromJson(ReconEngineRulesUtils.ruleItemToObjMapper)

      let accountEntries =
        results
        ->Array.get(1)
        ->Option.getExn
        ->getArrayDataFromJson(ReconEngineRevampedOverviewUtils.overviewAccountEntryMapper)

      let accountMap: Dict.t<ReconEngineRevampedOverviewTypes.overviewAccountEntry> = Dict.make()
      accountEntries->Array.forEach(e => Dict.set(accountMap, e.account_id, e))

      setAllData(_ => Some((reconRulesList, accountMap)))

      let (nodes, edges) = buildGraph(reconRulesList, accountMap, ~selectedNodeId)
      if nodes->Array.length > 0 {
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
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  React.useEffect(() => {
    switch allData {
    | Some((reconRulesList, accountMap)) => {
        let (nodes, edges) = buildGraph(reconRulesList, accountMap, ~selectedNodeId)
        if nodes->Array.length > 0 {
          setNodes(_ => nodes)->ignore
          setEdges(_ => edges)->ignore
        }
      }
    | None => ()
    }
    None
  }, [selectedNodeId])

  let containerClass = isFullscreen ? "h-screen w-screen" : "h-[800px] w-full"

  <div
    ref={graphContainerRef->ReactDOM.Ref.domRef}
    className={`border rounded-xl border-nd_gray-200 overflow-auto bg-white ${containerClass}`}>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-[800px]" message="No data available." />}
      customLoader={<Shimmer styleClass="h-[800px] w-full rounded-b-xl" />}>
      <div className="h-full overflow-hidden">
        <ReactFlow.ReactFlowProvider>
          <FlowWithLayoutControls
            nodes={reactFlowNodes}
            edges={reactFlowEdges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            isFullscreen
            toggleFullscreen
          />
        </ReactFlow.ReactFlowProvider>
      </div>
    </PageLoaderWrapper>
  </div>
}

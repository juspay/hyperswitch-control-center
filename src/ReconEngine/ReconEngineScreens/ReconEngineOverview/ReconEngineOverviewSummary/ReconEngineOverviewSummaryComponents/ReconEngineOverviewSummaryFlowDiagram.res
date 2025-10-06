open Typography
open ReconEngineOverviewSummaryTypes

module InOutComponent = {
  @react.component
  let make = (~statusItem) => {
    open ReconEngineOverviewSummaryUtils

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
              {statusItem.data.inAmount->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {statusItem.data.inTxns->React.string}
            </p>
          </div>
          <div className="flex flex-1 flex-col items-center justify-center">
            <p className={`${body.md.semibold} text-nd_gray-600`}>
              {statusItem.data.outAmount->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {statusItem.data.outTxns->React.string}
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
      className={`flex flex-col rounded-xl border ${borderColor} p-4 relative bg-white w-[400px] cursor-pointer`}
      onClick={_ => onClick()}>
      <HandleComponent \"type"="target" position={positionLeft} />
      <HandleComponent \"type"="source" position={positionRight} />
      <div className="absolute -top-0 -left-0">
        <div
          className={`${body.xs.medium} text-nd_gray-600 bg-nd_gray-100 px-3 py-1 rounded-tl-xl border border-t-0 border-l-0 border-nd_gray-200 rounded-br-xl `}>
          {`${data.accountType->LogicUtils.capitalizeString} Account`->React.string}
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
          <InOutComponent statusItem key={LogicUtils.randomString(~length=10)} />
        )
        ->React.array}
      </div>
    </div>
  }
}

module FlowWithLayoutControls = {
  @react.component
  let make = (~nodes, ~edges, ~onNodesChange, ~onEdgesChange) => {
    open ReactFlow

    <ReactFlowComponent
      nodes={nodes}
      edges={edges}
      nodeTypes={{"reconNode": ReconNodeComponent.make}}
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
    </ReactFlowComponent>
  }
}

@react.component
let make = (~reconRulesList: array<ReconEngineTypes.reconRuleType>) => {
  open ReconEngineOverviewSummaryUtils
  open ReactFlow

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (selectedNodeId, setSelectedNodeId) = React.useState(_ => None)
  let (allData, setAllData) = React.useState(_ => None)
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let (reactFlowNodes, setNodes, onNodesChange) = useNodesState([])
  let (reactFlowEdges, setEdges, onEdgesChange) = useEdgesState([])

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
      let accountData = await getAccounts()
      let allTransactions = await getTransactions()
      let accountTransactionData = processAllTransactionsWithAmounts(
        reconRulesList,
        allTransactions,
      )

      setAllData(_ => Some((reconRulesList, accountData, accountTransactionData, allTransactions)))

      let (nodes, edges) = generateNodesAndEdgesWithTransactionAmounts(
        reconRulesList,
        accountData,
        accountTransactionData,
        allTransactions,
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
    getAccountsData()->ignore
    None
  }, [])

  React.useEffect(() => {
    switch allData {
    | Some((reconRulesList, accountData, accountTransactionData, allTransactions)) => {
        let (nodes, edges) = generateNodesAndEdgesWithTransactionAmounts(
          reconRulesList,
          accountData,
          accountTransactionData,
          allTransactions,
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

  <div className="border rounded-xl border-nd_gray-200">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-30-rem" message="No data available." />}
      customLoader={<Shimmer styleClass="h-30-rem w-full rounded-b-xl" />}>
      <div className="h-30-rem overflow-hidden">
        <ReactFlowProvider>
          <FlowWithLayoutControls
            nodes={reactFlowNodes}
            edges={reactFlowEdges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
          />
        </ReactFlowProvider>
      </div>
    </PageLoaderWrapper>
  </div>
}

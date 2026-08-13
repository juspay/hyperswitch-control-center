open Typography
open ReconEngineSetupExplainerTypes

module LegendStep = {
  @react.component
  let make = (~step, ~title, ~description) => {
    <div className="flex flex-col gap-1 flex-1 min-w-0">
      <div className="flex items-center gap-2">
        <span
          className={`${body.xs.semibold} text-nd_gray-600 bg-nd_gray-100 rounded-full w-5 h-5 flex items-center justify-center shrink-0`}>
          {step->React.string}
        </span>
        <p className={`${body.md.semibold} text-nd_gray-800`}> {title->React.string} </p>
      </div>
      <p className={`${body.sm.medium} text-nd_gray-500`}> {description->React.string} </p>
    </div>
  }
}

module SetupFlowWithControls = {
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
      nodes
      edges
      nodeTypes={{"explainerNode": ReconEngineSetupExplainerNode.make}}
      onNodesChange
      onEdgesChange
      fitView={true}
      fitViewOptions={{"padding": 0.15}}
      nodesDraggable={true}
      nodesConnectable={false}
      elementsSelectable={true}
      panOnDrag={true}
      zoomOnScroll={true}
      zoomOnPinch={true}
      zoomOnDoubleClick={true}
      minZoom={0.2}
      maxZoom={1.5}
      proOptions={{"hideAttribution": true}}>
      <Background variant="dots" gap={20} size={1} />
      <Controls showZoom={true} showFitView={true} showInteractive={false} />
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
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getIngestionConfigs = ReconEngineHooks.useGetIngestionConfigs()
  let getTransformationConfigs = ReconEngineHooks.useGetTransformationConfigs()
  let getReconRuleList = ReconEngineHooks.useGetReconRuleList()
  let (nodes, setNodes, onNodesChange) = ReactFlow.useNodesState([])
  let (edges, setEdges, onEdgesChange) = ReactFlow.useEdgesState([])
  let (isFullscreen, setIsFullscreen) = React.useState(_ => false)

  let toggleFullscreen = () => setIsFullscreen(prev => !prev)

  React.useEffect(() => {
    let handleKeyUp = ev => {
      open ReactEvent.Keyboard
      if ev->key === "Escape" || ev->keyCode === 27 {
        setIsFullscreen(_ => false)
      }
    }
    if isFullscreen {
      Window.addEventListener("keyup", handleKeyUp)
    }
    Some(() => Window.removeEventListener("keyup", handleKeyUp))
  }, [isFullscreen])

  let handleNodeClick = (kind: explainerNodeKind, entityId: string) => {
    let url = switch kind {
    | RuleNode => Some(`/v1/recon-engine/rules/${entityId}`)
    | AccountNode
    | TransformationNode =>
      Some("/v1/recon-engine/transformed-entries")
    | IngestionNode => None
    }
    switch url {
    | Some(url) => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url))
    | None => ()
    }
  }

  let fetchSetupData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let (accounts, ingestionConfigs, transformationConfigs, rules) = await Promise.all4((
        getAccounts(),
        getIngestionConfigs(),
        getTransformationConfigs(),
        getReconRuleList(),
      ))
      let (newNodes, newEdges) = ReconEngineSetupExplainerUtils.generateSetupNodesAndEdges(
        ~accounts,
        ~ingestionConfigs,
        ~transformationConfigs,
        ~rules,
        ~onNodeClick=handleNodeClick,
      )
      if newNodes->Array.length > 0 {
        setNodes(_ => newNodes)->ignore
        setEdges(_ => newEdges)->ignore
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load your reconciliation setup"))
    }
  }

  React.useEffect(() => {
    fetchSetupData()->ignore
    None
  }, [])

  let fullScreenClass = isFullscreen
    ? "fixed inset-0 z-50 h-screen w-screen rounded-none"
    : "h-45-rem w-full rounded-xl"

  <div className="flex flex-col">
    <PageUtils.PageHeading
      title="Setup Map"
      subTitle="A live map of your current setup — how files flow in, become entries, and get reconciled by your rules."
    />
    <div className="flex flex-col gap-4">
      <div className="flex flex-row gap-6 rounded-xl border border-nd_gray-150 bg-nd_gray-25 p-4">
        <LegendStep
          step="1" title="Data Sources" description="Files arrive from your systems and providers"
        />
        <LegendStep
          step="2" title="Transformations" description="Each file is parsed into normalized entries"
        />
        <LegendStep
          step="3" title="Accounts" description="Entries are posted to double-entry accounts"
        />
        <LegendStep
          step="4"
          title="Recon Rules"
          description="Rules pair entries across accounts; anything unmatched becomes an exception"
        />
      </div>
      <div className={`border border-nd_gray-200 overflow-hidden bg-white ${fullScreenClass}`}>
        <PageLoaderWrapper
          screenState
          customUI={<NoDataFound
            message="No reconciliation setup configured yet. Set up ingestion, transformations and rules to see your flow here."
            renderType=Painting
          />}
          customLoader={<Shimmer styleClass="h-45-rem w-full rounded-xl" />}>
          <div className="h-full overflow-hidden">
            <ReactFlow.ReactFlowProvider>
              <SetupFlowWithControls
                nodes edges onNodesChange onEdgesChange isFullscreen toggleFullscreen
              />
            </ReactFlow.ReactFlowProvider>
          </div>
        </PageLoaderWrapper>
      </div>
    </div>
  </div>
}

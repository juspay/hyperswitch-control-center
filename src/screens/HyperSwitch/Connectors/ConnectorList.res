module NewProcessorCards = {
  @react.component
  let make = (
    ~configuredConnectors: array<ConnectorTypes.connectorName>,
    ~showIcons: bool,
    ~isPayoutFlow: bool,
  ) => {
    let featureFlagDetails =
      HyperswitchAtom.featureFlagAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->FeatureFlagUtils.featureFlagType
    let connectorsAvailableForIntegration = isPayoutFlow
      ? ConnectorUtils.payoutConnectorList
      : ConnectorUtils.connectorList
    let unConfiguredConnectors =
      connectorsAvailableForIntegration->Js.Array2.filter(total =>
        configuredConnectors->Js.Array2.find(item => item === total)->Belt.Option.isNone
      )

    let (showModal, setShowModal) = React.useState(_ => false)

    let urlPrefix = isPayoutFlow ? "payoutconnectors/new" : "connectors/new"
    let handleClick = connectorName => {
      RescriptReactRouter.push(`${urlPrefix}?name=${connectorName}`)
    }
    let unConfiguredConnectorsCount = unConfiguredConnectors->Js.Array2.length

    let descriptedConnectors = (connectorList, heading, showRequestConnectorBtn) => {
      <>
        <div className="flex w-full justify-between">
          <h2
            className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
            {heading->React.string}
          </h2>
          <UIUtils.RenderIf condition={showRequestConnectorBtn}>
            <div
              onClick={_ => setShowModal(_ => true)}
              className="text-blue-900 cursor-pointer underline underline-offset-4 font-medium">
              {"Can't find the connector of you're choice?"->React.string}
            </div>
          </UIUtils.RenderIf>
        </div>
        <div className="grid gap-4 lg:grid-cols-4 md:grid-cols-2 grid-cols-1 mb-5">
          {connectorList
          ->Array.mapWithIndex((connector, i) => {
            let connectorName = connector->ConnectorUtils.getConnectorNameString
            let connectorInfo = connector->ConnectorUtils.getConnectorInfo
            let size = switch connectorName->ConnectorUtils.getConnectorNameTypeFromString {
            | PHONYPAY | PRETENDPAY | FAUXPAY => "w-8 h-8"
            | _ => "w-14 h-14 rounded-full"
            }

            <div
              key={i->string_of_int}
              className="border p-8 gap-4 bg-white rounded flex flex-col justify-between">
              <div className="flex gap-2 items-center">
                <GatewayIcon gateway={connectorName->Js.String2.toUpperCase} className=size />
                <h1 className="text-xl font-semibold break-all">
                  {connectorName->LogicUtils.capitalizeString->React.string}
                </h1>
              </div>
              <div className="overflow-hidden text-gray-400 flex-1 mb-6">
                {connectorInfo.description->React.string}
              </div>
              <Button
                text="+ Connect"
                buttonType={Secondary}
                buttonSize={Small}
                onClick={_ => handleClick(connectorName)}
              />
            </div>
          })
          ->React.array}
        </div>
      </>
    }

    let iconsConnectors = (connectorList, heading, showRequestConnectorBtn) => {
      <>
        <div className="flex w-full justify-between">
          <h2
            className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
            {heading->React.string}
          </h2>
          <UIUtils.RenderIf condition={showRequestConnectorBtn}>
            <div
              onClick={_ => setShowModal(_ => true)}
              className="text-blue-900 cursor-pointer underline underline-offset-4 font-medium">
              {"Can't find the connector of you're choice?"->React.string}
            </div>
          </UIUtils.RenderIf>
        </div>
        <div className="flex gap-2 flex-wrap">
          {connectorList
          ->Array.mapWithIndex((connector, i) => {
            let connectorName = connector->ConnectorUtils.getConnectorNameString
            let size = switch connectorName->ConnectorUtils.getConnectorNameTypeFromString {
            | PHONYPAY | PRETENDPAY | FAUXPAY => "w-8 h-8"
            | _ => "w-14 h-14 rounded-full"
            }
            <ToolTip
              key={i->string_of_int}
              description={connectorName->LogicUtils.capitalizeString}
              toolTipFor={<div
                className="bg-white p-2 cursor-pointer" onClick={_ => handleClick(connectorName)}>
                <GatewayIcon gateway={connectorName->Js.String2.toUpperCase} className=size />
              </div>}
              toolTipPosition={Top}
              tooltipWidthClass="w-30"
            />
          })
          ->React.array}
        </div>
      </>
    }

    <UIUtils.RenderIf condition={unConfiguredConnectorsCount > 0}>
      <div className="flex flex-col gap-4">
        {if showIcons {
          <>
            {connectorsAvailableForIntegration->iconsConnectors("Connect a new connector", true)}
            {<UIUtils.RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->ConnectorUtils.dummyConnectorList
              ->iconsConnectors("Connect a test connector", false)}
            </UIUtils.RenderIf>}
          </>
        } else {
          <>
            <UIUtils.RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->ConnectorUtils.dummyConnectorList
              ->descriptedConnectors("Connect a test connector", false)}
            </UIUtils.RenderIf>
            {connectorsAvailableForIntegration->descriptedConnectors(
              "Connect a new connector",
              true,
            )}
          </>
        }}
      </div>
      <UIUtils.RenderIf condition={showModal}>
        <HSwitchFeedBackModal
          modalHeading="Request a connector"
          setShowModal
          showModal
          modalType={RequestConnectorModal}
        />
      </UIUtils.RenderIf>
    </UIUtils.RenderIf>
  }
}

@react.component
let make = (~isPayoutFlow=false) => {
  open UIUtils
  open ConnectorUtils
  let {showFeedbackModal, setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails =
    HyperswitchAtom.featureFlagAtom
    ->Recoil.useRecoilValueFromAtom
    ->LogicUtils.safeParse
    ->FeatureFlagUtils.featureFlagType

  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let detailedCardCount = 5
  let showConnectorIcons = configuredConnectors->len > detailedCardCount
  let (searchText, setSearchText) = React.useState(_ => "")
  let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()

  let getConnectorListAndUpdateState = async () => {
    open LogicUtils
    try {
      let response = await fetchConnectorListResponse()
      let removeFromList = isPayoutFlow ? HSwitchUtils.PayoutConnector : HSwitchUtils.FRMPlayer
      let connectorsList = response->HSwitchUtils.getProcessorsListFromJson(~removeFromList, ())
      let previousData = connectorsList->Js.Array2.map(ConnectorTableUtils.getProcessorPayloadType)

      setFilteredConnectorData(_ => previousData->Js.Array2.map(Js.Nullable.return))
      setPreviouslyConnectedData(_ => previousData->Js.Array2.map(Js.Nullable.return))
      let arr =
        connectorsList->Js.Array2.map(paymentMethod =>
          paymentMethod->getString("connector_name", "")->getConnectorNameTypeFromString
        )
      setConfiguredConnectors(_ => arr)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect1(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [isPayoutFlow])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->Js.String2.length > 0 {
      arr->Js.Array2.filter((obj: Js.Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Js.Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.profile_id, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let entityPrefix = isPayoutFlow ? "payout" : ""

  <div className="overflow-scroll">
    <PageLoaderWrapper screenState>
      <UIUtils.RenderIf condition={showFeedbackModal}>
        <HSwitchFeedBackModal
          showModal={showFeedbackModal}
          setShowModal={setShowFeedbackModal}
          modalHeading="Tell us about your integration experience"
          feedbackVia="connected_a_connector"
        />
      </UIUtils.RenderIf>
      <div className="flex flex-col gap-10">
        <RenderIf condition={isPayoutFlow && featureFlagDetails.frm}>
          <FRMSelect.FRMProPackageInfo />
        </RenderIf>
        <RenderIf condition={showConnectorIcons}>
          <NewProcessorCards configuredConnectors showIcons={showConnectorIcons} isPayoutFlow />
        </RenderIf>
        <RenderIf condition={configuredConnectors->Js.Array2.length > 0}>
          <LoadedTable
            title="Previously Connected"
            actualData=filteredConnectorData
            totalResults={filteredConnectorData->Js.Array2.length}
            filters={<TableSearchFilter
              data={previouslyConnectedData}
              filterLogic
              placeholder="Search Processor or Country or Business Label"
              customSearchBarWrapperWidth="w-full lg:w-1/3"
              customInputBoxWidth="w-full"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            resultsPerPage=20
            offset
            setOffset
            entity={ConnectorTableUtils.connectorEntity(`${entityPrefix}connectors`)}
            currrentFetchCount={filteredConnectorData->Js.Array2.length}
            collapseTabelRow=false
          />
        </RenderIf>
        <RenderIf condition={!showConnectorIcons}>
          <NewProcessorCards configuredConnectors showIcons={showConnectorIcons} isPayoutFlow />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}

let p1MediumTextStyle = HSwitchUtils.getTextClass(~textVariant=P1, ~paragraphTextVariant=Medium, ())

module RequestConnector = {
  @react.component
  let make = (~connectorList, ~setShowModal) => {
    <UIUtils.RenderIf condition={connectorList->Js.Array2.length === 0}>
      <div
        className="flex flex-col gap-6 items-center justify-center w-full bg-white rounded-lg border p-8">
        <div className="mb-8 mt-4 max-w-full h-auto">
          <img src={`${LogicUtils.useUrlPrefix()}/notfound.svg`} />
        </div>
        <p className="jp-grey-700 opacity-50">
          {"Uh-oh! Looks like we couldn't find the processor you were searching for."->React.string}
        </p>
        <Button
          text={"Request a processor"} buttonType=Primary onClick={_ => setShowModal(_ => true)}
        />
      </div>
    </UIUtils.RenderIf>
  }
}

module NewProcessorCards = {
  @react.component
  let make = (
    ~configuredConnectors: array<ConnectorTypes.connectorName>,
    ~showIcons: bool,
    ~isPayoutFlow: bool,
  ) => {
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
      ? ConnectorUtils.connectorListForLive
      : isPayoutFlow
      ? ConnectorUtils.payoutConnectorList
      : ConnectorUtils.connectorList

    let unConfiguredConnectors =
      connectorsAvailableForIntegration->Js.Array2.filter(total =>
        configuredConnectors->Js.Array2.find(item => item === total)->Belt.Option.isNone
      )

    let (showModal, setShowModal) = React.useState(_ => false)
    let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
    let searchRef = React.useRef(Js.Nullable.null)

    let urlPrefix = isPayoutFlow ? "payoutconnectors/new" : "connectors/new"
    let handleClick = connectorName => {
      RescriptReactRouter.push(`${urlPrefix}?name=${connectorName}`)
    }
    let unConfiguredConnectorsCount = unConfiguredConnectors->Js.Array2.length

    let handleSearch = event => {
      let val = ref(ReactEvent.Form.currentTarget(event)["value"])
      setSearchedConnector(_ => val.contents)
    }

    let descriptedConnectors = (
      connectorList,
      heading,
      showRequestConnectorBtn,
      ~showSearch=true,
      (),
    ) => {
      <>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
        <div className="flex w-full justify-between">
          <UIUtils.RenderIf condition={showSearch}>
            <input
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search a processor"
              className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
            />
          </UIUtils.RenderIf>
          <UIUtils.RenderIf condition={showRequestConnectorBtn}>
            <div
              onClick={_ => setShowModal(_ => true)}
              className="text-blue-900 cursor-pointer underline underline-offset-4 font-medium">
              {"Can't find the processor of your choice?"->React.string}
            </div>
          </UIUtils.RenderIf>
        </div>
        <UIUtils.RenderIf condition={connectorList->Js.Array2.length > 0}>
          <div
            className="grid gap-x-5 gap-y-6 2xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-2 grid-cols-1 mb-5">
            {connectorList
            ->Array.mapWithIndex((connector, i) => {
              let connectorName = connector->ConnectorUtils.getConnectorNameString
              let connectorInfo = connector->ConnectorUtils.getConnectorInfo
              let size = "w-14 h-14 rounded-sm"

              <div
                key={i->string_of_int}
                className="border p-6 gap-4 bg-white rounded flex flex-col justify-between">
                <div className="flex flex-col gap-3 items-start">
                  <GatewayIcon gateway={connectorName->Js.String2.toUpperCase} className=size />
                  <p className={`${p1MediumTextStyle} break-all`}>
                    {connectorName->LogicUtils.capitalizeString->React.string}
                  </p>
                </div>
                <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                  {connectorInfo.description->React.string}
                </p>
                <Button
                  text="+ Connect"
                  buttonType={Transparent}
                  buttonSize={Small}
                  onClick={_ => handleClick(connectorName)}
                  textStyle="text-jp-gray-900"
                />
              </div>
            })
            ->React.array}
          </div>
        </UIUtils.RenderIf>
        <RequestConnector connectorList setShowModal />
      </>
    }

    let iconsConnectors = (
      connectorList,
      heading,
      showRequestConnectorBtn,
      ~showSearch=true,
      (),
    ) => {
      <>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
        <div className="flex w-full justify-between">
          <UIUtils.RenderIf condition={showSearch}>
            <input
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search a processor"
              className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
            />
          </UIUtils.RenderIf>
          <UIUtils.RenderIf condition={showRequestConnectorBtn}>
            <div
              onClick={_ => setShowModal(_ => true)}
              className="text-blue-900 cursor-pointer underline underline-offset-4 font-medium">
              {"Can't find the processor of your choice?"->React.string}
            </div>
          </UIUtils.RenderIf>
        </div>
        <UIUtils.RenderIf condition={connectorList->Js.Array2.length > 0}>
          <div className="bg-white rounded-md flex gap-2 flex-wrap p-4 border">
            {connectorList
            ->Array.mapWithIndex((connector, i) => {
              let connectorName = connector->ConnectorUtils.getConnectorNameString
              let size = "w-14 h-14 rounded-sm"
              <ToolTip
                key={i->string_of_int}
                description={connectorName->LogicUtils.capitalizeString}
                toolTipFor={<div
                  className="p-2 cursor-pointer" onClick={_ => handleClick(connectorName)}>
                  <GatewayIcon gateway={connectorName->Js.String2.toUpperCase} className=size />
                </div>}
                toolTipPosition={Top}
                tooltipWidthClass="w-30"
              />
            })
            ->React.array}
          </div>
        </UIUtils.RenderIf>
        <RequestConnector connectorList setShowModal />
      </>
    }

    let connectorListFiltered = {
      if searchedConnector->Js.String2.length > 0 {
        connectorsAvailableForIntegration->Js.Array2.filter(item =>
          item
          ->ConnectorUtils.getConnectorNameString
          ->Js.String2.includes(searchedConnector->Js.String2.toLowerCase)
        )
      } else {
        connectorsAvailableForIntegration
      }
    }
    <UIUtils.RenderIf condition={unConfiguredConnectorsCount > 0}>
      <div className="flex flex-col gap-4">
        {if showIcons {
          <>
            {connectorListFiltered->iconsConnectors("Connect a new connector", true, ())}
            {<UIUtils.RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->ConnectorUtils.dummyConnectorList
              ->iconsConnectors("Connect a test connector", false, ~showSearch=false, ())}
            </UIUtils.RenderIf>}
          </>
        } else {
          <>
            <UIUtils.RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->ConnectorUtils.dummyConnectorList
              ->descriptedConnectors("Connect a test connector", false, ~showSearch=false, ())}
            </UIUtils.RenderIf>
            {connectorListFiltered->descriptedConnectors("Connect a new connector", true, ())}
          </>
        }}
      </div>
      <UIUtils.RenderIf condition={showModal}>
        <HSwitchFeedBackModal
          modalHeading="Request a processor"
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

  <div>
    <PageUtils.PageHeading
      title={isPayoutFlow ? "Payout Processors" : `Processors`}
      subTitle={isPayoutFlow
        ? "Connect and manage payout processors for disbursements and settlements"
        : "Connect and manage payment processors to enable payment acceptance"}
    />
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
            collapseTableRow=false
          />
        </RenderIf>
        <RenderIf condition={!showConnectorIcons}>
          <NewProcessorCards configuredConnectors showIcons={showConnectorIcons} isPayoutFlow />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}

open HSwitchUtils
let p1MediumTextStyle = getTextClass((P1, Medium))

module RequestConnector = {
  @react.component
  let make = (~connectorList, ~setShowModal) => {
    <UIUtils.RenderIf condition={connectorList->Array.length === 0}>
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

module CantFindProcessor = {
  @react.component
  let make = (~showRequestConnectorBtn, ~setShowModal) => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.merchantAccountWrite)

    <UIUtils.RenderIf condition={showRequestConnectorBtn}>
      <ACLDiv
        permission=userPermissionJson.merchantAccountWrite
        onClick={_ => setShowModal(_ => true)}
        className={`text-blue-900 underline underline-offset-4 font-medium ${cursorStyles}`}>
        {"Can't find the processor of your choice?"->React.string}
      </ACLDiv>
    </UIUtils.RenderIf>
  }
}

module NewProcessorCards = {
  open UIUtils
  @react.component
  let make = (
    ~configuredConnectors: array<ConnectorTypes.connectorName>,
    ~showIcons: bool,
    ~isPayoutFlow: bool,
  ) => {
    open ConnectorUtils
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

    let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
      ? connectorListForLive
      : isPayoutFlow
      ? payoutConnectorList
      : connectorList

    let unConfiguredConnectors =
      connectorsAvailableForIntegration->Array.filter(total =>
        configuredConnectors->Array.find(item => item === total)->Option.isNone
      )

    let (showModal, setShowModal) = React.useState(_ => false)
    let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
    let searchRef = React.useRef(Nullable.null)

    let urlPrefix = isPayoutFlow ? "payoutconnectors/new" : "connectors/new"
    let handleClick = connectorName => {
      RescriptReactRouter.push(`${urlPrefix}?name=${connectorName}`)
    }
    let unConfiguredConnectorsCount = unConfiguredConnectors->Array.length

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
        <AddDataAttributes
          attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
          <h2
            className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
            {heading->React.string}
          </h2>
        </AddDataAttributes>
        <div className="flex w-full justify-between">
          <RenderIf condition={showSearch}>
            <AddDataAttributes attributes=[("data-testid", "search-processor")]>
              <input
                ref={searchRef->ReactDOM.Ref.domRef}
                type_="text"
                value=searchedConnector
                onChange=handleSearch
                placeholder="Search a processor"
                className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
                id="search-processor"
              />
            </AddDataAttributes>
          </RenderIf>
          <CantFindProcessor showRequestConnectorBtn setShowModal />
        </div>
        <RenderIf condition={connectorList->Array.length > 0}>
          <div
            className="grid gap-x-5 gap-y-6 2xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-2 grid-cols-1 mb-5">
            {connectorList
            ->Array.mapWithIndex((connector, i) => {
              let connectorName = connector->getConnectorNameString
              let connectorInfo = connector->getConnectorInfo
              let size = "w-14 h-14 rounded-sm"
              <AddDataAttributes attributes=[("data-testid", connectorName->String.toLowerCase)]>
                <div
                  onClick={_ => handleClick(connectorName)}
                  key={i->string_of_int}
                  className="border p-6 gap-4 bg-white rounded flex flex-col justify-between">
                  <div className="flex flex-col gap-3 items-start">
                    <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                    <p className={`${p1MediumTextStyle} break-all`}>
                      {connectorName->getDisplayNameForConnectors->React.string}
                    </p>
                  </div>
                  <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                    {connectorInfo.description->React.string}
                  </p>
                  <ACLButton
                    access={userPermissionJson.merchantConnectorAccountWrite}
                    text="+ Connect"
                    buttonType={Transparent}
                    buttonSize={Small}
                    textStyle="text-jp-gray-900"
                  />
                </div>
              </AddDataAttributes>
            })
            ->React.array}
          </div>
        </RenderIf>
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
        <AddDataAttributes
          attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
          <h2
            className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
            {heading->React.string}
          </h2>
        </AddDataAttributes>
        <div className="flex w-full justify-between">
          <RenderIf condition={showSearch}>
            <input
              {...DOMUtils.domProps({
                "data-testid": "search-processor",
              })}
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search a processor"
              className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
            />
          </RenderIf>
          <CantFindProcessor showRequestConnectorBtn setShowModal />
        </div>
        <RenderIf condition={connectorList->Array.length > 0}>
          <div className="bg-white rounded-md flex gap-2 flex-wrap p-4 border">
            {connectorList
            ->Array.mapWithIndex((connector, i) => {
              let connectorName = connector->getConnectorNameString
              let cursorStyles = PermissionUtils.cursorStyles(
                userPermissionJson.merchantConnectorAccountWrite,
              )

              <ACLDiv
                key={i->string_of_int}
                permission=userPermissionJson.merchantConnectorAccountWrite
                className={`p-2 ${cursorStyles}`}
                noAccessDescription=noAccessControlTextForProcessors
                tooltipWidthClass="w-30"
                description={connectorName->getDisplayNameForConnectors}
                onClick={_ => handleClick(connectorName)}>
                <AddDataAttributes attributes=[("data-testid", connectorName->String.toLowerCase)]>
                  <GatewayIcon
                    gateway={connectorName->String.toUpperCase} className="w-14 h-14 rounded-sm"
                  />
                </AddDataAttributes>
              </ACLDiv>
            })
            ->React.array}
          </div>
        </RenderIf>
        <RequestConnector connectorList setShowModal />
      </>
    }

    let connectorListFiltered = {
      if searchedConnector->LogicUtils.isNonEmptyString {
        connectorsAvailableForIntegration->Array.filter(item =>
          item->getConnectorNameString->String.includes(searchedConnector->String.toLowerCase)
        )
      } else {
        connectorsAvailableForIntegration
      }
    }
    <RenderIf condition={unConfiguredConnectorsCount > 0}>
      <div className="flex flex-col gap-4">
        {if showIcons {
          <>
            {connectorListFiltered->iconsConnectors("Connect a new connector", true, ())}
            {<RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->dummyConnectorList
              ->iconsConnectors("Connect a test connector", false, ~showSearch=false, ())}
            </RenderIf>}
          </>
        } else {
          <>
            <RenderIf condition={featureFlagDetails.testProcessors && !isPayoutFlow}>
              {featureFlagDetails.testProcessors
              ->dummyConnectorList
              ->descriptedConnectors("Connect a test connector", false, ~showSearch=false, ())}
            </RenderIf>
            {connectorListFiltered->descriptedConnectors("Connect a new connector", true, ())}
          </>
        }}
      </div>
      <RenderIf condition={showModal}>
        <HSwitchFeedBackModal
          modalHeading="Request a processor"
          setShowModal
          showModal
          modalType={RequestConnectorModal}
        />
      </RenderIf>
    </RenderIf>
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
  let showConnectorIcons = configuredConnectors->Array.length > detailedCardCount
  let (searchText, setSearchText) = React.useState(_ => "")
  let fetchConnectorListResponse = useFetchConnectorList()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let getConnectorListAndUpdateState = async () => {
    open LogicUtils
    try {
      let response = await fetchConnectorListResponse()
      let removeFromList = isPayoutFlow ? ConnectorTypes.PayoutConnector : ConnectorTypes.FRMPlayer
      let connectorsList = response->getProcessorsListFromJson(~removeFromList, ())
      let previousData = connectorsList->Array.map(ConnectorTableUtils.getProcessorPayloadType)

      setFilteredConnectorData(_ => previousData->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => previousData->Array.map(Nullable.make))
      let arr =
        connectorsList->Array.map(paymentMethod =>
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
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Nullable.toOption(obj) {
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
      <RenderIf condition={showFeedbackModal}>
        <HSwitchFeedBackModal
          showModal={showFeedbackModal}
          setShowModal={setShowFeedbackModal}
          modalHeading="Tell us about your integration experience"
          feedbackVia="connected_a_connector"
        />
      </RenderIf>
      <div className="flex flex-col gap-10">
        <RenderIf condition={showConnectorIcons}>
          <NewProcessorCards configuredConnectors showIcons={showConnectorIcons} isPayoutFlow />
        </RenderIf>
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Previously Connected"
            actualData=filteredConnectorData
            totalResults={filteredConnectorData->Array.length}
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
            entity={ConnectorTableUtils.connectorEntity(
              `${entityPrefix}connectors`,
              ~permission=userPermissionJson.merchantConnectorAccountWrite,
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
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

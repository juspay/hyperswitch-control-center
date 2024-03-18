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
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getConnectorListAndUpdateState = async () => {
    try {
      let response = await fetchConnectorListResponse()
      let removeFromList = isPayoutFlow ? ConnectorTypes.PayoutConnector : ConnectorTypes.FRMPlayer

      // TODO : maintain separate list for multiple types of connectors
      let connectorsList =
        response
        ->ConnectorListMapper.getArrayOfConnectorListPayloadType
        ->getProcessorsListFromJson(~removeFromList, ())
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorsList->Array.map(Nullable.make))
      setConfiguredConnectors(_ =>
        connectorsList->ConnectorUtils.getConnectorTypeArrayFromListConnectors
      )
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
  let urlPrefix = isPayoutFlow ? "payoutconnectors/new" : "connectors/new"

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : isPayoutFlow
    ? payoutConnectorList
    : connectorList

  <div>
    <PageUtils.PageHeading
      title={isPayoutFlow ? "Payout Processors" : `Payment Processors`}
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
          <ProcessorCards
            configuredConnectors
            showIcons={showConnectorIcons}
            connectorsAvailableForIntegration
            showTestProcessor={!isPayoutFlow}
            urlPrefix
          />
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
              ~permission=userPermissionJson.connectorsManage,
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <RenderIf condition={!showConnectorIcons}>
          <ProcessorCards
            configuredConnectors
            showIcons={showConnectorIcons}
            connectorsAvailableForIntegration
            showTestProcessor={!isPayoutFlow}
            urlPrefix
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}

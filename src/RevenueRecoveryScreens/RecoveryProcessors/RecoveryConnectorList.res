@react.component
let make = () => {
  open RecoveryPaymentProcessorsUtils
  // let {showFeedbackModal, setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let connectorListFromRecoil = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getConnectorListAndUpdateState = async () => {
    try {
      // TODO : maintain separate list for multiple types of connectors
      let connectorsList =
        connectorListFromRecoil->ConnectorUtils.getProcessorsListFromJson(
          ~removeFromList=ConnectorTypes.FRMPlayer,
        )
      connectorsList->Array.reverse
      ConnectorUtils.sortByDisableField(connectorsList, connectorPayload =>
        connectorPayload.disabled
      )
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

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.merchant_connector_id, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : connectorList

  <div>
    <PageLoaderWrapper screenState>
      <PageUtils.PageHeading title="Payment Processors" customHeadingStyle="mb-10" subTitle="" />
      <div className="flex flex-col gap-14">
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData=filteredConnectorData
            totalResults={filteredConnectorData->Array.length}
            filters={<TableSearchFilter
              data={previouslyConnectedData}
              filterLogic
              placeholder="Search Processor or Merchant Connector Id or Connector Label"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            resultsPerPage=20
            offset
            setOffset
            entity={ConnectorTableUtils.connectorEntity(
              "v2/recovery/payment-processors",
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <RecoveryProcessorCards
          configuredConnectors
          connectorsAvailableForIntegration
          urlPrefix="v2/recovery/payment-processors/new"
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

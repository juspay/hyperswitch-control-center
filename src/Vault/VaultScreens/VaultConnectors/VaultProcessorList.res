@react.component
let make = () => {
  open ConnectorUtils

  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let connectorListFromRecoil = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)

  let getConnectorListAndUpdateState = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let connectorsList =
        connectorListFromRecoil->getProcessorsListFromJson(~removeFromList=ConnectorTypes.FRMPlayer)
      connectorsList->Array.reverse
      setConfiguredConnectors(_ => connectorsList->getConnectorTypeArrayFromListConnectors)
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorsList->Array.map(Nullable.make))
      setConfiguredConnectors(_ => connectorsList->getConnectorTypeArrayFromListConnectors)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }
  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [connectorListFromRecoil])

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : connectorList

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

  <PageLoaderWrapper screenState>
    <div className="mt-12">
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
          entity={VaultConnectorEntity.connectorEntity(
            "v2/vault/onboarding",
            ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
          )}
          currrentFetchCount={filteredConnectorData->Array.length}
          collapseTableRow=false
        />
      </RenderIf>
      <VaultProcessorCards configuredConnectors connectorsAvailableForIntegration />
    </div>
  </PageLoaderWrapper>
}

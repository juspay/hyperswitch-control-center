@react.component
let make = () => {
  let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=VaultProcessor)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let {vaultProcessorsLiveListFromConfig} =
    HyperswitchAtom.connectorListForLiveAtom->Recoil.useRecoilValueFromAtom

  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, list) = ob
    let filteredList = if searchText->isNonEmptyString {
      list->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayloadCommonType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.id, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      list
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let getConnectorList = async _ => {
    try {
      connectorList->Array.reverse
      ConnectorUtils.sortByDisableField(connectorList, connectorPayload =>
        connectorPayload.disabled
      )

      setConfiguredConnectors(_ => connectorList)
      setFilteredConnectorData(_ => connectorList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorList()->ignore
    None
  }, [])
  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? vaultProcessorsLiveListFromConfig->Array.length > 0
        ? vaultProcessorsLiveListFromConfig
        : ConnectorUtils.vaultProcessorList
    : ConnectorUtils.vaultProcessorList
  <div>
    <PageUtils.PageHeading
      title={"Vault Processor"} subTitle={"Connect and configure Vault Processor"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={filteredConnectorData}
            totalResults={filteredConnectorData->Array.length}
            resultsPerPage=20
            entity={VaultProcessorsEntity.vaultProcessorEntity(
              "vault-processor",
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
              ~external_vault_connector_details=businessProfileRecoilVal.external_vault_connector_details,
            )}
            filters={<TableSearchFilter
              data={configuredConnectors->Array.map(Nullable.make)}
              filterLogic
              placeholder="Search Processor or Merchant Connector Id or Connector Label"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            offset
            setOffset
            currrentFetchCount={configuredConnectors->Array.map(Nullable.make)->Array.length}
            collapseTableRow=false
            showAutoScroll=true
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors={ConnectorListInterface.mapConnectorPayloadToConnectorType(
            ConnectorListInterface.connectorInterfaceV1,
            ConnectorTypes.VaultProcessor,
            configuredConnectors,
          )}
          connectorsAvailableForIntegration
          urlPrefix="vault-processor/new"
          connectorType=ConnectorTypes.VaultProcessor
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

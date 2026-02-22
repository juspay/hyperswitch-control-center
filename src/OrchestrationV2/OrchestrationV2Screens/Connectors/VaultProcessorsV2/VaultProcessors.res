@react.component
let make = () => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")

  let connectorsList = ConnectorListInterface.useFilteredConnectorList(~retainInList=VaultProcessor)

  let getConnectorListAndUpdateState = async () => {
    try {
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorsList->Array.map(Nullable.make))
      let list = ConnectorListInterface.mapConnectorPayloadToConnectorType(
        ConnectorListInterface.connectorInterfaceV2,
        ConnectorTypes.VaultProcessor,
        connectorsList,
      )
      setConfiguredConnectors(_ => list)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch vault processors"))
    }
  }

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    setShowSideBar(_ => true)
    None
  }, [connectorsList->Array.length])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, list) = ob
    let filteredList = if searchText->isNonEmptyString {
      list->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayloadCommonType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      list
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let connectorsAvailableForIntegration = ConnectorUtils.vaultProcessorListV2

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10">
      <PageUtils.PageHeading
        title="Vault Processors"
        subTitle="Connect and manage your Hyperswitch Vault for secure card tokenisation"
        customHeadingStyle="mb-4 text-nd_gray-800"
        customSubTitleStyle="text-nd_gray-400 font-medium !opacity-100"
      />
      <RenderIf condition={configuredConnectors->Array.length > 0}>
        <LoadedTable
          title="Connected Vault Processors"
          actualData=filteredConnectorData
          totalResults={filteredConnectorData->Array.length}
          filters={<TableSearchFilter
            data={previouslyConnectedData}
            filterLogic
            placeholder="Search Vault Processor or Connector Label"
            customSearchBarWrapperWidth="w-full lg:w-1/2"
            customInputBoxWidth="w-full"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          resultsPerPage=20
          offset
          setOffset
          entity={ConnectorInterfaceTableEntity.connectorEntity(
            "v2/orchestration/vault-processors",
            ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            ~sendMixpanelEvent=() => (),
          )}
          currrentFetchCount={filteredConnectorData->Array.length}
          collapseTableRow=false
          showAutoScroll=true
        />
      </RenderIf>
      <VaultProcessorCardsV2
        configuredConnectors
        connectorsAvailableForIntegration
        urlPrefix="v2/orchestration/vault-processors/new"
      />
      // <RenderIf condition={filteredConnectorData->Array.length === 0}>
      //   <div className="flex flex-col items-center gap-6 p-12 bg-white border rounded-lg">
      //     <p className="text-nd_gray-400 text-base font-medium">
      //       {"No vault processors connected yet."->React.string}
      //     </p>
      //     <ACLButton
      //       authorization={userHasAccess(~groupAccess=ConnectorsManage)}
      //       text="Connect Vault"
      //       buttonType=Primary
      //       onClick={_ =>
      //         RescriptReactRouter.push(
      //           GlobalVars.appendDashboardPath(
      //             ~url=`/v2/orchestration/vault-processors/new?name=${VaultProcessorUtilsV2.vaultConnectorName}`,
      //           ),
      //         )}
      //     />
      //   </div>
      // </RenderIf>
    </div>
  </PageLoaderWrapper>
}

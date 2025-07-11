@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let connectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PMAuthProcessor,
  )

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayloadCommonType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.id, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let getConnectorList = async _ => {
    try {
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

  <div>
    <PageUtils.PageHeading
      title={"PM Authentication Processor"}
      subTitle={"Connect and configure open banking providers to verify customer bank accounts"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={filteredConnectorData}
            totalResults={filteredConnectorData->Array.length}
            resultsPerPage=20
            entity={PMAuthenticationTableEntity.pmAuthenticationEntity(
              `pm-authentication-processor`,
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
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
          configuredConnectors={ConnectorInterface.mapConnectorPayloadToConnectorType(
            ConnectorInterface.connectorInterfaceV1,
            ConnectorTypes.PMAuthenticationProcessor,
            configuredConnectors,
          )}
          connectorsAvailableForIntegration=ConnectorUtils.pmAuthenticationConnectorList
          urlPrefix="pm-authentication-processor/new"
          connectorType=ConnectorTypes.PMAuthenticationProcessor
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

@react.component
let make = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])

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

  let getConnectorList = async _ => {
    try {
      let response = await fetchConnectorListResponse()
      let connectorsList =
        response
        ->ConnectorListMapper.getArrayOfConnectorListPayloadType
        ->Array.filter(item =>
          item.connector_type->ConnectorUtils.connectorTypeStringToTypeMapper ===
            AuthenticationProcessor
        )

      HSwitchUtils.sortByDisableField(connectorsList, c => c.disabled)

      setConfiguredConnectors(_ => connectorsList)
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
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
      title={"3DS Authentication Manager"}
      subTitle={"Connect and manage 3DS authentication providers to enhance the conversions"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={filteredConnectorData->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={ThreeDsTableEntity.threeDsAuthenticatorEntity(
              `3ds-authenticators`,
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            )}
            filters={<TableSearchFilter
              data={configuredConnectors->Array.map(Nullable.make)}
              filterLogic
              placeholder="Search Processor or Merchant Connector Id or Connector Label"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal={searchText}
              setSearchVal={setSearchText}
            />}
            offset
            setOffset
            currrentFetchCount={configuredConnectors->Array.map(Nullable.make)->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors(
            ~connectorType=ConnectorTypes.ThreeDsAuthenticator,
          )}
          connectorsAvailableForIntegration={featureFlagDetails.isLiveMode
            ? ConnectorUtils.threedsAuthenticatorListForLive
            : ConnectorUtils.threedsAuthenticatorList}
          urlPrefix="3ds-authenticators/new"
          connectorType=ConnectorTypes.ThreeDsAuthenticator
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

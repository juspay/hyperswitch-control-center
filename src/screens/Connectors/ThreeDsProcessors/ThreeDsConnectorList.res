@react.component
let make = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (
    filteredConnectorData: array<
      RescriptCore.Nullable.t<ConnectorTypes.connectorPayloadCommonType>,
    >,
    setFilteredConnectorData,
  ) = React.useState(_ => [])

  let connectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=AuthenticationProcessor,
  )

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
      let threeDsConnectorsList =
        connectorList->Array.filter(item => item.connector_type === AuthenticationProcessor)
      ConnectorUtils.sortByDisableField(threeDsConnectorsList, connectorPayload =>
        connectorPayload.disabled
      )

      setConfiguredConnectors(_ => threeDsConnectorsList)
      setFilteredConnectorData(_ => threeDsConnectorsList->Array.map(Nullable.make))
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
            actualData={filteredConnectorData}
            totalResults={filteredConnectorData->Array.length}
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
            showAutoScroll=true
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors={ConnectorInterface.mapConnectorPayloadToConnectorType(
            ConnectorInterface.connectorInterfaceV1,
            ConnectorTypes.ThreeDsAuthenticator,
            configuredConnectors,
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

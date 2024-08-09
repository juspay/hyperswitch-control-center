@react.component
let make = () => {
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let getConnectorList = async _ => {
    try {
      let response = await fetchConnectorListResponse()
      let connectorsList =
        response
        ->ConnectorListMapper.getArrayOfConnectorListPayloadType
        ->Array.filter(item =>
          item.connector_type->ConnectorUtils.connectorTypeStringToTypeMapper === PMAuthProcessor
        )

      setConfiguredConnectors(_ => connectorsList)
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
      title={"PM Authentication Processors"}
      subTitle={"Connect and configure open banking providers to verify customer bank accounts"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors(
            ~connectorType=ConnectorTypes.PMAuthenticationProcessor,
          )}
          connectorsAvailableForIntegration=ConnectorUtils.pmAuthenticationConnectorList
          urlPrefix="pm-authentication-processor/new"
          connectorType=ConnectorTypes.PMAuthenticationProcessor
        />
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={configuredConnectors->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={PMAuthenticationTableEntity.pmAuthenticationEntity(
              `pm-authentication-processor`,
              ~permission=userPermissionJson.connectorsManage,
            )}
            offset
            setOffset
            currrentFetchCount={configuredConnectors->Array.map(Nullable.make)->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}

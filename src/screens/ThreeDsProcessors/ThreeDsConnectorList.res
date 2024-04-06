@react.component
let make = () => {
  open UIUtils

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
          item.connector_type->ConnectorUtils.connectorTypeStringToTypeMapper ===
            AuthenticationProcessor
        )

      setConfiguredConnectors(_ => connectorsList)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect0(() => {
    getConnectorList()->ignore
    None
  })
  <div>
    <PageUtils.PageHeading
      title={"3DS Authentication Manager"}
      subTitle={"Connect and manage 3DS authentication providers to enhance the conversions"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors(
            ~connectorType=ConnectorTypes.ThreeDsAuthenticator,
          )}
          connectorsAvailableForIntegration=ConnectorUtils.threedsAuthenticatorList
          urlPrefix="3ds-authenticators/new"
          connectorType=ConnectorTypes.ThreeDsAuthenticator
        />
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={configuredConnectors->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={ThreeDsTableEntity.threeDsAuthenticatorEntity(
              `3ds-authenticators`,
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

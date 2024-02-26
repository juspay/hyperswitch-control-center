let detailedCardCount = 5

@react.component
let make = () => {
  open UIUtils

  let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let showConnectorIcons = configuredConnectors->Array.length > detailedCardCount
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let getConnectorList = async _ => {
    open ConnectorUtils
    try {
      let response = await fetchConnectorListResponse()
      let connectorsList =
        response->getProcessorsListFromJson(~removeFromList=ConnectorTypes.ThreeDsAuthenticator, ())
      let previousData = connectorsList->Array.map(ConnectorTableUtils.getProcessorPayloadType)
      setConfiguredConnectors(_ => previousData)
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
      title={"Three Ds Processors"}
      subTitle={"Connect and manage payout processors for disbursements and settlements"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors}
          showIcons={showConnectorIcons}
          connectorsAvailableForIntegration=ConnectorUtils.threedsAuthenticatorList
          showTestProcessor=false
          urlPrefix="threeds-processors/new"
        />
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Previously Connected"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={configuredConnectors->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={ConnectorTableUtils.connectorEntity(
              `connectors`,
              ~permission=userPermissionJson.merchantConnectorAccountWrite,
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

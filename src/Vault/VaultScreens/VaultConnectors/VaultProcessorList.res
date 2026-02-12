@react.component
let make = () => {
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let connectorListFromRecoil = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let requestAProcessorComponent = {
    <div className="-mt-8">
      <VaultProcessorCards.CantFindProcessor showRequestConnectorBtn=true />
    </div>
  }

  let getConnectorListAndUpdateState = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      connectorListFromRecoil->Array.reverse
      let list = ConnectorListInterface.mapConnectorPayloadToConnectorType(
        ConnectorListInterface.connectorInterfaceV2,
        ConnectorTypes.Processor,
        connectorListFromRecoil,
      )
      setConfiguredConnectors(_ => list)

      setFilteredConnectorData(_ => connectorListFromRecoil->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [connectorListFromRecoil->Array.length])

  let sendMixpanelEvent = () => {
    mixpanelEvent(~eventName="vault_view_connector_details")
  }

  let connectorsAvailableForIntegration = VaultConnectorUtils.connectorListForVault

  <PageLoaderWrapper screenState>
    <RenderIf condition={configuredConnectors->Array.length > 0}>
      <div className="mt-12">
        <LoadedTable
          title="Connected Processors"
          actualData=filteredConnectorData
          totalResults={filteredConnectorData->Array.length}
          resultsPerPage=20
          offset
          setOffset
          entity={VaultConnectorEntity.connectorEntity(
            "v2/vault/onboarding",
            ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            ~sendMixpanelEvent,
          )}
          currrentFetchCount={filteredConnectorData->Array.length}
          collapseTableRow=false
          rightTitleElement={requestAProcessorComponent}
          showAutoScroll=true
        />
      </div>
    </RenderIf>
    <RenderIf condition={configuredConnectors->Array.length == 0}>
      <div className="-mt-4">
        <VaultProcessorCards configuredConnectors connectorsAvailableForIntegration />
      </div>
    </RenderIf>
  </PageLoaderWrapper>
}

@react.component
let make = (~isOrchestrationVault=false) => {
  open Typography
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let connectorListFromRecoil = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )
  let connectorsAvailableForIntegration = VaultConnectorUtils.connectorListForVault
  let filteredconnectorListFromRecoil = connectorListFromRecoil->Array.filter(connector =>
    connectorsAvailableForIntegration
    ->Array.find(item =>
      item == ConnectorUtils.getConnectorNameTypeFromString(connector.connector_name)
    )
    ->Option.isSome
  )
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let requestAProcessorComponent = {
    <div className="-mt-8">
      <VaultProcessorCards.CantFindProcessor showRequestConnectorBtn=true isOrchestrationVault />
    </div>
  }

  let getConnectorListAndUpdateState = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      filteredconnectorListFromRecoil->Array.reverse
      let list = ConnectorListInterface.mapConnectorPayloadToConnectorType(
        ConnectorListInterface.connectorInterfaceV2,
        ConnectorTypes.Processor,
        filteredconnectorListFromRecoil,
      )
      setConfiguredConnectors(_ => list)

      setFilteredConnectorData(_ => filteredconnectorListFromRecoil->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [filteredconnectorListFromRecoil->Array.length])

  let sendMixpanelEvent = () => {
    mixpanelEvent(
      ~eventName={
        isOrchestrationVault
          ? "orchestration_vault_view_connector_details"
          : "vault_view_connector_details"
      },
    )
  }

  <div className="flex flex-col gap-4 mt-4">
    <PageLoaderWrapper screenState>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"When vaulting a card directly, you can also tokenize the cards at any of the following payment connectors by passing the corresponding Merchant Connector Id"->React.string}
      </p>
      <RenderIf condition={configuredConnectors->Array.length > 0}>
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
            ~isOrchestrationVault,
          )}
          currrentFetchCount={filteredConnectorData->Array.length}
          collapseTableRow=false
          rightTitleElement={!isOrchestrationVault ? requestAProcessorComponent : React.null}
          showAutoScroll=true
        />
      </RenderIf>
      <RenderIf condition={!isOrchestrationVault}>
        <VaultProcessorCards
          configuredConnectors connectorsAvailableForIntegration isOrchestrationVault
        />
      </RenderIf>
      <RenderIf condition={isOrchestrationVault}>
        <ProcessorCards
          configuredConnectors
          connectorsAvailableForIntegration
          urlPrefix="connectors/new"
          showDummyConnectorButton=false
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}

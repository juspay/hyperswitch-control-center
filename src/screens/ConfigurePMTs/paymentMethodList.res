@react.component
let make = (~isPayoutFlow=false) => {
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (offset, setOffset) = React.useState(_ => 0)

  let getConnectorListAndUpdateState = async () => {
    try {
      let response = await fetchConnectorListResponse()
      let removeFromList = isPayoutFlow ? ConnectorTypes.PayoutConnector : ConnectorTypes.FRMPlayer

      setConfiguredConnectors(_ =>
        response->PaymentMethodEntity.getPreviouslyConnectedList->Array.map(Nullable.make)
      )
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect1(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [isPayoutFlow])
  <div>
    <PageUtils.PageHeading
      title={`Configure PMTs at Checkout`}
      subTitle={"Control the visibility of your payment methods at the checkout"}
    />
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Configure PMTs"
        actualData=configuredConnectors
        totalResults={configuredConnectors->Array.length}
        resultsPerPage=20
        offset
        setOffset
        entity={PaymentMethodEntity.paymentMethodEntity(`connectors`)}
        currrentFetchCount={configuredConnectors->Array.length}
        collapseTableRow=false
      />
    </PageLoaderWrapper>
  </div>
}

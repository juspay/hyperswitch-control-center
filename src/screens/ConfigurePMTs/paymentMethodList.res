@react.component
let make = (~isPayoutFlow=false) => {
  open PaymentMethodConfigUtils
  open PaymentMethodEntity
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let _businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (connectorResponse, setConnectorResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let filters = UrlUtils.useGetFilterDictFromUrl("")
  let (filteredConnectors, setFiltersConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getConnectedList
  )
  let (_configuredConnectors, setConfiguredConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getConnectedList
  )
  let (offset, setOffset) = React.useState(_ => 0)
  let allFilters: PaymentMethodConfigTypes.paymentMethodConfigFilters = React.useMemo1(() => {
    filters->pmtConfigFilter
  }, [filters])
  let getConnectorListAndUpdateState = React.useCallback0(async () => {
    try {
      setScreenState(_ => Loading)
      let response = await fetchConnectorListResponse()
      let configuredConnectors = response->getConnectedList
      let filterdValue = response->getFilterdConnectorList(allFilters)
      setFiltersConnectors(_ => filterdValue)
      setConnectorResponse(_ => response)
      setConfiguredConnectors(_ => configuredConnectors)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  })

  React.useEffect1(() => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/configure-pmts"))
    getConnectorListAndUpdateState()->ignore
    None
  }, [isPayoutFlow])

  let applyFilter = async () => {
    setScreenState(_ => Loading)
    let res = connectorResponse->getFilterdConnectorList(allFilters)
    setFiltersConnectors(_ => res)
    await HyperSwitchUtils.delay(500)
    setScreenState(_ => Success)
  }

  React.useEffect1(() => {
    let {connectorId, profileId, paymentMethod, paymentMethodType} = allFilters
    if (
      connectorId->Option.isSome ||
      profileId->Option.isSome ||
      paymentMethod->Option.isSome ||
      paymentMethodType->Option.isSome
    ) {
      applyFilter()->ignore
    }
    None
  }, [allFilters])

  <div>
    <PageUtils.PageHeading
      title={`Configure PMTs at Checkout`}
      subTitle={"Control the visibility of your payment methods at the checkout"}
    />
    <PageLoaderWrapper screenState>
      <LoadedTable
        title=" "
        actualData={filteredConnectors->Array.map(Nullable.make)}
        totalResults={filteredConnectors->Array.length}
        resultsPerPage=20
        showSerialNumber=true
        offset
        setOffset
        entity={PaymentMethodEntity.paymentMethodEntity(
          ~setReferesh=getConnectorListAndUpdateState,
        )}
        currrentFetchCount={filteredConnectors->Array.length}
        collapseTableRow=false
      />
    </PageLoaderWrapper>
  </div>
}

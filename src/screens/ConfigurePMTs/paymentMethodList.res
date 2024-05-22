@react.component
let make = (~isPayoutFlow=false) => {
  open PaymentMethodConfigUtils
  open PaymentMethodEntity
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (connectorResponse, setConnectorResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (filteredConnectors, setFiltersConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getConnectedList
  )
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getConnectedList
  )
  let {updateExistingKeys, reset, filterValueJson} = FilterContext.filterContext->React.useContext
  let (offset, setOffset) = React.useState(_ => 0)
  let allFilters: PaymentMethodConfigTypes.paymentMethodConfigFilters = React.useMemo1(() => {
    filterValueJson->pmtConfigFilter
  }, [filterValueJson])
  let getConnectorListAndUpdateState = async () => {
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
  }

  React.useEffect2(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, (isPayoutFlow, filterValueJson))

  let applyFilter = async () => {
    let res = connectorResponse->getFilterdConnectorList(allFilters)
    setFiltersConnectors(_ => res)
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

  let handleClearFilter = async () => {
    await HyperSwitchUtils.delay(500)
    let dict = Dict.make()->pmtConfigFilter
    let res = connectorResponse->getFilterdConnectorList(dict)
    setFiltersConnectors(_ => res)
    reset()
  }

  <div>
    <PageUtils.PageHeading
      title={`Configure PMTs at Checkout`}
      subTitle={"Control the visibility of your payment methods at the checkout"}
    />
    <PageLoaderWrapper screenState>
      <Filter
        key="0"
        defaultFilters={Dict.make()->JSON.Encode.object}
        fixedFilters=[]
        requiredSearchFieldsList=[]
        localFilters={configuredConnectors->initialFilters(businessProfiles)}
        localOptions=[]
        remoteOptions=[]
        remoteFilters={configuredConnectors->initialFilters(businessProfiles)}
        defaultFilterKeys=[]
        updateUrlWith={updateExistingKeys}
        clearFilters={() => handleClearFilter()->ignore}
      />
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

@react.component
let make = (~isPayoutFlow=false) => {
  open PaymentMethodConfigUtils
  open PaymentMethodEntity
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (connectorResponse, setConnectorResponse) = React.useState(_ => [])
  let (filteredConnectors, setFiltersConnectors) = React.useState(_ => [])
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let {updateExistingKeys, reset, filterValueJson, filterValue} =
    FilterContext.filterContext->React.useContext
  let (offset, setOffset) = React.useState(_ => 0)
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let allFilters: PaymentMethodConfigTypes.paymentMethodConfigFilters = React.useMemo(() => {
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

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, (isPayoutFlow, filterValue))

  let applyFilter = async () => {
    let res = connectorResponse->getFilterdConnectorList(allFilters)
    setFiltersConnectors(_ => res)
  }

  React.useEffect(() => {
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
        localFilters={configuredConnectors->initialFilters([businessProfileRecoilVal], ~profileId)}
        localOptions=[]
        remoteOptions=[]
        remoteFilters={configuredConnectors->initialFilters([businessProfileRecoilVal], ~profileId)}
        defaultFilterKeys=[]
        updateUrlWith={updateExistingKeys}
        clearFilters={() => handleClearFilter()->ignore}
        setOffset
      />
      <div className="mt-4">
        <LoadedTable
          title="Payment Methods"
          hideTitle=true
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
          showAutoScroll=true
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

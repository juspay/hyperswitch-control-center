@react.component
let make = (~isPayoutFlow=false) => {
  open LogicUtils
  open FormRenderer
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (connectorResponse, setConnectorResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let filters = UrlUtils.useGetFilterDictFromUrl("")
  let (filteredConnectors, setFiltersConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->PaymentMethodEntity.getConnectedList
  )
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->PaymentMethodEntity.getConnectedList
  )
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (offset, setOffset) = React.useState(_ => 0)
  let allFilters: PaymentMethodConfigTypes.paymentMethodConfigFilters = React.useMemo1(() => {
    filters->PaymentMethodConfigUtils.pmtConfigFilter
  }, [filters])
  let getConnectorListAndUpdateState = React.useCallback0(async () => {
    try {
      let response = await fetchConnectorListResponse()
      let configuredConnectors = response->PaymentMethodEntity.getConnectedList
      let filterdValue = response->PaymentMethodEntity.getFilterdConnectorList(allFilters)
      setFiltersConnectors(_ => filterdValue)
      setConnectorResponse(_ => response)
      setConfiguredConnectors(_ => configuredConnectors)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  })

  React.useEffect1(() => {
    RescriptReactRouter.replace(`/configure-pmts`)
    getConnectorListAndUpdateState()->ignore
    None
  }, [isPayoutFlow])

  React.useEffect1(() => {
    let res = connectorResponse->PaymentMethodEntity.getFilterdConnectorList(allFilters)
    setFiltersConnectors(_ => res)
    None
  }, [allFilters])

  let handleClearFilter = _ => {
    RescriptReactRouter.replace(`/configure-pmts`)
    let dict = Dict.make()->PaymentMethodConfigUtils.pmtConfigFilter
    let res = connectorResponse->PaymentMethodEntity.getFilterdConnectorList(dict)
    setFiltersConnectors(_ => res)
  }

  let initialFilters: array<EntityType.initialFilters<'t>> = [
    {
      field: makeFieldInfo(
        ~label="Prfofile",
        ~name="profileId",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.profile_id)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Profile",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Connector",
        ~name="connectorId",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.merchant_connector_id)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Connector",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Payment Method",
        ~name="paymentMethod",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.payment_method)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Payment Method",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Payment Method Type",
        ~name="paymentMethodType",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.payment_method_type)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Payment Method Type",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
  ]
  <div>
    <PageUtils.PageHeading
      title={`Configure PMTs at Checkout`}
      subTitle={"Control the visibility of your payment methods at the checkout"}
    />
    <PageLoaderWrapper screenState>
      <div>
        <RemoteFilter
          remoteFilters=initialFilters
          requiredSearchFieldsList=[]
          localFilters=[]
          remoteOptions=[]
          localOptions=[]
          defaultFilters={
            let dict = Dict.make()
            JSON.Encode.object(dict)
          }
          refreshFilters=false
          clearFilters={handleClearFilter}
          hideFiltersDefaultValue=false
          autoApply=false
        />
      </div>
      <div>
        <LoadedTable
          title="Configure PMTs"
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
      </div>
    </PageLoaderWrapper>
  </div>
}

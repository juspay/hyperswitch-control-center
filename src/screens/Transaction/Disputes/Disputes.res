@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open DisputesUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (offset, setOffset) = React.useState(_ => 0)
  let (filters, setFilters) = React.useState(_ => None)

  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity, orgId, merchantId}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let startTime = filterValueJson->getString("start_time", "")

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([("start_time", {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([("end_time", {prevStartdate})]))
  }

  let getDisputesList = async () => {
    try {
      setScreenState(_ => Loading)
      if searchText->isNonEmptyString {
        filterValueJson->Dict.set("dispute_id", searchText->String.trim->JSON.Encode.string)
        filterValueJson->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
      }
      let queryParam =
        filterValueJson
        ->Dict.toArray
        ->Array.map(item => {
          let (key, value) = item
          let value = switch value->JSON.Classify.classify {
          | String(str) => str
          | Array(arr) => {
              let valueString = arr->getStrArrayFromJsonArray->Array.joinWith(",")
              valueString
            }
          | _ => ""
          }
          `${key}=${value}`
        })
        ->Array.joinWith("&")
      let disputesUrl = getURL(
        ~entityName=V1(DISPUTES),
        ~methodType=Get,
        ~queryParamerters=Some(queryParam),
      )
      let response = await fetchDetails(disputesUrl)
      let disputesValue = response->getArrayDataFromJson(DisputesEntity.itemToObjMapper)
      if disputesValue->Array.length > 0 {
        setDisputesData(_ => disputesValue->Array.map(Nullable.make))
        setScreenState(_ => Success)
      } else {
        setScreenState(_ => Custom)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      if err->String.includes("HE_02") {
        setScreenState(_ => Custom)
      } else {
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }
  React.useEffect(() => {
    if filters->isNonEmptyValue {
      getDisputesList()->ignore
    }
    None
  }, (filters, searchText))

  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />

  let filtersUI =
    <RemoteTableFilters
      setFilters
      endTimeFilterKey
      startTimeFilterKey
      initialFilters
      initialFixedFilter
      setOffset
      customLeftView={<SearchBarFilter
        placeholder="Search for dispute ID" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName=V1(DISPUTE_FILTERS)
      title="Disputes"
    />

  <div>
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Disputes" subTitle="View and manage all disputes" />
      <div className="flex gap-4">
        <Portal to="DisputesOMPView">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
            selectedEntity={transactionEntity}
            onChange={updateTransactionEntity}
            entityMapper=UserInfoUtils.transactionEntityMapper
          />
        </Portal>
        <RenderIf condition={generateReport && disputesData->Array.length > 0}>
          <GenerateReport entityName={V1(DISPUTE_REPORT)} />
        </RenderIf>
      </div>
    </div>
    <div className="grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6 my-8">
      <TransactionView entity=TransactionViewTypes.Disputes />
    </div>
    <div className="flex-1"> {filtersUI} </div>
    <PageLoaderWrapper screenState customUI>
      <div className="flex flex-col gap-4">
        <LoadedTableWithCustomColumns
          title="Disputes"
          hideTitle=true
          actualData=disputesData
          entity={DisputesEntity.disputesEntity(merchantId, orgId)}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={disputesData->Array.length}
          offset
          setOffset
          currrentFetchCount={disputesData->Array.length}
          defaultColumns={DisputesEntity.defaultColumns}
          customColumnMapper={TableAtoms.disputesMapDefaultCols}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          showAutoScroll=true
          isDraggable=true
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

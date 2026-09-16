open LogicUtils
open OffersTypes

@react.component
let make = () => {
  let fetchOffers = OffersHooks.useOffersList()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offersData, setOffersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (refetchCounter, setRefetchCounter) = React.useState(_ => 0)

  let resultsPerPage = 20
  let title = "Offers"

  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get(title)->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)

  let hasManageAccess = userHasAccess(~groupAccess=OperationsManage) === Access

  let refetch = () => setRefetchCounter(prev => prev + 1)

  let getOffers = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let response = await fetchOffers(
        ~limit=resultsPerPage,
        ~offset,
        ~filterValueJson,
        ~sortField=CreatedAtSort,
        ~sortOrder=Descending,
      )
      if response.list->isEmptyArray && offset > 0 {
        setOffset(_ => 0)
      } else if response.list->isNonEmptyArray {
        let padding = Array.make(~length=offset, Dict.make()->OffersUtils.itemToObjMapper)
        setTotalCount(_ => response.summary.totalCount)
        setOffersData(_ => padding->Array.concat(response.list)->Array.map(Nullable.make))
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to fetch offers")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getOffers()->ignore
    None
  }, (offset, filterValue, refetchCounter))

  let entity = OffersEntity.offersEntity(
    ~onStatusToggled=refetch,
    ~onDiscarded=refetch,
    ~hasManageAccess,
  )

  let customUI =
    <NoDataFound message="No offers found for the selected filters" renderType={Painting} />

  <div className="flex flex-col gap-4">
    <PageUtils.PageHeading
      title customHeadingStyle="mb-2" subTitle="View and manage offers for this merchant"
    />
    <div className="flex flex-row">
      <DynamicFilter
        title="OffersFilters"
        initialFilters={OffersFilters.initialFilters()}
        options=[]
        popupFilterFields={OffersFilters.popupFilterFields()}
        initialFixedFilters=[]
        defaultFilterKeys=[]
        tabNames=filterKeys
        key="OffersFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
    <PageLoaderWrapper screenState customUI>
      <LoadedTableWithCustomColumns
        title
        hideTitle=true
        actualData=offersData
        entity
        resultsPerPage
        totalResults=totalCount
        offset
        setOffset
        currentFetchCount={offersData->Array.length}
        customColumnMapper=TableAtoms.offersMapDefaultCols
        defaultColumns={OffersEntity.defaultColumns}
        showSerialNumber=true
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        showAutoScroll=true
        isDraggable=true
        visitedRows={{getId: offer => offer.offerId, prefix_key: "offer"}}
      />
    </PageLoaderWrapper>
  </div>
}

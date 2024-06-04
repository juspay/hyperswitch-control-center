@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open LogicUtils
  open PayoutsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (payoutData, setPayoutsData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Payouts")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)

  let fetchPayouts = () => {
    switch filters {
    | Some(dict) =>
      let filters = [("offset", offset->Int.toFloat->JSON.Encode.float)]->Dict.fromArray
      if !(searchText->isEmptyString) {
        filters->Dict.set("payout_id", searchText->String.trim->JSON.Encode.string)
      }

      dict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        filters->Dict.set(key, value)
      })

      filters
      ->getPayoutsList(
        ~updateDetails,
        ~setPayoutsData,
        ~setScreenState,
        ~offset,
        ~setOffset,
        ~setTotalCount,
        ~getURL,
      )
      ->ignore
    | _ => ()
    }
  }

  React.useEffect3(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchPayouts()
    }
    None
  }, (offset, filters, searchText))

  let filterUrl = getURL(~entityName=PAYOUTS, ~methodType=Get, ~id=Some("filter"), ())

  <ErrorBoundary>
    <div className="min-h-[50vh]">
      <PageUtils.PageHeading title="Payouts" subTitle="View and manage all payouts" />
      <div className="flex justify-between gap-3">
        <div className="flex-1">
          <RemoteTableFilters
            apiType=Fetch.Post
            filterUrl
            setFilters
            endTimeFilterKey
            startTimeFilterKey
            initialFilters
            initialFixedFilter
            setOffset
            customLeftView={<SearchBarFilter
              placeholder="Search payout id" setSearchVal=setSearchText searchVal=searchText
            />}
          />
        </div>
        <PortalCapture key={`PayoutsCustomizeColumn`} name={`PayoutsCustomizeColumn`} />
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          hideTitle=true
          title="Payouts"
          actualData=payoutData
          entity={PayoutsEntity.payoutEntity}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currrentFetchCount={payoutData->Array.length}
          defaultColumns={PayoutsEntity.defaultColumns}
          customColumnMapper=TableAtoms.payoutsMapDefaultCols
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          showResultsPerPageSelector=false
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}

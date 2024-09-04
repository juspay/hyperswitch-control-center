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
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Payouts")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userManagementRevamp} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchPayouts = () => {
    switch filters {
    | Some(dict) =>
      let filters = [("offset", offset->Int.toFloat->JSON.Encode.float)]->Dict.fromArray
      filters->Dict.set("limit", 20->Int.toFloat->JSON.Encode.float)
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

  React.useEffect(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchPayouts()
    }
    None
  }, (offset, filters, searchText))

  <ErrorBoundary>
    <div className="min-h-[50vh]">
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Payouts" subTitle="View and manage all payouts" />
        <RenderIf condition={userManagementRevamp}>
          <OMPSwitchHelper.OMPViews
            views={OrderUIUtils.orderViewList} onChange={updateTransactionEntity}
          />
        </RenderIf>
      </div>
      <div className="flex justify-between gap-3">
        <div className="flex-1">
          <RemoteTableFilters
            apiType=Post
            setFilters
            endTimeFilterKey
            startTimeFilterKey
            initialFilters
            initialFixedFilter
            setOffset
            customLeftView={<SearchBarFilter
              placeholder="Search payout id" setSearchVal=setSearchText searchVal=searchText
            />}
            entityName=PAYOUTS_FILTERS
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
          resultsPerPage=20
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currrentFetchCount={payoutData->Array.length}
          defaultColumns={PayoutsEntity.defaultColumns}
          customColumnMapper=TableAtoms.payoutsMapDefaultCols
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}

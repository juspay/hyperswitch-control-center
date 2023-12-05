@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open HSwitchUtils
  open RefundUtils
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (refundData, setRefundsData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)

  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Js.Dict.get("Refunds")->Belt.Option.getWithDefault(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)

  React.useEffect3(() => {
    switch filters {
    | Some(dict) =>
      let filters = Js.Dict.empty()

      filters->Js.Dict.set("offset", offset->Belt.Int.toFloat->Js.Json.number)
      if !(searchText->isEmptyString) {
        filters->Js.Dict.set("payment_id", searchText->Js.Json.string)
      }

      dict
      ->Js.Dict.entries
      ->Js.Array2.forEach(item => {
        let (key, value) = item
        filters->Js.Dict.set(key, value)
      })

      filters
      ->getRefundsList(
        ~updateDetails,
        ~setRefundsData,
        ~setScreenState,
        ~offset,
        ~setOffset,
        ~setTotalCount,
      )
      ->ignore
    | _ => ()
    }
    None
  }, (offset, filters, searchText))

  let {generateReport} =
    HyperswitchAtom.featureFlagAtom
    ->Recoil.useRecoilValueFromAtom
    ->LogicUtils.safeParse
    ->FeatureFlagUtils.featureFlagType

  <ErrorBoundary>
    <div className="flex flex-col overflow-y-auto min-h-[50vh]">
      <PageUtils.PageHeading title="Refunds" subTitle="View and manage all refunds" />
      <div className="flex w-full justify-end pb-3 gap-3">
        <UIUtils.RenderIf condition={generateReport}>
          <GenerateReport entityName={REFUND_REPORT} />
        </UIUtils.RenderIf>
      </div>
      <RemoteTableFilters
        placeholder="Search payment id"
        setSearchVal=setSearchText
        searchVal=searchText
        filterUrl={`${HSwitchGlobalVars.hyperSwitchApiPrefix}/refunds/filter`}
        setFilters
        endTimeFilterKey
        startTimeFilterKey
        initialFilters
        initialFixedFilter
        setOffset
      />
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          hideTitle=true
          title="Refunds"
          actualData=refundData
          entity={RefundEntity.refundEntity}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currrentFetchCount={refundData->Js.Array2.length}
          defaultColumns={RefundEntity.defaultColumns}
          customColumnMapper=RefundEntity.refundsMapDefaultCols
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          showResultsPerPageSelector=false
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}

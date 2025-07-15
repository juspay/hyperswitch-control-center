@react.component
let make = () => {
  open ReconEngineTransactionsUtils
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (exceptionData, setExceptionData) = React.useState(_ => [])
  let (filteredExceptionData, setFilteredExceptionData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReconEngineTransactionsTypes.transactionPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(obj.transaction_status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredExceptionData(_ => filteredList)
  }, ~wait=200)

  let getExceptionsTransactionsList = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~queryParamerters=Some("status=mismatched,expected"),
      )
      let res = await fetchDetails(url)
      let data = res->getDictFromJsonObject->getArrayFromDict("transactions", [])
      let exceptionList = data->getArrayOfTransactionsListPayloadType
      setExceptionData(_ => exceptionList->Array.map(Nullable.make))
      setFilteredExceptionData(_ => exceptionList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getExceptionsTransactionsList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <RenderIf condition={exceptionData->Array.length > 0}>
        <LoadedTableWithCustomColumns
          title="Exception Entries - Expected & Mismatched"
          actualData={filteredExceptionData}
          entity={TransactionsTableEntity.transactionsEntity(
            `v1/recon-engine/exceptions`,
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          resultsPerPage=10
          filters={<TableSearchFilter
            data={exceptionData}
            filterLogic
            placeholder="Search Exception ID or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/2 mt-8 mb-2"
            customInputBoxWidth="w-full rounded-xl "
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          totalResults={filteredExceptionData->Array.length}
          offset
          setOffset
          currrentFetchCount={exceptionData->Array.length}
          customColumnMapper=TableAtoms.reconTransactionsDefaultCols
          defaultColumns={TransactionsTableEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          customizeColumnButtonIcon="nd-filter-horizontal"
          hideRightTitleElement=true
          showAutoScroll=true
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}

@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open DisputesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (offset, setOffset) = React.useState(_ => 0)
  let (filters, setFilters) = React.useState(_ => None)

  let {generateReport, transactionView} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let getDisputesList = async () => {
    open LogicUtils
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
        ~entityName=DISPUTES,
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
      customCssClass={"my-6"} message="There are no disputes as of now" renderType=Painting
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
        placeholder="Search disptue id" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName=DISPUTE_FILTERS
      title="Disputes"
    />

  <div>
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Disputes" subTitle="View and manage all disputes" />
      <div className="flex gap-4">
        <OMPSwitchHelper.OMPViews
          views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
          selectedEntity={transactionEntity}
          onChange={updateTransactionEntity}
        />
        <RenderIf condition={generateReport && disputesData->Array.length > 0}>
          <GenerateReport entityName={DISPUTE_REPORT} />
        </RenderIf>
      </div>
    </div>
    <RenderIf condition={transactionView}>
      <div className="flex gap-6 justify-around">
        <TransactionView entity=TransactionViewTypes.Disputes />
      </div>
    </RenderIf>
    <div className="flex-1"> {filtersUI} </div>
    <PageLoaderWrapper screenState customUI>
      <div className="flex flex-col gap-4">
        <LoadedTableWithCustomColumns
          title="Disputes"
          hideTitle=true
          actualData=disputesData
          entity={DisputesEntity.disputesEntity}
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
        />
      </div>
    </PageLoaderWrapper>
  </div>
}

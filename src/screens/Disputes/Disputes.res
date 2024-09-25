@react.component
let make = () => {
  open APIUtils
  open PageLoaderWrapper
  open HSwitchRemoteFilter
  open DisputesUtils
  let getURL = useGetURL()
  let {globalUIConfig: {font: {textColor}, border: {borderColor}}} = React.useContext(
    ThemeProvider.themeContext,
  )
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchDetails = useGetMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (offset, setOffset) = React.useState(_ => 0)
  let (filters, setFilters) = React.useState(_ => None)

  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )

  let getDisputesList = async () => {
    try {
      setScreenState(_ => Loading)
      if searchText->LogicUtils.isNonEmptyString {
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
              let valueString = arr->LogicUtils.getStrArrayFromJsonArray->Array.joinWith(",")
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
      let disputesValue = response->LogicUtils.getArrayDataFromJson(DisputesEntity.itemToObjMapper)
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
    getDisputesList()->ignore
    None
  }, (filters, searchText))

  let customUI =
    <>
      <RenderIf condition={!branding}>
        <div
          className={`${borderColor.primaryNormal} flex  items-start  text-sm rounded-md gap-2 px-4 py-3 mt-5`}>
          <Icon name="info-vacent" className={`${textColor.primaryNormal} mt-1`} size=18 />
          <p>
            {"Missing disputes? Disputes might not be supported for your payment processor or might not yet have been integrated with hyperswitch. Please check the"->React.string}
            <a
              href="https://hyperswitch.io/pm-list"
              target="_blank"
              className={`${textColor.primaryNormal}`}>
              {" feature matrix "->React.string}
            </a>
            {"for your processor."->React.string}
          </p>
        </div>
      </RenderIf>
      <HelperComponents.BluredTableComponent
        infoText="No disputes as of now." moduleName=" " showRedirectCTA=false
      />
    </>

  <div>
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Disputes" subTitle="View and manage all disputes" />
      <OMPSwitchHelper.OMPViews
        views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
        selectedEntity={transactionEntity}
        onChange={updateTransactionEntity}
      />
    </div>
    <div className="flex w-full justify-end pb-3 gap-3">
      <RenderIf condition={generateReport && disputesData->Array.length > 0}>
        <GenerateReport entityName={DISPUTE_REPORT} />
      </RenderIf>
    </div>
    <div className="flex">
      <RemoteTableFilters
        setFilters
        endTimeFilterKey
        startTimeFilterKey
        initialFilters
        initialFixedFilter
        setOffset
        customLeftView={<SearchBarFilter
          placeholder="Search disptue id" setSearchVal=setSearchText searchVal=searchText //// dispute id
        />}
        entityName=DISPUTE_FILTERS
      />
    </div>
    <PageLoaderWrapper screenState customUI>
      <div className="flex flex-col gap-4">
        <LoadedTableWithCustomColumns
          title=" "
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

@react.component
let make = () => {
  open APIUtils
  open WebhooksUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (webhooksData, setWebhooksData) = React.useState(_ => [])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Webhooks")->Option.getOr(defaultValue)
  let (totalCount, setTotalCount) = React.useState(_ => 100) //TODO: to be extracted from API
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, reset, filterValue} =
    FilterContext.filterContext->React.useContext
  let businessProfileValues = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom
  let (searchText, setSearchText) = React.useState(_ => "")

  let webhookURL = switch businessProfileValues->Array.get(0) {
  | Some(val) => val.webhook_details.webhook_url->Option.getOr("")
  | None => ""
  }

  React.useEffect(() => {
    if filterValueJson->Dict.keysToArray->Array.length === 0 {
      setOffset(_ => 0)
    }
    None
  }, [])

  React.useEffect(() => {
    if filterValueJson->Dict.keysToArray->Array.length != 0 {
      setOffset(_ => 0)
    }
    None
  }, [filterValue])

  let initialDisplayFilters =
    []->Array.filter((item: EntityType.initialFilters<'t>) => item.localFilter->Option.isSome)

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~compareToStartTimeKey="",
    ~compareToEndTimeKey="",
    ~comparisonKey="",
    ~range=30,
    ~origin="orders",
    (),
  )

  React.useEffect(() => {
    fetchWebhooks(
      ~getURL,
      ~fetchDetails,
      ~filterValueJson,
      ~offset,
      ~setOffset,
      ~searchText,
      ~setScreenState,
      ~setWebhooksData,
      ~setTotalCount,
    )->ignore
    if filterValueJson->Dict.keysToArray->Array.length < 1 {
      setInitialFilters()
    }
    None
  }, (filterValueJson, offset, searchText))

  let filtersUI = React.useMemo(() => {
    <Filter
      key="0"
      title="Webhooks"
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter()}
      requiredSearchFieldsList=[]
      localFilters={initialDisplayFilters}
      localOptions=[]
      remoteOptions=[]
      remoteFilters=[]
      autoApply=false
      submitInputOnEnter=true
      defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
      updateUrlWith={updateExistingKeys}
      customLeftView={<HSwitchRemoteFilter.SearchBarFilter
        placeholder="Search for object ID" setSearchVal=setSearchText searchVal=searchText
      />}
      clearFilters={() => reset()}
    />
  }, [])

  let refreshPage = () => {
    reset()
    Window.Location.reload()
  }

  let isWebhookUrlConfigured = webhookURL !== ""

  let message = isWebhookUrlConfigured
    ? "No data found, try searching with different filters or try refreshing using the button below"
    : "Webhook UI is not configured please do it from payment settings"

  let customUI =
    <NoDataFound message renderType=Painting>
      <RenderIf condition={isWebhookUrlConfigured}>
        <div className="m-2">
          <Button text="Refresh" buttonType=Primary onClick={_ => refreshPage()} />
        </div>
      </RenderIf>
    </NoDataFound>

  <>
    <PageUtils.PageHeading title="Webhooks" subTitle="" />
    {filtersUI}
    <PageLoaderWrapper screenState customUI>
      <LoadedTable
        title=" "
        actualData={webhooksData->Array.map(Nullable.make)}
        totalResults=totalCount
        resultsPerPage=20
        entity={WebhooksTableEntity.webhooksEntity(
          `webhooks`,
          ~authorization=userHasAccess(~groupAccess=AccountManage),
        )}
        hideTitle=true
        offset
        setOffset
        currrentFetchCount={webhooksData->Array.map(Nullable.make)->Array.length}
        collapseTableRow=false
        showSerialNumber=true
      />
    </PageLoaderWrapper>
  </>
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open WebhooksUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (data, setData) = React.useState(_ => [])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Webhooks")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson} = FilterContext.filterContext->React.useContext
  let businessProfileValues = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom

  let webhookURL = switch businessProfileValues->Array.get(0) {
  | Some(val) => val.webhook_details.webhook_url->Option.getOr("")
  | None => ""
  }

  let fetchWebhooks = async () => {
    try {
      let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
      let start_time = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
      let end_time = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

      let queryParamerters = `limit=50&offset=${offset->Int.toString}&created_after=${start_time}&created_before=${end_time}`

      setScreenState(_ => Loading)
      let url = getURL(
        ~entityName=WEBHOOK_EVENTS,
        ~methodType=Get,
        ~queryParamerters=Some(queryParamerters),
      )
      let response = await fetchDetails(url)
      setData(_ => response->getArrayDataFromJson(WebhooksUtils.itemToObjectMapper))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

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
    fetchWebhooks()->ignore
    None
  }, [])

  React.useEffect(() => {
    if filterValueJson->Dict.keysToArray->Array.length < 1 {
      setInitialFilters()
    }
    None
  }, [filterValueJson])

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
    />
  }, [])

  <>
    <PageUtils.PageHeading title="Webhooks" subTitle="" />
    <PageLoaderWrapper screenState>
      {filtersUI}
      <LoadedTable
        title=" "
        actualData={data->Array.map(Nullable.make)}
        totalResults={data->Array.length}
        resultsPerPage=20
        entity={WebhooksTableEntity.webhooksEntity(
          `webhooks`,
          ~authorization=userHasAccess(~groupAccess=AccountManage),
        )}
        hideTitle=true
        offset
        setOffset
        currrentFetchCount={data->Array.map(Nullable.make)->Array.length}
        collapseTableRow=false
        showSerialNumber=true
        noDataMsg={webhookURL === ""
          ? "Webhook UI is not configured please do it from payment settings"
          : "No data found"}
      />
    </PageLoaderWrapper>
  </>
}

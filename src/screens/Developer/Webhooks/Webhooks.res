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
  let (totalCount, setTotalCount) = React.useState(_ => 0)
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

  let isWebhookUrlConfigured = webhookURL->LogicUtils.isNonEmptyString

  let message = isWebhookUrlConfigured
    ? "No data found, try searching with different filters or try refreshing using the button below"
    : "Webhook UI is not configured please do it from payment settings"

  let refreshPage = () => {
    reset()
  }

  let customUI =
    <NoDataFound message renderType=Painting>
      <RenderIf condition={isWebhookUrlConfigured}>
        <div className="m-2">
          <Button text="Refresh" buttonType=Primary onClick={_ => refreshPage()} />
        </div>
      </RenderIf>
    </NoDataFound>

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

  let setData = (~total, ~data) => {
    let arr = Array.make(~length=offset, Dict.make())
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let webhookDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let webhookData =
        arr
        ->Array.concat(webhookDictArr)
        ->Array.map(itemToObjectMapper)

      let list = webhookData
      setTotalCount(_ => total)
      setWebhooksData(_ => list)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let fetchWebhooks = async () => {
    open LogicUtils
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
      let start_time = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
      let end_time = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

      let queryParamerters = `limit=50&offset=${offset->Int.toString}&created_after=${start_time}&created_before=${end_time}`

      let queryParam = searchText->isEmptyString ? queryParamerters : `&object_id=${searchText}`

      let url = getURL(
        ~entityName=V1(WEBHOOK_EVENTS),
        ~methodType=Get,
        ~queryParamerters=Some(queryParam),
      )
      let response = await fetchDetails(url)

      let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
      let events = response->getDictFromJsonObject->getArrayFromDict("events", [])

      if !isWebhookUrlConfigured || events->Array.length <= 0 {
        setScreenState(_ => Custom)
      } else {
        setData(~total=totalCount, ~data=events)
        setScreenState(_ => Success)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    fetchWebhooks()->ignore
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

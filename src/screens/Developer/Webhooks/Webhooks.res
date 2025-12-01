@react.component
let make = () => {
  open APIUtils
  open WebhooksUtils
  open LogicUtils
  open WebhooksTypes
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (webhooksData, setWebhooksData) = React.useState(_ => [])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Webhooks")->Option.getOr(defaultValue)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, reset} = FilterContext.filterContext->React.useContext
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (searchText, setSearchText) = React.useState(_ => "")
  let (lastFilterState, setLastFilterState) = React.useState(_ => "")

  let webhookURL = businessProfileRecoilVal.webhook_details.webhook_url->Option.getOr("")

  let isWebhookUrlConfigured = webhookURL->LogicUtils.isNonEmptyString

  let message = isWebhookUrlConfigured
    ? "No data found, try searching with different filters or try refreshing using the button below"
    : "Webhook URL is not configured. Please set it up in the Payment Settings"

  let refreshPage = () => {
    reset()
  }

  let convertToSearchType = (value: string): searchType => {
    switch value {
    | "object_id" => ObjectId
    | "event_id" => EventId
    | _ => ObjectId
    }
  }

  let searchTypeToString = (search_type: searchType): string =>
    switch search_type {
    | ObjectId => "object_id"
    | EventId => "event_id"
    }

  let customUI =
    <NoDataFound message renderType=Painting>
      <RenderIf condition={isWebhookUrlConfigured}>
        <div className="m-2">
          <Button text="Refresh" buttonType=Primary onClick={_ => refreshPage()} />
        </div>
      </RenderIf>
    </NoDataFound>

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
    let shouldAddOffset = searchText->isEmptyString
    let arr = shouldAddOffset ? Array.make(~length=offset, Dict.make()) : []

    if total <= offset && shouldAddOffset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let webhookDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let webhookData = arr->Array.concat(webhookDictArr)->Array.map(itemToObjectMapper)
      setTotalCount(_ => total)
      setWebhooksData(_ => webhookData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setTotalCount(_ => 0)
      setWebhooksData(_ => [])
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let fetchWebhooks = async (~searchType: searchType) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
      let start_time = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
      let end_time = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

      let payload = Dict.make()
      if searchText->isNonEmptyString {
        payload->Dict.set(searchTypeToString(searchType), searchText->JSON.Encode.string)
      } else {
        payload->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
        payload->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        payload->Dict.set("created_after", start_time->JSON.Encode.string)
        payload->Dict.set("created_before", end_time->JSON.Encode.string)
      }

      let url = getURL(~entityName=V1(WEBHOOK_EVENTS), ~methodType=Post)
      let response = await updateDetails(url, payload->JSON.Encode.object, Post)

      let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
      let events = response->getDictFromJsonObject->getArrayFromDict("events", [])

      setData(~total=totalCount, ~data=events)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    let currentFilterState = {
      let filterDict = Dict.make()
      filterValueJson
      ->Dict.toArray
      ->Array.forEach(((key, value)) => {
        if key !== "offset" && key !== "limit" {
          filterDict->Dict.set(key, value)
        }
      })
      filterDict->JSON.Encode.object->JSON.stringify
    }

    if currentFilterState !== lastFilterState && searchText === "" {
      setLastFilterState(_ => currentFilterState)
      if offset !== 0 {
        setOffset(_ => 0)
      } else {
        fetchWebhooks(~searchType=ObjectId)->ignore
      }
    } else {
      fetchWebhooks(~searchType=ObjectId)->ignore
    }

    if filterValueJson->Dict.keysToArray->Array.length < 1 {
      setInitialFilters()
    }
    None
  }, (filterValueJson, offset))

  let filtersUI =
    <Filter
      key="0"
      title="Webhooks"
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter()}
      requiredSearchFieldsList=[]
      localFilters=[]
      localOptions=[]
      remoteOptions=[]
      remoteFilters=[]
      autoApply=false
      submitInputOnEnter=true
      defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
      updateUrlWith={updateExistingKeys}
      clearFilters={() => reset()}
      customLeftView={<SearchInput
        onChange={value => setSearchText(_ => value)}
        inputText=searchText
        placeholder="Search by ID"
        showTypeSelector=true
        typeSelectorOptions=[
          {label: "Object ID", value: "object_id"},
          {label: "Event ID", value: "event_id"},
        ]
        onSubmitSearchDropdown={value => {
          let searchTypeValue = convertToSearchType(value->Option.getOr("object_id"))
          if searchText->isNonEmptyString {
            setOffset(_ => 0)
          }
          fetchWebhooks(~searchType=searchTypeValue)->ignore
        }}
        widthClass="w-max"
        showSearchIcon=true
      />}
    />

  <>
    <PageUtils.PageHeading title="Webhooks" subTitle="" />
    <div className="-mb-6"> {filtersUI} </div>
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
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  </>
}

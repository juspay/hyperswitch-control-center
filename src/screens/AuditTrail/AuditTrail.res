@react.component
let make = () => {
  open APIUtils
  open AuditTrailUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (activityData, setActivityData) = React.useState(_ => [])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("AuditTrail")->Option.getOr(defaultValue)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, reset} = FilterContext.filterContext->React.useContext
  let lastFiltersSignature = React.useRef("")

  let customUI =
    <NoDataFound message="No activity found for the selected time range" renderType=Painting>
      <div className="m-2">
        <Button text="Refresh" buttonType=Primary onClick={_ => reset()} />
      </div>
    </NoDataFound>

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~compareToStartTimeKey="",
    ~compareToEndTimeKey="",
    ~comparisonKey="",
    ~range=7,
    ~origin="audit-trail",
    (),
  )

  let setData = (~total, ~data) => {
    let arr = Array.make(~length=offset, Dict.make())

    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let dataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let activityLogs = arr->Array.concat(dataDictArr)->Array.map(itemToObjMapper)
      setTotalCount(_ => total)
      setActivityData(_ => activityLogs)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setTotalCount(_ => 0)
      setActivityData(_ => [])
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let fetchActivityLogs = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=7)
      let startTime = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
      let endTime = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

      let timeRange = Dict.make()
      timeRange->Dict.set("startTime", startTime->JSON.Encode.string)
      timeRange->Dict.set("endTime", endTime->JSON.Encode.string)

      let payload = Dict.make()
      payload->Dict.set("timeRange", timeRange->JSON.Encode.object)
      payload->Dict.set("limit", 20->Int.toFloat->JSON.Encode.float)
      payload->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)

      let url = getURL(~entityName=V1(ORG_ACTIVITY_LOGS), ~methodType=Post)
      let response = await updateDetails(url, payload->JSON.Encode.object, Post)

      let total = response->getDictFromJsonObject->getInt("totalCount", 0)
      let logs = response->getDictFromJsonObject->getArrayFromDict("activityLogs", [])

      setData(~total, ~data=logs)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    if filterValueJson->isEmptyDict {
      setInitialFilters()
    } else {
      let currentFilterState = {
        let filterDict = Dict.make()
        filterValueJson
        ->Dict.toArray
        ->Array.forEach(((key, value)) => filterDict->Dict.set(key, value))
        filterDict->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        filterDict->JSON.Encode.object->JSON.stringify
      }

      if currentFilterState !== lastFiltersSignature.current {
        lastFiltersSignature.current = currentFilterState
        fetchActivityLogs()->ignore
      }
    }
    None
  }, (filterValueJson, offset))

  let filtersUI =
    <Filter
      key="0"
      title="Audit Trail"
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter()}
      requiredSearchFieldsList=[]
      localFilters=[]
      localOptions=[]
      remoteOptions=[]
      remoteFilters=[]
      autoApply=false
      defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
      updateUrlWith={updateExistingKeys}
      clearFilters={() => reset()}
    />

  <>
    <PageUtils.PageHeading
      title="Audit Trail" subTitle="Track who changed what across your organization"
    />
    <div className="-mb-6"> {filtersUI} </div>
    <PageLoaderWrapper screenState customUI>
      <LoadedTable
        title=" "
        actualData={activityData->Array.map(Nullable.make)}
        totalResults=totalCount
        resultsPerPage=20
        entity={AuditTrailEntity.auditTrailEntity}
        hideTitle=true
        offset
        setOffset
        currentFetchCount={activityData->Array.map(Nullable.make)->Array.length}
        collapseTableRow=false
        showSerialNumber=true
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  </>
}

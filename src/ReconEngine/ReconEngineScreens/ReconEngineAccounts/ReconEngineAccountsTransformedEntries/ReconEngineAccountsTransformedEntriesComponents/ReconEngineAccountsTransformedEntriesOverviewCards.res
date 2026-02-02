@react.component
let make = (~selectedTransformationHistoryId: option<string>) => {
  open LogicUtils
  open ReconEngineAccountsTransformedEntriesUtils
  open ReconEngineHooks
  open ReconEngineAccountsTransformedEntriesTypes

  let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (stagingData, setStagingData) = React.useState(_ => [
    Dict.make()->getProcessingEntryPayloadFromDict,
  ])
  let (activeView: transformedEntriesViewType, setActiveView) = React.useState(_ =>
    UnknownTransformedEntriesViewType
  )
  let getProcessingEntries = useGetProcessingEntries()

  let customFilterKey = "status"

  let updateViewsFilterValue = (view: transformedEntriesViewType) => {
    let statusFilter = view->getViewStatusFilter
    if statusFilter->isNonEmptyString {
      let customFilter = `[${statusFilter}]`
      updateExistingKeys(Dict.fromArray([(customFilterKey, customFilter)]))

      if !(filterKeys->Array.includes(customFilterKey)) {
        filterKeys->Array.push(customFilterKey)
        setfilterKeys(_ => filterKeys)
      }
    }
  }

  let onViewClick = (view: transformedEntriesViewType) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let fetchStagingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = switch selectedTransformationHistoryId {
      | Some(id) => Some(`transformation_history_id=${id}`)
      | None => None
      }
      let stagingList = await getProcessingEntries(~queryParameters=queryParams)

      setStagingData(_ => stagingList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let settingActiveView = () => {
    let appliedStatusFilter = filterValueJson->LogicUtils.getArrayFromDict(customFilterKey, [])

    if appliedStatusFilter->Array.length == 0 {
      setActiveView(_ => UnknownTransformedEntriesViewType)
    }
  }

  React.useEffect(() => {
    fetchStagingData()->ignore
    None
  }, [])

  React.useEffect(() => {
    settingActiveView()
    None
  }, [filterKeys])

  <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mt-2">
    {cardDetails(~stagingData)
    ->Array.map(card => {
      let isClickable = card.viewType !== UnknownTransformedEntriesViewType
      let isActive = isClickable && card.viewType === activeView
      <PageLoaderWrapper
        key={randomString(~length=10)}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-28" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-28 rounded-xl" />}>
        <ReconEngineAccountsTransformedEntriesHelper.TransformedEntriesOverviewCard
          title={card.title}
          value={card.value}
          onClick={isClickable ? Some(() => onViewClick(card.viewType)) : None}
          isActive={isActive}
        />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}

@react.component
let make = () => {
  open RoutingAnalyticsSummaryEntity
  open RoutingAnalyticsSummaryTypes
  open APIUtils
  open Typography
  open LogicUtils
  let expand = -1
  let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
  let heading = summaryMainColumns->Array.map(colType => getSummaryMainHeading(colType))
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Post, ~id=Some("routing"))

      let groupByRoutingApproachAndConnectorBody =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~groupByNames=Some(["connector", "routing_approach"]),
            ~source="BATCH",
            ~metrics=Some(["payment_count", "payment_processed_amount", "payment_success_rate"]),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let groupByRoutingApproachBody =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~groupByNames=Some(["routing_approach"]),
            ~source="BATCH",
            ~metrics=Some(["payment_count", "payment_processed_amount", "payment_success_rate"]),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, groupByRoutingApproachAndConnectorBody, Post)
      let responseRouting = await updateDetails(url, groupByRoutingApproachBody, Post)

      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let responseRoutingData =
        responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length > 0 || responseRoutingData->Array.length > 0 {
        let hi = RoutingAnalyticsSummaryUtils.processRoutingAnalyticsSummaryResponse(
          ~dataConnector=response,
          ~dataRouting=responseRouting,
        )
        setData(_ => hi)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(_ => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, [startTimeVal, endTimeVal])

  React.useEffect(() => {
    if expand != -1 {
      setExpandedRowIndexArray(_ => [expand])
    }
    None
  }, [expand])

  let onExpandClick = idx => {
    setExpandedRowIndexArray(_ => {
      [idx]
    })
  }

  let collapseClick = idx => {
    let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
    setExpandedRowIndexArray(_ => {
      let array = expandedRowIndexArray->Array.map(item => item)
      array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])

      array
    })
  }

  let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
    if isCurrentRowExpanded {
      collapseClick(rowIndex)
    } else {
      onExpandClick(rowIndex)
    }
  }

  let rows = data->Array.map(item => {
    summaryMainColumns->Array.map(colType => getSummaryMainCell(item, colType))
  })

  let getRowDetails = rowIndex => {
    let data = data[rowIndex]
    switch data {
    | Some(data) =>
      <LoadedTable
        title=" "
        actualData={data.connectors->Array.map(Nullable.make)}
        totalResults={data.connectors->Array.length}
        resultsPerPage=20
        offset=0
        setOffset={_ => ()}
        entity={connectorEntity()}
        currrentFetchCount={data.connectors->Array.length}
        showHeading=false
        hideTitle=true
        enableEqualWidthCol=true
      />

    | _ => React.null
    }
  }

  <div>
    <PageUtils.PageHeading
      title="Summary"
      customHeadingStyle="flex flex-col mb-6"
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
    />
    <PageLoaderWrapper
      screenState
      customUI={<InsightsHelper.NoData />}
      customLoader={<Shimmer styleClass="w-full h-96" />}>
      <CustomExpandableTable
        title=" "
        heading
        rows={rows}
        onExpandIconClick={onExpandIconClick}
        expandedRowIndexArray={expandedRowIndexArray}
        getRowDetails
        showSerial={false}
        fullWidth=true
        tableClass="border rounded-xl"
        borderClass=" "
        firstColRoundedHeadingClass="rounded-tl-xl"
        lastColRoundedHeadingClass="rounded-tr-xl"
        headingBgColor="bg-nd_gray-25"
        headingFontWeight="font-semibold"
        headingFontColor="text-nd_gray-400"
        rowFontColor="text-nd_gray-700"
        rowFontSize="text-md"
        rowFontStyle="font-medium"
      />
    </PageLoaderWrapper>
  </div>
}

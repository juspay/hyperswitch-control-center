module RowDetailsComponent = {
  @react.component
  let make = (~rowIndex, ~data, ~rows) => {
    open RoutingAnalyticsSummaryEntity
    open RoutingAnalyticsSummaryTypes
    open Typography

    switch data->Array.get(rowIndex) {
    | Some(data) =>
      let tableCellArray = data.connectors->Array.map(connectorDetails => {
        connectorCols->Array.map(colType => getConnectorCell(connectorDetails, colType))
      })
      let isLastRow = rowIndex == rows->Array.length - 1

      {
        tableCellArray
        ->Array.map(item => {
          <tr className="group h-full bg-nd_gray-25 text-nd_gray-700 ">
            {item
            ->Array.mapWithIndex((obj, cellIndex) => {
              let isFirstCell = cellIndex === 0
              let isLastCell = cellIndex === item->Array.length - 1
              let roundedClass = if isLastRow {
                if isFirstCell {
                  "rounded-bl-xl"
                } else if isLastCell {
                  "rounded-br-xl"
                } else {
                  ""
                }
              } else {
                ""
              }

              <td
                className={`h-full p-0 align-top border-t border-jp-gray-500 dark:border-jp-gray-960 ${body.md.medium} ${roundedClass} text-nd_gray-700`}>
                <div className="box-border px-4 py-3">
                  <Table.TableCell cell=obj />
                </div>
              </td>
            })
            ->React.array}
          </tr>
        })
        ->React.array
      }

    | _ => React.null
    }
  }
}

@react.component
let make = () => {
  open RoutingAnalyticsSummaryEntity
  open APIUtils
  open Typography
  open LogicUtils
  let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
  let heading = summaryMainColumns->Array.map(colType => getSummaryMainHeading(colType))
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
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
            ~filter=Some(filterValueJson->JSON.Encode.object),
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
            ~filter=Some(filterValueJson->JSON.Encode.object),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, groupByRoutingApproachAndConnectorBody, Post)
      let responseRouting = await updateDetails(url, groupByRoutingApproachBody, Post)

      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let responseRoutingData =
        responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length > 0 || responseRoutingData->Array.length > 0 {
        let typedData = RoutingAnalyticsSummaryUtils.mapToTableData(
          ~responseConnector=response,
          ~responseRouting,
        )
        setData(_ => typedData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching data"))
    }
  }

  React.useEffect(_ => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, filterValue))

  let onExpandClick = idx => {
    setExpandedRowIndexArray(_ => [idx])
  }

  let collapseClick = idx => {
    setExpandedRowIndexArray(prev => {
      let indexOfRemovalItem = prev->Array.findIndex(item => item === idx)
      if indexOfRemovalItem === -1 {
        prev
      } else {
        let newArray = prev->Array.slice(~start=0, ~end=Array.length(prev))
        newArray->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])
        newArray
      }
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

  <div>
    <PageUtils.PageHeading
      title="Routing Logic Performance Summary"
      subTitle="Deep-dive into the performance of various routing strategies with auth rate comparison
"
      customHeadingStyle="flex flex-col mb-6"
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
      customSubTitleStyle={`${body.md.medium} text-nd_gray-400 !opacity-100 !mt-1`}
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
        getRowDetails={rowindex => <RowDetailsComponent rowIndex=rowindex data rows />}
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
        customRowStyle="text-sm"
        rowFontStyle="font-medium"
        isLastRowRounded=true
        rowComponentInCell=false
      />
    </PageLoaderWrapper>
  </div>
}

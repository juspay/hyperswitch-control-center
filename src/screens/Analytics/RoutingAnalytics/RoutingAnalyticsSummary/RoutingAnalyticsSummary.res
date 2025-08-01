module RowDetailsComponent = {
  @react.component
  let make = (~rowIndex, ~data) => {
    open RoutingAnalyticsSummaryEntity
    open RoutingAnalyticsSummaryTypes
    open Typography

    switch data->Array.get(rowIndex) {
    | Some(data) =>
      let childRows = data.connectors->Array.map(connectorDetails => {
        summaryMainColumns->Array.map(colType => {
          switch colType {
          | RoutingLogic => getConnectorCell(connectorDetails, ConnectorName)
          | TrafficPercentage => getConnectorCell(connectorDetails, TrafficPercentage)
          | NoOfPayments => getConnectorCell(connectorDetails, NoOfPayments)
          | AuthorizationRate => getConnectorCell(connectorDetails, AuthorizationRate)
          | ProcessedAmount => getConnectorCell(connectorDetails, ProcessedAmount)
          }
        })
      })

      <div className="w-full">
        {childRows
        ->Array.mapWithIndex((row, index) => {
          <div
            key={index->Int.toString}
            className={`bg-nd_gray-25 text-nd_gray-700 ${body.md.medium} border-t border-jp-gray-500 dark:border-jp-gray-960`}>
            <div className="grid grid-cols-5">
              {row
              ->Array.mapWithIndex((cell, cellIndex) => {
                <div key={cellIndex->Int.toString} className={`px-4 py-3`}>
                  <Table.TableCell cell />
                </div>
              })
              ->React.array}
            </div>
          </div>
        })
        ->React.array}
      </div>

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
      <div className="border border-gray-200 rounded-xl overflow-hidden">
        <table className="w-full table-auto">
          <thead>
            <tr className="bg-gray-50">
              {heading
              ->Array.mapWithIndex((item, i) => {
                let isFirstCol = i === 0
                let isLastCol = i === heading->Array.length - 1
                let roundedClass = if isFirstCol {
                  "rounded-tl-xl"
                } else if isLastCol {
                  "rounded-tr-xl"
                } else {
                  ""
                }
                <th
                  key={i->Int.toString}
                  className={`px-4 py-3 text-sm font-medium text-gray-600 ${roundedClass}`}>
                  {item.title->React.string}
                </th>
              })
              ->React.array}
            </tr>
          </thead>
          <tbody>
            {rows
            ->Array.mapWithIndex((row, rowIndex) => {
              let isExpanded = expandedRowIndexArray->Array.includes(rowIndex)
              let modifiedRow = row->Array.mapWithIndex((cell, cellIndex) => {
                if cellIndex === 0 {
                  // Add caret icon to the first cell
                  Table.CustomCell(
                    <div className="flex items-center gap-2">
                      <Icon
                        name={isExpanded ? "caret-down" : "caret-right"}
                        size=14
                        className="text-gray-500"
                      />
                      <Table.TableCell cell />
                    </div>,
                    "",
                  )
                } else {
                  cell
                }
              })
              <>
                <Table.TableRow
                  item=modifiedRow
                  rowIndex
                  title=""
                  onRowClick=Some(_ => onExpandIconClick(isExpanded, rowIndex))
                  onRowDoubleClick=None
                  onRowClickPresent=true
                  offset=0
                  removeVerticalLines=true
                  highlightSelectedRow=false
                  removeHorizontalLines=false
                  evenVertivalLines=false
                  highlightEnabledFieldsArray={[]}
                  expandedRow={_ => React.null}
                  onMouseEnter=None
                  onMouseLeave=None
                  highlightText=""
                  rowCustomClass={`bg-white text-gray-700 text-sm font-normal hover:bg-gray-50 cursor-pointer border-b border-gray-100`}
                  alignCellContent="px-4 py-3 text-left"
                  collapseTableRow=false
                  fixedWidthClass=""
                  selectedIndex=0
                  setSelectedIndex={_ => ()}
                />
                {if isExpanded {
                  data
                  ->Array.get(rowIndex)
                  ->Option.map(data => {
                    data.connectors
                    ->Array.mapWithIndex(
                      (connector, connectorIndex) => {
                        let connectorRow = summaryMainColumns->Array.mapWithIndex(
                          (colType, cellIndex) => {
                            let cell = switch colType {
                            | RoutingLogic => getConnectorCell(connector, ConnectorName)
                            | TrafficPercentage => getConnectorCell(connector, TrafficPercentage)
                            | NoOfPayments => getConnectorCell(connector, NoOfPayments)
                            | AuthorizationRate => getConnectorCell(connector, AuthorizationRate)
                            | ProcessedAmount => getConnectorCell(connector, ProcessedAmount)
                            }
                            cell
                          },
                        )
                        <Table.TableRow
                          item=connectorRow
                          rowIndex={connectorIndex}
                          title=""
                          onRowClick=None
                          onRowDoubleClick=None
                          onRowClickPresent=false
                          offset=0
                          removeVerticalLines=true
                          highlightSelectedRow=false
                          removeHorizontalLines=false
                          evenVertivalLines=false
                          highlightEnabledFieldsArray={[]}
                          expandedRow={_ => React.null}
                          onMouseEnter=None
                          onMouseLeave=None
                          highlightText=""
                          rowCustomClass={`bg-gray-50 text-gray-700 text-sm font-normal border-b border-gray-100`}
                          alignCellContent="px-4 py-3 text-left"
                          fixedWidthClass=""
                          selectedIndex=0
                          setSelectedIndex={_ => ()}
                        />
                      },
                    )
                    ->React.array
                  })
                  ->Option.getOr(React.null)
                } else {
                  React.null
                }}
              </>
            })
            ->React.array}
          </tbody>
        </table>
      </div>
    </PageLoaderWrapper>
  </div>
}

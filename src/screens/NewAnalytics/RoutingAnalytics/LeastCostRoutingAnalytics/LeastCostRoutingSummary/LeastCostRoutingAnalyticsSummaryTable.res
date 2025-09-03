@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open Typography
  open PageLoaderWrapper
  open LeastCostRoutingAnalyticsTypes

  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let defaultSummaryMain: LeastCostRoutingAnalyticsSummaryTableTypes.summaryMain = {
    signature_network: "",
    card_network: "",
    traffic_percentage: 0.0,
    debit_routed_transaction_count: 0,
    regulated_transaction_percentage: 0.0,
    unregulated_transaction_percentage: 0.0,
    debit_routing_savings: 0.0,
  }
  let (tableData, setTableData) = React.useState(_ => [defaultSummaryMain])
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  let getData = async () => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([(#sessionized_debit_routing: requestPayloadMetrics :> string)]),
            ~delta=false,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~groupByNames=Some([
              (#card_network: requestPayloadMetrics :> string),
              "signature_network",
              "is_issuer_regulated",
            ]),
            ~filter=Some(LeastCostRoutingAnalyticsUtils.filterDict),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length == 0 {
        setScreenState(_ => Custom)
      } else {
        let typedData = response->LeastCostRoutingAnalyticsSummaryTableUtils.mapToTableData
        setTableData(_ => typedData)
        setScreenState(_ => Success)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching data"))
    }
  }

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  <div>
    <PageUtils.PageHeading
      title="Summary Table"
      subTitle="Detailed view of debit routed transactions with traffic share, regulated status, and estimated savings.
"
      customHeadingStyle="flex flex-col mb-6"
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
      customSubTitleStyle={`${body.md.medium} text-nd_gray-400 !opacity-100 !mt-1`}
    />
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-72" />}
      customLoader={<Shimmer styleClass="w-full h-22-rem rounded-xl" />}>
      <LoadedTable
        actualData={tableData->Array.map(Nullable.make)}
        totalResults={tableData->Array.length}
        offset
        resultsPerPage={10}
        title=" "
        setOffset
        entity={LeastCostRoutingAnalyticsSummaryTableEntity.summaryEntity()}
        currrentFetchCount={tableData->Array.length}
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  </div>
}

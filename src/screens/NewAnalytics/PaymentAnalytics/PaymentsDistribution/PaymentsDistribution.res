open NewAnalyticsTypes
open NewAnalyticsHelper
open NewPaymentAnalyticsEntity
open BarGraphTypes
open PaymentsDistributionUtils

module TableModule = {
  @react.component
  let make = (~data, ~className="", ~selectedTab: string) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-2 border-solid  border-jp-gray-940 border-collapse border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"
    let visibleColumns = visibleColumns->Array.concat([selectedTab->getDimentionType])
    let paymentsDistribution = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={paymentsDistribution}
        entity=paymentsDistributionTableEntity
        resultsPerPage=10
        totalResults={paymentsDistribution->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={paymentsDistribution->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

module PaymentsDistributionHeader = {
  @react.component
  let make = (~viewType, ~setViewType, ~groupBy, ~setGroupBy) => {
    let setViewType = value => {
      setViewType(_ => value)
    }

    let setGroupBy = value => {
      setGroupBy(_ => value)
    }

    <div className="w-full px-7 py-8 flex justify-between">
      <Tabs option={groupBy} setOption={setGroupBy} options={tabs} />
      <div className="flex gap-2">
        <TabSwitch viewType setViewType />
      </div>
    </div>
  }
}

@react.component
let make = (~entity: moduleEntity, ~chartEntity: chartEntity<barGraphPayload, barGraphOptions>) => {
  open LogicUtils
  open APIUtils
  //let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (paymentsDistribution, setpaymentsDistribution) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getPaymentsDistribution = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      //let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let url = "https://integ-api.hyperswitch.io/analytics/v1/org/metrics/payments"

      let body = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupByNames=[groupBy.value]->Some,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let response = await updateDetails(url, body, Post)
      let arr =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        setpaymentsDistribution(_ => [response]->JSON.Encode.array)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      getPaymentsDistribution()->ignore
    }
    None
  }, [startTimeVal, endTimeVal, groupBy.value])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer styleClass="w-full h-96 " />} customUI={<NoData />}>
        <PaymentsDistributionHeader viewType setViewType groupBy setGroupBy />
        <div className="mb-5">
          {switch viewType {
          | Graph =>
            <BarGraph
              entity={chartEntity}
              object={chartEntity.getObjects(
                ~data=paymentsDistribution,
                ~xKey=(#payment_success_rate: metrics :> string),
                ~yKey=groupBy.value,
              )}
              className="mr-3"
            />
          | Table =>
            <TableModule data={paymentsDistribution} className="mx-7" selectedTab={groupBy.value} />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

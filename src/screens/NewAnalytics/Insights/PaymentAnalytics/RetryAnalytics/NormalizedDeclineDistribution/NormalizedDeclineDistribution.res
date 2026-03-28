open InsightsTypes
open InsightsHelper
open BarGraphTypes
open NormalizedDeclineDistributionUtils
open NewAnalyticsHelper

module TableModule = {
  @react.component
  let make = (~data, ~className="", ~selectedTab: string) => {
    open RetryAnalyticsTypes

    let (offset, setOffset) = React.useState(_ => 0)

    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [selectedTab->getColumn, Decline_Count, Decline_Percentage]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Normalized Decline Distribution"
        hideTitle=true
        actualData={tableData}
        entity=RetryAnalyticsEntity.normalizedDeclineTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        defaultSort
        currentFetchCount={tableData->Array.length}
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

module NormalizedDeclineDistributionHeader = {
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
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<barGraphPayload, barGraphOptions, JSON.t>,
) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  open InsightsContainerUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (declineData, setDeclineData) = React.useState(_ => JSON.Encode.array([]))
  let fetchApi = AuthHooks.useApiFetcher()
  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)

  let getNormalizedDeclineDistribution = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = if isSampleDataEnabled {
        let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
        let res = await fetchApi(
          paymentsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let paymentsResponse = await res->(res => res->Fetch.Response.json)
        paymentsResponse
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("paymentsRateDataWithConnectors")
      } else {
        let url = getURL(
          ~entityName=V1(ANALYTICS_RETRY),
          ~methodType=Post,
          ~id=Some((entity.domain: domain :> string)),
        )
        let body = requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=entity.requestBodyConfig.metrics,
          ~groupByNames=[groupBy.value]->Some,
          ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
        )
        await updateDetails(url, body, Post)
      }
      let responseData =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->filterQueryData(groupBy.value)

      if responseData->Array.length > 0 {
        setDeclineData(_ => responseData->JSON.Encode.array)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getNormalizedDeclineDistribution()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, groupBy.value, currency, isSampleDataEnabled))

  let params = {
    data: declineData,
    xKey: RetryAnalyticsTypes.Decline_Count->getStringFromVariant,
    yKey: groupBy.value,
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <NormalizedDeclineDistributionHeader viewType setViewType groupBy setGroupBy />
        <div className="mb-5">
          {switch viewType {
          | Graph => <BarGraph options className="mr-3" />
          | Table => <TableModule data={declineData} className="mx-7" selectedTab={groupBy.value} />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

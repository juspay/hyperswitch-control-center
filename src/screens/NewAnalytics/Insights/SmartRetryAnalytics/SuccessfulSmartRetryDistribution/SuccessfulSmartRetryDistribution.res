open InsightsTypes
open InsightsHelper
open NewAnalyticsHelper
open BarGraphTypes
open InsightsSmartRetryAnalyticsEntity
open SuccessfulSmartRetryDistributionUtils
open SuccessfulSmartRetryDistributionTypes
open InsightsPaymentAnalyticsUtils

module TableModule = {
  @react.component
  let make = (~data, ~className="", ~selectedTab: string) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns =
      [selectedTab->getColumn]->Array.concat([Payments_Success_Rate_Distribution_With_Only_Retries])
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Successful Payments Distribution"
        hideTitle=true
        actualData={tableData}
        entity=successfulSmartRetryDistributionTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={tableData->Array.length}
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

module SuccessfulSmartRetryDistributionHeader = {
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
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (paymentsDistribution, setpaymentsDistribution) = React.useState(_ => JSON.Encode.array([]))

  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let getPaymentsDistribution = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
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
          ~entityName=V1(ANALYTICS_PAYMENTS),
          ~methodType=Post,
          ~id=Some((entity.domain: domain :> string)),
        )
        let filters = Dict.make()
        filters->Dict.set("first_attempt", [false->JSON.Encode.bool]->JSON.Encode.array)
        let body = requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=entity.requestBodyConfig.metrics,
          ~groupByNames=[groupBy.value]->Some,
          ~filter=generateFilterObject(
            ~globalFilters=filterValueJson,
            ~localFilters=filters->Some,
          )->Some,
        )
        await updateDetails(url, body, Post)
      }
      let responseData = if isSampleDataEnabled {
        let sampleData =
          response
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
        sampleData->aggregateSampleDataByGroupBy(groupBy.value)
      } else {
        response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      }

      if responseData->Array.length > 0 {
        setpaymentsDistribution(_ => responseData->JSON.Encode.array)
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
      getPaymentsDistribution()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, groupBy.value, currency, isSampleDataEnabled))

  let params = {
    data: paymentsDistribution,
    xKey: Payments_Success_Rate_Distribution_With_Only_Retries->getStringFromVariant,
    yKey: groupBy.value,
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <SuccessfulSmartRetryDistributionHeader viewType setViewType groupBy setGroupBy />
        <div className="mb-5">
          {switch viewType {
          | Graph => <BarGraph options className="mr-3" />
          | Table =>
            <TableModule data={paymentsDistribution} className="mx-7" selectedTab={groupBy.value} />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

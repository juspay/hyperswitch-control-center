open InsightsTypes
open InsightsHelper
open InsightsRefundsAnalyticsEntity
open BarGraphTypes
open SuccessfulRefundsDistributionUtils
open SuccessfulRefundsDistributionTypes

module TableModule = {
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [Connector, Refunds_Success_Rate]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Successful Refunds Distribution"
        hideTitle=true
        actualData={tableData}
        entity=successfulRefundsDistributionTableEntity
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

module SuccessfulRefundsDistributionHeader = {
  @react.component
  let make = (~viewType, ~setViewType) => {
    let setViewType = value => {
      setViewType(_ => value)
    }

    <div className="w-full px-8 pt-3 pb-3  flex justify-end">
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
  let (refundsDistribution, setrefundsDistribution) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let getRefundsDistribution = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_REFUNDS),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let body = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupByNames=[Connector->getStringFromVariant]->Some,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let response = if isSampleDataEnabled {
        let refundsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/refunds.json`
        let res = await fetchApi(
          refundsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let refundsResponse = await res->(res => res->Fetch.Response.json)
        refundsResponse
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("refundConnectorsSampleData")
      } else {
        await updateDetails(url, body, Post)
      }
      let responseData =
        response->getDictFromJsonObject->getArrayFromDict("queryData", [])->modifyQuery

      if responseData->Array.length > 0 {
        setrefundsDistribution(_ => responseData->JSON.Encode.array)
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
      getRefundsDistribution()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, currency, isSampleDataEnabled))

  let params = {
    data: refundsDistribution,
    xKey: Refunds_Success_Rate->getStringFromVariant,
    yKey: Connector->getStringFromVariant,
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <SuccessfulRefundsDistributionHeader viewType setViewType />
        <div className="mb-5">
          {switch viewType {
          | Graph => <BarGraph options className="mr-3" />
          | Table => <TableModule data={refundsDistribution} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

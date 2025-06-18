open InsightsTypes
open InsightsHelper
open ExemptionGraphsUtils
open ExemptionGraphsTypes
open InsightsUtils
open NewAuthenticationAnalyticsEntity

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30 mt-7"

    let paymentsProcessed =
      data
      ->Array.map(item => {
        item->getDictFromJsonObject->tableItemToObjMapper
      })
      ->Array.map(Nullable.make)

    let cols = [
      Authentication_Connector,
      Authentication_Success_Rate,
      Exemption_Approval_Rate,
      Exemption_Request_Rate,
      User_Drop_Off_Rate,
    ]

    <div className>
      <div className="flex flex-1 flex-col my-5">
        <div className="relative">
          <div
            className="absolute font-bold text-xl bg-white w-full text-black text-opacity-75 dark:bg-jp-gray-950 dark:text-white dark:text-opacity-75">
            {React.string("Authentication Summary")}
          </div>
          <LoadedTable
            visibleColumns=cols
            title="Authentication Summary"
            hideTitle=true
            actualData={paymentsProcessed}
            entity=authSummaryTableEntity
            resultsPerPage=10
            totalResults={paymentsProcessed->Array.length}
            offset
            setOffset
            defaultSort
            currrentFetchCount={paymentsProcessed->Array.length}
            tableLocalFilter=false
            tableheadingClass=tableBorderClass
            tableBorderClass
            ignoreHeaderBg=true
            showSerialNumber=true
            tableDataBorderClass=tableBorderClass
            isAnalyticsModule=true
          />
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchApi = AuthHooks.useApiFetcher()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)

  let (authenticationSummaryTableData, setAuthenticationSummaryTableData) = React.useState(_ => [])
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison =
    filterValueJson
    ->getString("comparison", "")
    ->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let defaulGranularity = getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaulGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  let isSampleDataEnabled =
    filterValueJson->getStringFromDictAsBool(NewAuthenticationAnalyticsUtils.sampleDataKey, false)
  let getPaymentsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_AUTHENTICATION_V2),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )
      let primaryResponse = if isSampleDataEnabled {
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
        ->getJsonObjectFromDict("authenticationSummaryTableData")
      } else {
        let primaryBody = InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=entity.requestBodyConfig.metrics,
          ~groupByNames=Some(["authentication_connector"]),
          ~filter=Some(getUpdatedFilterValueJson(filterValueJson)->JSON.Encode.object),
        )
        await updateDetails(url, primaryBody, Post)
      }
      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->modifyQueryData
        ->sortQueryDataByDate
      setAuthenticationSummaryTableData(_ => primaryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getPaymentsProcessed()->ignore
    }
    None
  }, (
    startTimeVal,
    endTimeVal,
    compareToStartTime,
    compareToEndTime,
    comparison,
    granularity.value,
    currency,
    isSampleDataEnabled,
  ))

  <PageLoaderWrapper
    screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
    <TableModule data={authenticationSummaryTableData} />
  </PageLoaderWrapper>
}

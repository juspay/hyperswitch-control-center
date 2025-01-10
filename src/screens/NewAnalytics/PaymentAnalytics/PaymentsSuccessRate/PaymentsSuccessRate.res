open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open PaymentsSuccessRateUtils
open NewPaymentAnalyticsUtils

module PaymentsSuccessRateHeader = {
  open NewAnalyticsUtils
  open LogicUtils
  @react.component
  let make = (~data, ~keyValue, ~granularity, ~setGranularity) => {
    let setGranularity = value => {
      setGranularity(_ => value)
    }
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let isSmartRetryEnabled =
      filterValueJson
      ->getString("is_smart_retry_enabled", "true")
      ->getBoolFromString(true)
      ->getSmartRetryMetricType

    let primaryValue = getMetaDataValue(
      ~data,
      ~index=0,
      ~key=keyValue->getMetaDataMapper(~isSmartRetryEnabled),
    )
    let secondaryValue = getMetaDataValue(
      ~data,
      ~index=1,
      ~key=keyValue->getMetaDataMapper(~isSmartRetryEnabled),
    )

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)
    <div className="w-full px-7 py-8 grid grid-cols-2">
      // will enable it in future
      <div className="flex gap-2 items-center">
        <div className="text-fs-28 font-semibold">
          {primaryValue->valueFormatter(Rate)->React.string}
        </div>
        <RenderIf condition={comparison == EnableComparison}>
          <StatisticsCard value direction tooltipValue={secondaryValue->valueFormatter(Rate)} />
        </RenderIf>
      </div>
      <RenderIf condition={false}>
        <div className="flex justify-center">
          <Tabs option={granularity} setOption={setGranularity} options={tabs} />
        </div>
      </RenderIf>
      <div />
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions, JSON.t>,
) => {
  open LogicUtils
  open APIUtils
  open NewAnalyticsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (paymentsSuccessRateData, setPaymentsSuccessRateData) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (paymentsSuccessRateMetaData, setpaymentsProcessedMetaData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSmartRetryEnabled =
    filterValueJson
    ->getString("is_smart_retry_enabled", "true")
    ->getBoolFromString(true)
    ->getSmartRetryMetricType

  let getPaymentsSuccessRate = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=ANALYTICS_PAYMENTS_V2,
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let primaryBody = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=entity.requestBodyConfig.metrics,
        ~granularity=granularity.value->Some,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let secondaryBody = requestBody(
        ~startTime=compareToStartTime,
        ~endTime=compareToEndTime,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=entity.requestBodyConfig.metrics,
        ~granularity=granularity.value->Some,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let primaryResponse = await updateDetails(url, primaryBody, Post)
      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->sortQueryDataByDate
      let primaryMetaData = primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])

      let (secondaryMetaData, secondaryModifiedData) = switch comparison {
      | EnableComparison => {
          let secondaryResponse = await updateDetails(url, secondaryBody, Post)
          let secondaryData =
            secondaryResponse->getDictFromJsonObject->getArrayFromDict("queryData", [])
          let secondaryMetaData =
            secondaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
          let secondaryModifiedData = [secondaryData]->Array.map(data => {
            fillMissingDataPoints(
              ~data,
              ~startDate=compareToStartTime,
              ~endDate=compareToEndTime,
              ~timeKey="time_bucket",
              ~defaultValue={
                "payment_count": 0,
                "payment_processed_amount": 0,
                "time_bucket": startTimeVal,
              }->Identity.genericTypeToJson,
              ~granularity=granularity.value,
            )
          })
          (secondaryMetaData, secondaryModifiedData)
        }
      | DisableComparison => ([], [])
      }
      if primaryData->Array.length > 0 {
        let primaryModifiedData = [primaryData]->Array.map(data => {
          fillMissingDataPoints(
            ~data,
            ~startDate=startTimeVal,
            ~endDate=endTimeVal,
            ~timeKey=Time_Bucket->getStringFromVariant,
            ~defaultValue={
              "payment_count": 0,
              "payment_success_rate": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~granularity=granularity.value,
          )
        })

        setPaymentsSuccessRateData(_ =>
          primaryModifiedData->Array.concat(secondaryModifiedData)->Identity.genericTypeToJson
        )
        setpaymentsProcessedMetaData(_ =>
          primaryMetaData->Array.concat(secondaryMetaData)->Identity.genericTypeToJson
        )
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
      getPaymentsSuccessRate()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, compareToStartTime, compareToEndTime, comparison, currency))

  let mockDelay = async () => {
    if paymentsSuccessRateData != []->JSON.Encode.array {
      setScreenState(_ => Loading)
      await HyperSwitchUtils.delay(300)
      setScreenState(_ => Success)
    }
  }

  React.useEffect(() => {
    mockDelay()->ignore
    None
  }, [isSmartRetryEnabled])
  let params = {
    data: paymentsSuccessRateData,
    xKey: Payments_Success_Rate->getKeyForModule(~isSmartRetryEnabled),
    yKey: Time_Bucket->getStringFromVariant,
    comparison,
  }
  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <PaymentsSuccessRateHeader
          data={paymentsSuccessRateMetaData}
          keyValue={Payments_Success_Rate->getStringFromVariant}
          granularity
          setGranularity
        />
        <div className="mb-5">
          <LineGraph entity={chartEntity} data={chartEntity.getObjects(~params)} className="mr-3" />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

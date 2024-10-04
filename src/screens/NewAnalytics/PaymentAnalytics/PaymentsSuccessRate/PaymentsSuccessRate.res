open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open PaymentsSuccessRateUtils

module PaymentsSuccessRateHeader = {
  open NewAnalyticsTypes
  @react.component
  let make = (~title, ~granularity, ~setGranularity) => {
    let setGranularity = value => {
      setGranularity(_ => value)
    }

    <div className="w-full px-7 py-8 grid grid-cols-2">
      // will enable it in future
      <RenderIf condition={false}>
        <div className="flex gap-2 items-center">
          <div className="text-3xl font-600"> {title->React.string} </div>
          <StatisticsCard value="8" direction={Upward} />
        </div>
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
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (paymentsSuccessRateData, setPaymentsSuccessRateData) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (_paymentsSuccessRateMetaData, setpaymentsProcessedMetaData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getPaymentsSuccessRate = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=ANALYTICS_PAYMENTS,
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let primaryBody = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
        ~granularity=granularity.value->Some,
      )

      let (prevStartTime, prevEndTime) = NewAnalyticsUtils.getComparisionTimePeriod(
        ~startDate=startTimeVal,
        ~endDate=endTimeVal,
      )

      let secondaryBody = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime=prevStartTime, // use compare by function
        ~endTime=prevEndTime, // use compare by function
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
        ~granularity=granularity.value->Some,
      )

      let primaryResponse = await updateDetails(url, primaryBody, Post)
      let secondaryResponse = await updateDetails(url, secondaryBody, Post)
      let primaryData = primaryResponse->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let primaryMetaData = primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])

      let secondaryData =
        secondaryResponse->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let secondaryMetaData =
        primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
      if primaryData->Array.length > 0 {
        let modifiedData =
          [primaryData, secondaryData]
          ->Array.map(data => {
            NewAnalyticsUtils.fillMissingDataPoints(
              ~data,
              ~startDate=startTimeVal,
              ~endDate=endTimeVal,
              ~timeKey="time_bucket",
              ~defaultValue={
                "payment_count": 0,
                "payment_processed_amount": 0,
                "time_bucket": startTimeVal,
              }->Identity.genericTypeToJson,
              ~granularity=granularity.value,
            )
          })
          ->Identity.genericTypeToJson
        setPaymentsSuccessRateData(_ => modifiedData)
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
  }, [startTimeVal, endTimeVal])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <PaymentsSuccessRateHeader title="0" granularity setGranularity />
        <div className="mb-5">
          <LineGraph
            entity={chartEntity}
            data={chartEntity.getObjects(
              ~data=paymentsSuccessRateData,
              ~xKey=(#payment_success_rate: metrics :> string),
              ~yKey=(#time_bucket: metrics :> string),
            )}
            className="mr-3"
          />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

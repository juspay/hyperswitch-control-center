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
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (paymentsSuccessRate, setpaymentsSuccessRate) = React.useState(_ => JSON.Encode.array([]))
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getPaymentsSuccessRate = async () => {
    try {
      let url = getURL(
        ~entityName=ANALYTICS_PAYMENTS,
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let body = NewAnalyticsUtils.requestBody(
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

      let response = await updateDetails(url, body, Post)
      let arr =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        setpaymentsSuccessRate(_ => [response]->JSON.Encode.array)
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
        screenState customLoader={<Shimmer styleClass="w-full h-96" />} customUI={<NoData />}>
        <PaymentsSuccessRateHeader title="0" granularity setGranularity />
        <div className="mb-5">
          <LineGraph
            entity={chartEntity}
            data={chartEntity.getObjects(
              ~data=paymentsSuccessRate,
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

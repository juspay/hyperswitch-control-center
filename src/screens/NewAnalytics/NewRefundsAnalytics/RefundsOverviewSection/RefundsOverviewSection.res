open NewAnalyticsTypes
open RefundsOverviewSectionTypes
open RefundsOverviewSectionUtils
open NewAnalyticsHelper
open LogicUtils
open APIUtils
open NewAnalyticsUtils
open RefundsSampleData
open NewAnalyticsContainerUtils
@react.component
let make = (~entity: moduleEntity) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => []->JSON.Encode.array)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = defaultValue->Dict.copy
      let secondaryData = defaultValue->Dict.copy

      if isSampleDataEnabled {
        setData(_ => refundsOverviewData) //replace with s3 call
      } else {
        let refundsUrl = getURL(
          ~entityName=V1(ANALYTICS_REFUNDS),
          ~methodType=Post,
          ~id=Some((#refunds: domain :> string)),
        )

        let amountRateBodyRefunds = requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=[#sessionized_refund_processed_amount, #sessionized_refund_success_rate],
          ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
        )

        let filters = Dict.make()
        filters->Dict.set(
          "refund_status",
          [#success, #failure, #pending]
          ->Array.map(item => {
            (item: status :> string)->JSON.Encode.string
          })
          ->JSON.Encode.array,
        )

        let statusCountBodyRefunds = requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~groupByNames=["refund_status"]->Some,
          ~filter=generateFilterObject(
            ~globalFilters=filterValueJson,
            ~localFilters=filters->Some,
          )->Some,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=[#sessionized_refund_count],
        )

        let amountRateResponseRefunds = await updateDetails(refundsUrl, amountRateBodyRefunds, Post)
        let statusCountResponseRefunds = await updateDetails(
          refundsUrl,
          statusCountBodyRefunds,
          Post,
        )

        let amountRateDataRefunds = amountRateResponseRefunds->parseResponse("metaData")
        let statusCountDataRefunds = statusCountResponseRefunds->modifyStatusCountResponse

        primaryData->setValue(
          ~data=amountRateDataRefunds,
          ~ids=[Total_Refund_Processed_Amount, Total_Refund_Success_Rate],
          ~currency,
        )

        primaryData->setValue(
          ~data=statusCountDataRefunds,
          ~ids=[Successful_Refund_Count, Failed_Refund_Count, Pending_Refund_Count],
          ~currency,
        )

        let secondaryAmountRateBodyRefunds = requestBody(
          ~startTime=compareToStartTime,
          ~endTime=compareToEndTime,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=[#sessionized_refund_processed_amount, #sessionized_refund_success_rate],
          ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
        )

        let secondaryStatusCountBodyRefunds = requestBody(
          ~startTime=compareToStartTime,
          ~endTime=compareToEndTime,
          ~groupByNames=["refund_status"]->Some,
          ~filter=generateFilterObject(
            ~globalFilters=filterValueJson,
            ~localFilters=filters->Some,
          )->Some,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=[#sessionized_refund_count],
        )

        let secondaryData = switch comparison {
        | EnableComparison => {
            let secondaryResponseRefunds = await updateDetails(
              refundsUrl,
              secondaryAmountRateBodyRefunds,
              Post,
            )

            let secondaryStatusCountResponseRefunds = await updateDetails(
              refundsUrl,
              secondaryStatusCountBodyRefunds,
              Post,
            )

            let secondaryAmountRateDataRefunds = secondaryResponseRefunds->parseResponse("metaData")
            let secondaryStatusCountDataRefunds =
              secondaryStatusCountResponseRefunds->modifyStatusCountResponse

            secondaryData->setValue(
              ~data=secondaryAmountRateDataRefunds,
              ~ids=[Total_Refund_Processed_Amount, Total_Refund_Success_Rate],
              ~currency,
            )

            secondaryData->setValue(
              ~data=secondaryStatusCountDataRefunds,
              ~ids=[Successful_Refund_Count, Failed_Refund_Count, Pending_Refund_Count],
              ~currency,
            )

            secondaryData->JSON.Encode.object
          }
        | DisableComparison => JSON.Encode.null
        }

        setData(_ => [primaryData->JSON.Encode.object, secondaryData]->JSON.Encode.array)
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, (
    startTimeVal,
    endTimeVal,
    compareToStartTime,
    compareToEndTime,
    comparison,
    currency,
    isSampleDataEnabled,
  ))

  <PageLoaderWrapper screenState customLoader={<Shimmer layoutId=entity.title />}>
    <div className="grid grid-cols-3 grid-rows-2 gap-6">
      <OverViewStat
        data responseKey={Total_Refund_Success_Rate} getInfo getValueFromObj getStringFromVariant
      />
      <OverViewStat
        data
        responseKey={Total_Refund_Processed_Amount}
        getInfo
        getValueFromObj
        getStringFromVariant
      />
      <OverViewStat
        data responseKey={Successful_Refund_Count} getInfo getValueFromObj getStringFromVariant
      />
      <OverViewStat
        data responseKey={Failed_Refund_Count} getInfo getValueFromObj getStringFromVariant
      />
      <OverViewStat
        data responseKey={Pending_Refund_Count} getInfo getValueFromObj getStringFromVariant
      />
    </div>
  </PageLoaderWrapper>
}

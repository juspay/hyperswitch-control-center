open InsightsTypes
open InsightsPaymentsOverviewSectionTypes
@react.component
let make = (~entity: moduleEntity) => {
  open InsightsPaymentsOverviewSectionUtils
  open LogicUtils
  open APIUtils
  open InsightsHelper
  open InsightsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => []->JSON.Encode.array)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let metricType: metricType =
    filterValueJson
    ->getString("is_smart_retry_enabled", "true")
    ->getBoolFromString(true)
    ->InsightsPaymentAnalyticsUtils.getSmartRetryMetricType

  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = defaultValue->Dict.copy
      let secondaryData = defaultValue->Dict.copy

      let paymentsUrl = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
        ~methodType=Post,
        ~id=Some((#payments: domain :> string)),
      )

      let refundsUrl = getURL(
        ~entityName=V1(ANALYTICS_REFUNDS),
        ~methodType=Post,
        ~id=Some((#refunds: domain :> string)),
      )

      let disputesUrl = getURL(
        ~entityName=V1(ANALYTICS_DISPUTES),
        ~methodType=Post,
        ~id=Some((#disputes: domain :> string)),
      )

      // primary date range
      let primaryBodyPayments = getPayload(
        ~entity,
        ~metrics=[
          #sessionized_smart_retried_amount,
          #sessionized_payments_success_rate,
          #sessionized_payment_processed_amount,
        ],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let primaryBodyRefunds = getPayload(
        ~entity,
        ~metrics=[#refund_processed_amount],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let primaryBodyDisputes = getPayload(
        ~entity,
        ~metrics=[#dispute_status_metric],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filter=None,
      )

      let primaryResponsePayments = await updateDetails(paymentsUrl, primaryBodyPayments, Post)
      let primaryResponseRefunds = await updateDetails(refundsUrl, primaryBodyRefunds, Post)
      let primaryResponseDisputes = await updateDetails(disputesUrl, primaryBodyDisputes, Post)

      let primaryDataPayments = primaryResponsePayments->parseResponse("metaData")
      let primaryDataRefunds = primaryResponseRefunds->parseResponse("metaData")
      let primaryDataDisputes = primaryResponseDisputes->parseResponse("queryData")

      primaryData->setValue(
        ~data=primaryDataPayments,
        ~ids=[Total_Smart_Retried_Amount, Total_Success_Rate, Total_Payment_Processed_Amount],
        ~metricType,
        ~currency,
      )

      primaryData->setValue(
        ~data=primaryDataRefunds,
        ~ids=[Total_Refund_Processed_Amount],
        ~metricType,
        ~currency,
      )
      primaryData->setValue(~data=primaryDataDisputes, ~ids=[Total_Dispute], ~metricType, ~currency)

      let secondaryBodyPayments = getPayload(
        ~entity,
        ~metrics=[
          #sessionized_smart_retried_amount,
          #sessionized_payments_success_rate,
          #sessionized_payment_processed_amount,
        ],
        ~startTime=compareToStartTime,
        ~endTime=compareToEndTime,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let secondaryBodyRefunds = getPayload(
        ~entity,
        ~metrics=[#refund_processed_amount],
        ~startTime=compareToStartTime,
        ~endTime=compareToEndTime,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let secondaryBodyDisputes = getPayload(
        ~entity,
        ~metrics=[#dispute_status_metric],
        ~startTime=compareToStartTime,
        ~endTime=compareToEndTime,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )

      let secondaryData = switch comparison {
      | EnableComparison => {
          let secondaryResponsePayments = await updateDetails(
            paymentsUrl,
            secondaryBodyPayments,
            Post,
          )
          let secondaryResponseRefunds = await updateDetails(refundsUrl, secondaryBodyRefunds, Post)
          let secondaryResponseDisputes = await updateDetails(
            disputesUrl,
            secondaryBodyDisputes,
            Post,
          )

          let secondaryDataPayments = secondaryResponsePayments->parseResponse("metaData")
          let secondaryDataRefunds = secondaryResponseRefunds->parseResponse("metaData")
          let secondaryDataDisputes = secondaryResponseDisputes->parseResponse("queryData")

          secondaryData->setValue(
            ~data=secondaryDataPayments,
            ~ids=[Total_Smart_Retried_Amount, Total_Success_Rate, Total_Payment_Processed_Amount],
            ~metricType,
            ~currency,
          )

          secondaryData->setValue(
            ~data=secondaryDataRefunds,
            ~ids=[Total_Refund_Processed_Amount],
            ~metricType,
            ~currency,
          )
          secondaryData->setValue(
            ~data=secondaryDataDisputes,
            ~ids=[Total_Dispute],
            ~metricType,
            ~currency,
          )
          secondaryData->JSON.Encode.object
        }
      | DisableComparison => JSON.Encode.null
      }

      setData(_ => [primaryData->JSON.Encode.object, secondaryData]->JSON.Encode.array)

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
    metricType,
  ))

  <PageLoaderWrapper screenState customLoader={<Shimmer layoutId=entity.title />}>
    <div className="grid grid-cols-3 gap-6">
      <InsightsPaymentsOverviewSectionHelper.SmartRetryCard
        data responseKey={Total_Smart_Retried_Amount}
      />
      <div className="col-span-2 grid grid-cols-2 grid-rows-2 gap-6">
        <OverViewStat
          data responseKey={Total_Success_Rate} getInfo getValueFromObj getStringFromVariant
        />
        <OverViewStat
          data
          responseKey={Total_Payment_Processed_Amount}
          getInfo
          getValueFromObj
          getStringFromVariant
        />
        <OverViewStat
          data
          responseKey={Total_Refund_Processed_Amount}
          getInfo
          getValueFromObj
          getStringFromVariant
        />
        <OverViewStat
          data responseKey={Total_Dispute} getInfo getValueFromObj getStringFromVariant
        />
      </div>
    </div>
  </PageLoaderWrapper>
}

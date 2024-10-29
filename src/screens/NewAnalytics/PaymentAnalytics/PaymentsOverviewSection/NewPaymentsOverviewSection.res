open NewAnalyticsTypes
open NewPaymentsOverviewSectionTypes
@react.component
let make = (~entity: moduleEntity) => {
  open NewPaymentsOverviewSectionUtils
  open LogicUtils
  open APIUtils
  open NewAnalyticsHelper
  open NewPaymentsOverviewSectionHelper
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
    ->NewPaymentAnalyticsUtils.getSmartRetryMetricType

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = defaultValue->Dict.copy
      let secondaryData = defaultValue->Dict.copy

      let paymentsUrl = getURL(
        ~entityName=ANALYTICS_PAYMENTS_V2,
        ~methodType=Post,
        ~id=Some((#payments: domain :> string)),
      )

      let refundsUrl = getURL(
        ~entityName=ANALYTICS_REFUNDS,
        ~methodType=Post,
        ~id=Some((#refunds: domain :> string)),
      )

      let _disputesUrl = getURL(
        ~entityName=ANALYTICS_DISPUTES,
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
      )

      let primaryBodyRefunds = getPayload(
        ~entity,
        ~metrics=[#refund_processed_amount],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
      )

      let _primaryBodyDisputes = getPayload(
        ~entity,
        ~metrics=[#dispute_status_metric],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
      )

      let primaryResponsePayments = await updateDetails(paymentsUrl, primaryBodyPayments, Post)
      let primaryResponseRefunds = await updateDetails(refundsUrl, primaryBodyRefunds, Post)
      //let primaryResponseDisputes = await updateDetails(disputesUrl, primaryBodyDisputes, Post)

      let primaryDataPayments = primaryResponsePayments->parseResponse("metaData")
      let primaryDataRefunds = primaryResponseRefunds->parseResponse("queryData")
      //let primaryDataDisputes = primaryResponseDisputes->parseResponse("queryData")

      primaryData->setValue(
        ~data=primaryDataPayments,
        ~ids=[
          Total_Smart_Retried_Amount,
          Total_Smart_Retried_Amount_Without_Smart_Retries,
          Total_Success_Rate,
          Total_Success_Rate_Without_Smart_Retries,
          Total_Payment_Processed_Amount,
          Total_Payment_Processed_Amount_Without_Smart_Retries,
        ],
      )

      primaryData->setValue(~data=primaryDataRefunds, ~ids=[Refund_Processed_Amount])
      //primaryData->setValue(~data=primaryDataDisputes, ~ids=[Total_Dispute])

      // secondary date range
      let (prevStartTime, prevEndTime) = DateRangeUtils.getComparisionTimePeriod(
        ~startDate=startTimeVal,
        ~endDate=endTimeVal,
      )

      let secondaryBodyPayments = getPayload(
        ~entity,
        ~metrics=[
          #sessionized_smart_retried_amount,
          #sessionized_payments_success_rate,
          #sessionized_payment_processed_amount,
        ],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let secondaryBodyRefunds = getPayload(
        ~entity,
        ~metrics=[#refund_processed_amount],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let _secondaryBodyDisputes = getPayload(
        ~entity,
        ~metrics=[#dispute_status_metric],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let secondaryResponsePayments = await updateDetails(paymentsUrl, secondaryBodyPayments, Post)
      let secondaryResponseRefunds = await updateDetails(refundsUrl, secondaryBodyRefunds, Post)
      //let secondaryResponseDisputes = await updateDetails(disputesUrl, secondaryBodyDisputes, Post)

      let secondaryDataPayments = secondaryResponsePayments->parseResponse("metaData")
      let secondaryDataRefunds = secondaryResponseRefunds->parseResponse("queryData")
      //let secondaryDataDisputes = secondaryResponseDisputes->parseResponse("queryData")

      secondaryData->setValue(
        ~data=secondaryDataPayments,
        ~ids=[
          Total_Smart_Retried_Amount,
          Total_Smart_Retried_Amount_Without_Smart_Retries,
          Total_Success_Rate,
          Total_Success_Rate_Without_Smart_Retries,
          Total_Payment_Processed_Amount,
          Total_Payment_Processed_Amount_Without_Smart_Retries,
        ],
      )

      secondaryData->setValue(~data=secondaryDataRefunds, ~ids=[Refund_Processed_Amount])
      //secondaryData->setValue(~data=secondaryDataDisputes, ~ids=[Total_Dispute])

      setData(_ =>
        [primaryData->JSON.Encode.object, secondaryData->JSON.Encode.object]->JSON.Encode.array
      )

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
  }, [startTimeVal, endTimeVal])

  let mockDelay = async () => {
    if data != []->JSON.Encode.array {
      setScreenState(_ => Loading)
      await HyperSwitchUtils.delay(300)
      setScreenState(_ => Success)
    }
  }

  React.useEffect(() => {
    mockDelay()->ignore
    None
  }, [metricType])

  <PageLoaderWrapper screenState customLoader={<Shimmer layoutId=entity.title />}>
    <div className="grid grid-cols-3 gap-6">
      <SmartRetryCard data responseKey={Total_Smart_Retried_Amount->getKeyForModule(~metricType)} />
      <div className="col-span-2 grid grid-cols-2 grid-rows-2 gap-6">
        <OverViewStat data responseKey={Total_Success_Rate->getKeyForModule(~metricType)} />
        <OverViewStat
          data responseKey={Total_Payment_Processed_Amount->getKeyForModule(~metricType)}
        />
        <OverViewStat data responseKey={Refund_Processed_Amount->getKeyForModule(~metricType)} />
        <OverViewStat data responseKey={Total_Dispute->getKeyForModule(~metricType)} />
      </div>
    </div>
  </PageLoaderWrapper>
}

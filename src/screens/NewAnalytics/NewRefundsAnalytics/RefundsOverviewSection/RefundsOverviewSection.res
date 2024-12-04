open NewAnalyticsTypes
open RefundsOverviewSectionTypes
open RefundsOverviewSectionUtils
open NewAnalyticsHelper
open LogicUtils
open APIUtils
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

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = defaultValue->Dict.copy
      let secondaryData = defaultValue->Dict.copy

      let refundsUrl = getURL(
        ~entityName=ANALYTICS_REFUNDS,
        ~methodType=Post,
        ~id=Some((#refunds: domain :> string)),
      )

      // primary date range
      let primaryBodyRefunds = NewAnalyticsUtils.requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=[#sessionized_refund_processed_amount, #sessionized_refund_success_rate],
      )

      let primaryResponseRefunds = await updateDetails(refundsUrl, primaryBodyRefunds, Post)

      let primaryDataRefunds = primaryResponseRefunds->parseResponse("metaData")

      primaryData->setValue(
        ~data=primaryDataRefunds,
        ~ids=[Total_Refund_Processed_Amount, Total_Refund_Success_Rate],
      )

      let secondaryBodyRefunds = NewAnalyticsUtils.requestBody(
        ~startTime=compareToStartTime,
        ~endTime=compareToEndTime,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=[#sessionized_refund_processed_amount, #sessionized_refund_success_rate],
      )

      let secondaryData = switch comparison {
      | EnableComparison => {
          let secondaryResponseRefunds = await updateDetails(refundsUrl, secondaryBodyRefunds, Post)

          let secondaryDataRefunds = secondaryResponseRefunds->parseResponse("metaData")

          secondaryData->setValue(
            ~data=secondaryDataRefunds,
            ~ids=[Total_Refund_Processed_Amount, Total_Refund_Success_Rate],
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
  }, (startTimeVal, endTimeVal, compareToStartTime, compareToEndTime, comparison))

  <PageLoaderWrapper screenState customLoader={<Shimmer layoutId=entity.title />}>
    <div className="grid grid-cols-3 grid-rows-2 gap-6">
      <OverViewStat
        data
        responseKey={Total_Refund_Success_Rate}
        config={getInfo(~responseKey=Total_Refund_Success_Rate)}
        getValueFromObj
        getStringFromVariant
      />
      <OverViewStat
        data
        responseKey={Total_Refund_Processed_Amount}
        config={getInfo(~responseKey=Total_Refund_Processed_Amount)}
        getValueFromObj
        getStringFromVariant
      />
      <OverViewStat
        data
        responseKey={Successful_Refund_Count}
        config={getInfo(~responseKey=Successful_Refund_Count)}
        getValueFromObj
        getStringFromVariant
      />
      <OverViewStat
        data
        responseKey={Failed_Refund_Count}
        config={getInfo(~responseKey=Failed_Refund_Count)}
        getValueFromObj
        getStringFromVariant
      />
      <OverViewStat
        data
        responseKey={Pending_Refund_Count}
        config={getInfo(~responseKey=Pending_Refund_Count)}
        getValueFromObj
        getStringFromVariant
      />
    </div>
  </PageLoaderWrapper>
}

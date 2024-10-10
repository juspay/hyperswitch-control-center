open NewAnalyticsTypes

module SmartRetryCard = {
  open NewAnalyticsHelper
  open NewPaymentsOverviewSectionTypes
  open NewPaymentsOverviewSectionUtils
  open NewAnalyticsUtils
  @react.component
  let make = (~metric, ~data) => {
    let config = getInfo(~metric)

    let primaryValue = getValueFromObj(data, 0, metric)
    let secondaryValue = getValueFromObj(data, 1, metric)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto">
        <div className="font-semibold  dark:text-white"> {config.titleText->React.string} </div>
        <div className={"flex flex-col gap-1 justify-center  text-black h-full"}>
          <img alt="connector-list" className="h-20 w-fit" src="/assets/smart-retry.svg" />
          <div className="flex gap-1 items-center">
            <div className="font-semibold  text-2xl dark:text-white">
              {`Saved ${valueFormatter(primaryValue, config.valueType)}`->React.string}
            </div>
            <div className="scale-[0.9]">
              <StatisticsCard value direction />
            </div>
          </div>
          <div className="opacity-50 text-sm"> {config.description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}

module OverViewStat = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
  open NewPaymentsOverviewSectionTypes
  open NewPaymentsOverviewSectionUtils
  @react.component
  let make = (~metric, ~data) => {
    let config = getInfo(~metric)

    let primaryValue = getValueFromObj(data, 0, metric)
    let secondaryValue = getValueFromObj(data, 1, metric)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl">
              {valueFormatter(primaryValue, config.valueType)->React.string}
            </div>
            <div className="scale-[0.9]">
              <StatisticsCard value direction />
            </div>
          </div>
        </div>
        <div className={"flex flex-col gap-1  text-black"}>
          <div className="font-semibold  dark:text-white"> {config.titleText->React.string} </div>
          <div className="opacity-50 text-sm"> {config.description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}

@react.component
let make = (~entity: moduleEntity) => {
  open NewPaymentsOverviewSectionUtils
  open LogicUtils
  open APIUtils
  open NewAnalyticsHelper
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => []->JSON.Encode.array)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = defaultValue->Dict.copy
      let secondaryData = defaultValue->Dict.copy

      let urlV1Payments = getURL(
        ~entityName=ANALYTICS_PAYMENTS,
        ~methodType=Post,
        ~id=Some((#payments: domain :> string)),
      )

      let urlV1Refunds = getURL(
        ~entityName=ANALYTICS_PAYMENTS,
        ~methodType=Post,
        ~id=Some((#refunds: domain :> string)),
      )

      let urlV2Payments = getURL(
        ~entityName=ANALYTICS_PAYMENTS_V2,
        ~methodType=Post,
        ~id=Some((#payments: domain :> string)),
      )

      // primary date range
      let primaryBodyV2Payments = getPayload(
        ~entity,
        ~metrics=[#smart_retried_amount, #payments_success_rate],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
      )

      let primaryBodyV1Payments = getPayload(
        ~entity,
        ~metrics=[#payment_processed_amount],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
      )

      let primaryBodyV1Refunds = getPayload(
        ~entity,
        ~metrics=[#refund_success_count],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
      )

      let primaryResponseV1Payments = await updateDetails(
        urlV1Payments,
        primaryBodyV1Payments,
        Post,
      )
      let primaryResponseV1Refunds = await updateDetails(urlV1Refunds, primaryBodyV1Refunds, Post)
      let primaryResponseV2Payments = await updateDetails(
        urlV2Payments,
        primaryBodyV2Payments,
        Post,
      )

      let primaryDataV1Payments = primaryResponseV1Payments->parseResponse
      let primaryDataV1Refunds = primaryResponseV1Refunds->parseResponse
      let primaryDataV2Payments = primaryResponseV2Payments->parseResponse

      primaryData->setValue(~data=primaryDataV1Payments, ~ids=[#payment_processed_amount])
      primaryData->setValue(~data=primaryDataV1Refunds, ~ids=[#refund_success_count])
      primaryData->setValue(
        ~data=primaryDataV2Payments,
        ~ids=[#smart_retried_amount, #payments_success_rate],
      )

      // secondary date range
      let (prevStartTime, prevEndTime) = NewAnalyticsUtils.getComparisionTimePeriod(
        ~startDate=startTimeVal,
        ~endDate=endTimeVal,
      )

      let secondaryBodyV2Payments = getPayload(
        ~entity,
        ~metrics=[#smart_retried_amount, #payments_success_rate],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let secondaryBodyV1Payments = getPayload(
        ~entity,
        ~metrics=[#payment_processed_amount],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let secondaryBodyV1Refunds = getPayload(
        ~entity,
        ~metrics=[#refund_success_count],
        ~startTime=prevStartTime,
        ~endTime=prevEndTime,
      )

      let secondaryResponseV1Payments = await updateDetails(
        urlV1Payments,
        secondaryBodyV1Payments,
        Post,
      )
      let secondaryResponseV1Refunds = await updateDetails(
        urlV1Refunds,
        secondaryBodyV1Refunds,
        Post,
      )
      let secondaryResponseV2Payments = await updateDetails(
        urlV2Payments,
        secondaryBodyV2Payments,
        Post,
      )

      let secondaryDataV1Payments = secondaryResponseV1Payments->parseResponse
      let secondaryDataV1Refunds = secondaryResponseV1Refunds->parseResponse
      let secondaryDataV2Payments = secondaryResponseV2Payments->parseResponse

      secondaryData->setValue(~data=secondaryDataV1Payments, ~ids=[#payment_processed_amount])
      secondaryData->setValue(~data=secondaryDataV1Refunds, ~ids=[#refund_success_count])
      secondaryData->setValue(
        ~data=secondaryDataV2Payments,
        ~ids=[#smart_retried_amount, #payments_success_rate],
      )

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

  <PageLoaderWrapper screenState customLoader={<Shimmer layoutId=entity.title />}>
    // Need to modify
    <div className="grid grid-cols-3 gap-3">
      <SmartRetryCard data metric=#smart_retried_amount />
      <div className="col-span-2 grid grid-cols-2 grid-rows-2 gap-3">
        <OverViewStat data metric=#payments_success_rate />
        <OverViewStat data metric=#payment_processed_amount />
        <OverViewStat data metric=#refund_success_count />
        <OverViewStat data metric=#dispute_status_metric />
      </div>
    </div>
  </PageLoaderWrapper>
}

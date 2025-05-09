open NewAnalyticsTypes
open NewAnalyticsHelper
open SmartRetryPaymentsProcessedUtils
open NewSmartRetryAnalyticsEntity
open PaymentsProcessedTypes

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let smartRetryPaymentsProcessed =
      data
      ->Array.map(item => {
        item->getDictFromJsonObject->tableItemToObjMapper
      })
      ->Array.map(Nullable.make)

    let defaultCols = [Payment_Processed_Amount, Payment_Processed_Count]
    let visibleColumns = defaultCols->Array.concat(visibleColumns)

    <div className>
      <LoadedTable
        visibleColumns
        title="Smart Retry Payments Processed"
        hideTitle=true
        actualData={smartRetryPaymentsProcessed}
        entity=smartRetryPaymentsProcessedTableEntity
        resultsPerPage=10
        totalResults={smartRetryPaymentsProcessed->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={smartRetryPaymentsProcessed->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        showSerialNumber=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

module SmartRetryPaymentsProcessedHeader = {
  open NewAnalyticsUtils
  open LogicUtils
  open LogicUtilsTypes

  @react.component
  let make = (
    ~data: JSON.t,
    ~viewType,
    ~setViewType,
    ~selectedMetric,
    ~setSelectedMetric,
    ~granularity,
    ~setGranularity,
    ~granularityOptions,
  ) => {
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let currency = filterValueJson->getString((#currency: filters :> string), "")
    let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let primaryValue = getMetaDataValue(
      ~data,
      ~index=0,
      ~key=selectedMetric.value->getMetaDataMapper,
    )
    let secondaryValue = getMetaDataValue(
      ~data,
      ~index=1,
      ~key=selectedMetric.value->getMetaDataMapper,
    )

    let (primaryValue, secondaryValue) = if selectedMetric.value->isAmountMetric {
      (primaryValue /. 100.0, secondaryValue /. 100.0)
    } else {
      (primaryValue, secondaryValue)
    }

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    let setViewType = value => {
      setViewType(_ => value)
    }

    let setSelectedMetric = value => {
      setSelectedMetric(_ => value)
    }

    let setGranularity = value => {
      setGranularity(_ => value)
    }

    let metricType = switch selectedMetric.value->getVariantValueFromString {
    | Payment_Processed_Amount => Amount
    | _ => Volume
    }

    <div className="w-full px-7 py-8 grid grid-cols-3">
      <div className="flex gap-2 items-center">
        <div className="text-fs-28 font-semibold">
          {primaryValue->valueFormatter(metricType, ~currency)->React.string}
        </div>
        <RenderIf condition={comparison == EnableComparison}>
          <StatisticsCard
            value direction tooltipValue={secondaryValue->valueFormatter(metricType, ~currency)}
          />
        </RenderIf>
      </div>
      <div className="flex justify-center">
        <RenderIf condition={featureFlag.granularity}>
          <Tabs
            option={granularity}
            setOption={setGranularity}
            options={granularityOptions}
            showSingleTab=false
          />
        </RenderIf>
      </div>
      <div className="flex gap-2 justify-end">
        <CustomDropDown
          buttonText={selectedMetric} options={dropDownOptions} setOption={setSelectedMetric}
        />
        <TabSwitch viewType setViewType />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineGraphTypes.lineGraphPayload,
    LineGraphTypes.lineGraphOptions,
    JSON.t,
  >,
) => {
  open LogicUtils
  open APIUtils
  open NewAnalyticsUtils
  open NewAnalyticsSampleData
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (smartRetryPaymentsProcessedData, setSmartRetryPaymentsProcessedData) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (
    smartRetryPaymentsProcessedTableData,
    setSmartRetryPaymentsProcessedTableData,
  ) = React.useState(_ => [])
  let (
    smartRetryPaymentsProcessedMetaData,
    setSmartRetryPaymentsProcessedMetaData,
  ) = React.useState(_ => JSON.Encode.array([]))
  let (selectedMetric, setSelectedMetric) = React.useState(_ => defaultMetric)
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)
  let defaulGranularity = getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let isSampleDataEnabled =
    filterValueJson->getString("is_sample_data_enabled", "true")->LogicUtils.getBoolFromString(true)
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaulGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  let getSmartRetryPaymentsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
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

      let primaryResponse = if isSampleDataEnabled {
        paymentSampleData //replace with s3 call
      } else {
        await updateDetails(url, primaryBody, Post)
      }
      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->modifySmartRetryQueryData(~currency)
        ->sortQueryDataByDate

      let primaryMetaData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("metaData", [])
        ->modifySmartRetryMetaData(~currency)
      setSmartRetryPaymentsProcessedTableData(_ => primaryData)

      let (secondaryMetaData, secondaryModifiedData) = switch comparison {
      | EnableComparison => {
          let secondaryResponse = if isSampleDataEnabled {
            secondaryPaymentSampleData
          } else {
            await updateDetails(url, secondaryBody, Post)
          }
          let secondaryData =
            secondaryResponse
            ->getDictFromJsonObject
            ->getArrayFromDict("queryData", [])
            ->modifySmartRetryQueryData(~currency)
          let secondaryMetaData =
            secondaryResponse
            ->getDictFromJsonObject
            ->getArrayFromDict("metaData", [])
            ->modifySmartRetryMetaData(~currency)

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
              ~isoStringToCustomTimeZone,
              ~granularity=granularity.value,
              ~granularityEnabled=featureFlag.granularity,
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
            ~timeKey="time_bucket",
            ~defaultValue={
              "payment_count": 0,
              "payment_processed_amount": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~isoStringToCustomTimeZone,
            ~granularity=granularity.value,
            ~granularityEnabled=featureFlag.granularity,
          )
        })

        setSmartRetryPaymentsProcessedData(_ =>
          primaryModifiedData->Array.concat(secondaryModifiedData)->Identity.genericTypeToJson
        )
        setSmartRetryPaymentsProcessedMetaData(_ =>
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
      getSmartRetryPaymentsProcessed()->ignore
    }
    None
  }, (
    startTimeVal,
    endTimeVal,
    compareToStartTime,
    compareToEndTime,
    comparison,
    currency,
    granularity.value,
    isSampleDataEnabled,
  ))

  let params = {
    data: smartRetryPaymentsProcessedData,
    xKey: selectedMetric.value,
    yKey: Time_Bucket->getStringFromVariant,
    comparison,
    currency,
  }

  let options = chartEntity.getObjects(~params)->chartEntity.getChatOptions

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <SmartRetryPaymentsProcessedHeader
          data=smartRetryPaymentsProcessedMetaData
          viewType
          setViewType
          selectedMetric
          setSelectedMetric
          granularity
          setGranularity
          granularityOptions
        />
        <div className="mb-5">
          {switch viewType {
          | Graph => <LineGraph options className="mr-3" />
          | Table => <TableModule data={smartRetryPaymentsProcessedTableData} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

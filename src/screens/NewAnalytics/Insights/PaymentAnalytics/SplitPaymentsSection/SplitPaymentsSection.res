open InsightsTypes
open InsightsHelper
open SplitPaymentsSectionUtils
open NewAnalyticsHelper

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [
      SplitPaymentsSectionTypes.Split_Payment_Connector,
      Payments_Success_Rate_Distribution_Without_Smart_Retries,
    ]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Split Payments Distribution"
        hideTitle=true
        actualData={tableData}
        entity=InsightsPaymentAnalyticsEntity.splitPaymentsSectionTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        defaultSort
        currentFetchCount={tableData->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

module SplitPaymentsSectionHeader = {
  @react.component
  let make = (~viewType, ~setViewType) => {
    let setViewType = value => {
      setViewType(_ => value)
    }

    <div className="w-full px-7 py-8 flex justify-end">
      <div className="flex gap-2">
        <TabSwitch viewType setViewType />
      </div>
    </div>
  }
}

module SplitPaymentStatCard = {
  @react.component
  let make = (~title, ~value, ~description) => {
    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl"> {value->React.string} </div>
          </div>
        </div>
        <div className={"flex flex-col gap-1 text-black"}>
          <div className="font-semibold dark:text-white"> {title->React.string} </div>
          <div className="opacity-50 text-sm"> {description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (distributionData, setDistributionData) = React.useState(_ => JSON.Encode.array([]))
  let (splitPaymentsCount, setSplitPaymentsCount) = React.useState(_ => 0.0)
  let (totalPaymentsCount, setTotalPaymentsCount) = React.useState(_ => 0.0)
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")

  let getSplitPaymentsData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let splitFilters = splitPaymentFilter()
      let splitFilter = generateFilterObject(~globalFilters=filterValueJson, ~localFilters=splitFilters->Some)

      // Fetch total payments count
      let totalPaymentsBody = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=[#sessionized_payment_intent_count],
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
      )
      let totalPaymentsResponse = await updateDetails(url, totalPaymentsBody, Post)
      let totalCount =
        totalPaymentsResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
        ->getDictFromJsonObject
        ->getFloat("payment_intent_count", 0.0)
      setTotalPaymentsCount(_ => totalCount)

      // Fetch split payments count
      let splitPaymentsBody = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=[#sessionized_payment_intent_count],
        ~filter=splitFilter->Some,
      )
      let splitPaymentsResponse = await updateDetails(url, splitPaymentsBody, Post)
      let splitCount =
        splitPaymentsResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
        ->getDictFromJsonObject
        ->getFloat("payment_intent_count", 0.0)
      setSplitPaymentsCount(_ => splitCount)

      // Fetch distribution data
      let distributionBody = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupByNames=["split_payment_connector"]->Some,
        ~filter=splitFilter->Some,
      )
      let distributionResponse = await updateDetails(url, distributionBody, Post)
      let responseData =
        distributionResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->filterQueryData("split_payment_connector")

      if responseData->Array.length > 0 || splitCount > 0.0 {
        setDistributionData(_ => responseData->JSON.Encode.array)
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
      getSplitPaymentsData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, currency))

  let splitPercentage = if totalPaymentsCount > 0.0 {
    splitPaymentsCount /. totalPaymentsCount *. 100.0
  } else {
    0.0
  }

  let pieOptions = splitPaymentsDistributionPieMapper(distributionData)

  <div>
    <ModuleHeader title={entity.title} />
    <PageLoaderWrapper
      screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
      <div className="grid grid-cols-2 gap-6 mb-6">
        <SplitPaymentStatCard
          title="Total Split Payments"
          value={splitPaymentsCount->Float.toInt->Int.toString}
          description="Total number of payments processed as split payments"
        />
        <SplitPaymentStatCard
          title="Split Payment Percentage"
          value={splitPercentage->CurrencyFormatUtils.valueFormatter(Rate)}
          description="Percentage of total payments that are split payments"
        />
      </div>
      <Card>
        <SplitPaymentsSectionHeader viewType setViewType />
        <div className="mb-5">
          {switch viewType {
          | Graph =>
            <div className="flex justify-center">
              <PieGraph options={pieOptions} />
            </div>
          | Table => <TableModule data={distributionData} className="mx-7" />
          }}
        </div>
      </Card>
    </PageLoaderWrapper>
  </div>
}

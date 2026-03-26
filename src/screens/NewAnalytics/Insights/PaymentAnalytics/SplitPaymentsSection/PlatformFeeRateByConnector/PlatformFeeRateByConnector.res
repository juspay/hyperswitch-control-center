open InsightsTypes
open InsightsHelper
open NewAnalyticsHelper
open PlatformFeeRateByConnectorUtils
open PlatformFeeRateByConnectorTypes
open BarGraphTypes

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [Connector, Avg_Platform_Fee_Rate]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Platform Fee Rate by Connector"
        hideTitle=true
        actualData={tableData}
        entity=InsightsPaymentAnalyticsEntity.platformFeeRateByConnectorTableEntity
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

module PlatformFeeRateByConnectorHeader = {
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

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<barGraphPayload, barGraphOptions, JSON.t>,
) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (distributionData, setDistributionData) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")

  let splitFilters = SplitPaymentsSectionUtils.splitPaymentFilter()

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let filter = generateFilterObject(
        ~globalFilters=filterValueJson,
        ~localFilters=splitFilters->Some,
      )

      let body = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=[#sessionized_avg_platform_fee_rate],
        ~groupByNames=["connector"]->Some,
        ~filter=filter->Some,
      )

      let response = await updateDetails(url, body, Post)
      let responseData =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->filterQueryData("connector")

      if responseData->Array.length > 0 {
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
      getData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, currency))

  let params = {
    data: distributionData,
    xKey: Avg_Platform_Fee_Rate->getStringFromVariant,
    yKey: "connector",
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <PlatformFeeRateByConnectorHeader viewType setViewType />
        <div className="mb-5">
          {switch viewType {
          | Graph => <BarGraph options className="mr-3" />
          | Table => <TableModule data={distributionData} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

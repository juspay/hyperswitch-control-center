open InsightsTypes
open InsightsHelper
open NewAnalyticsHelper
open PlatformFeesByConnectorUtils
open PlatformFeesByConnectorTypes

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [Connector, Total_Platform_Fees]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Platform Fees by Connector"
        hideTitle=true
        actualData={tableData}
        entity=InsightsPaymentAnalyticsEntity.platformFeesByConnectorTableEntity
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

module PlatformFeesByConnectorHeader = {
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
let make = (~entity: moduleEntity) => {
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
        ~metrics=[#sessionized_total_platform_fees],
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

  let pieOptions = platformFeesByConnectorPieMapper(distributionData)

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <PlatformFeesByConnectorHeader viewType setViewType />
        <div className="mb-5">
          {switch viewType {
          | Graph =>
            <div className="flex justify-center">
              <PieGraph options={pieOptions} />
            </div>
          | Table => <TableModule data={distributionData} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

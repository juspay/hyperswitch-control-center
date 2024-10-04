open NewAnalyticsTypes
open NewAnalyticsHelper
open NewPaymentAnalyticsEntity
open BarGraphTypes
open FailedPaymentsDistributionUtils

module TableModule = {
  @react.component
  let make = (
    ~className="",
    ~groupBy: string,
    ~domain: string,
    ~startTimeVal: string,
    ~endTimeVal: string,
  ) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let (offset, setOffset) = React.useState(_ => 0)
    let (apiData, setApiData) = React.useState(_ => JSON.Encode.null)
    let (tableData, setTableData) = React.useState(_ => []->Array.map(Nullable.make))
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let tableBorderClass = "border-2 border-solid  border-jp-gray-940 border-collapse border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let getTableAPIData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

        let distribution = Dict.make()
        distribution->Dict.set("distributionFor", "failure_reasons"->JSON.Encode.string)

        let body = NewAnalyticsUtils.requestBody(
          ~dimensions=[],
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~metrics=[],
          ~groupByNames=[groupBy]->Some,
          ~distributionValues=distribution->JSON.Encode.object->Some,
        )

        let response = await updateDetails(url, body, Post)

        setApiData(_ => response)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(() => {
      getTableAPIData()->ignore
      None
    }, [])

    React.useEffect(() => {
      let updatedTableData =
        apiData->LogicUtils.getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
      setTableData(_ => updatedTableData)
      None
    }, [apiData])

    <div className>
      <PageLoaderWrapper screenState customUI={<NoData />}>
        <LoadedTable
          visibleColumns
          title=" "
          hideTitle=true
          actualData={tableData}
          entity=failedPaymentsDistributionTableEntity
          resultsPerPage=10
          totalResults={tableData->Array.length}
          offset
          setOffset
          defaultSort
          currrentFetchCount={tableData->Array.length}
          tableLocalFilter=false
          tableheadingClass=tableBorderClass
          tableBorderClass
          ignoreHeaderBg=true
          tableDataBorderClass=tableBorderClass
          isAnalyticsModule=true
        />
      </PageLoaderWrapper>
    </div>
  }
}

module FailedPaymentsDistributionHeader = {
  @react.component
  let make = (~viewType, ~setViewType, ~groupBy, ~setGroupBy) => {
    let setViewType = value => {
      setViewType(_ => value)
    }

    let setGroupBy = value => {
      setGroupBy(_ => value)
    }

    <div className="w-full px-7 py-8 flex justify-between">
      <Tabs option={groupBy} setOption={setGroupBy} options={tabs} />
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
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (failedPaymentsDistribution, setfailedPaymentsDistribution) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getFailedPaymentsDistribution = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
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
        ~groupByNames=[groupBy.value]->Some,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let arr =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        setfailedPaymentsDistribution(_ => responseData->JSON.Encode.array)
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
      getFailedPaymentsDistribution()->ignore
    }
    None
  }, [startTimeVal, endTimeVal, groupBy.value])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <FailedPaymentsDistributionHeader viewType setViewType groupBy setGroupBy />
        <div className="mb-5">
          {switch viewType {
          | Graph =>
            <BarGraph
              entity={chartEntity}
              object={chartEntity.getObjects(
                ~data=failedPaymentsDistribution,
                ~xKey=PaymentsFailureRate->colMapper,
                ~yKey=groupBy.value,
              )}
              className="mr-3"
            />
          | Table =>
            <TableModule
              className="mx-7"
              groupBy={groupBy.value}
              domain={(entity.domain: domain :> string)}
              startTimeVal
              endTimeVal
            />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

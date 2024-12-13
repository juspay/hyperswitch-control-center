open NewAnalyticsTypes
open FailureReasonsPaymentsTypes
open NewPaymentAnalyticsEntity
open FailureReasonsPaymentsUtils
open NewAnalyticsHelper

module TableModule = {
  @react.component
  let make = (~data, ~className="", ~selectedTab: string) => {
    let (offset, setOffset) = React.useState(_ => 0)

    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let defaultCols = [Error_Reason, Failure_Reason_Count, Reasons_Count_Ratio]
    let extraTabs = selectedTab->String.split(",")->Array.map(getColumn)
    let visibleColumns = defaultCols->Array.concat(extraTabs)
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={tableData}
        entity=failureReasonsTableEntity
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
    </div>
  }
}

module FailureReasonsPaymentsHeader = {
  @react.component
  let make = (~groupBy, ~setGroupBy) => {
    let setGroupBy = value => {
      setGroupBy(_ => value)
    }

    <div className="w-full px-7 py-8 flex justify-between">
      <Tabs option={groupBy} setOption={setGroupBy} options={tabs} />
    </div>
  }
}

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (tableData, setTableData) = React.useState(_ => JSON.Encode.array([]))
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getPaymentsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=ANALYTICS_PAYMENTS,
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let groupByNames = switch entity.requestBodyConfig.groupBy {
      | Some(dimentions) =>
        dimentions
        ->Array.map(item => (item: dimension :> string))
        ->Array.concat(groupBy.value->String.split(","))
        ->Some
      | _ => None
      }

      let body = NewAnalyticsUtils.requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupByNames,
      )

      let response = await updateDetails(url, body, Post)

      let metaData = response->getDictFromJsonObject->getArrayFromDict("metaData", [])

      let data =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->modifyQuery(metaData)

      if data->Array.length > 0 {
        setTableData(_ => data->JSON.Encode.array)
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
      getPaymentsProcessed()->ignore
    }
    None
  }, [startTimeVal, endTimeVal, groupBy.value])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <FailureReasonsPaymentsHeader groupBy setGroupBy />
        <div className="mb-5">
          <TableModule data={tableData} className="mx-7" selectedTab={groupBy.value} />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

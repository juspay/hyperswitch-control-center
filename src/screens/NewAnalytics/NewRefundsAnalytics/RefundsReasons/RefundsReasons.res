open NewAnalyticsTypes
open RefundsReasonsTypes
open NewRefundsAnalyticsEntity
open RefundsReasonsUtils
open NewAnalyticsHelper

module TableModule = {
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)

    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [Refund_Reason, Refund_Reason_Count, Refund_Reason_Count_Ratio, Connector]

    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={tableData}
        entity=refundsReasonsTableEntity
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

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  open NewAnalyticsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (tableData, setTableData) = React.useState(_ => JSON.Encode.array([]))
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")

  let getRefundsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_REFUNDS),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let groupByNames = switch entity.requestBodyConfig.groupBy {
      | Some(dimentions) =>
        dimentions
        ->Array.map(item => (item: dimension :> string))
        ->Some
      | _ => None
      }

      let body = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupByNames,
        ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
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
      getRefundsProcessed()->ignore
    }
    None
  }, [startTimeVal, endTimeVal, currency])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <TableModule data={tableData} className="ml-6 mr-5 mt-6 mb-5" />
      </PageLoaderWrapper>
    </Card>
  </div>
}

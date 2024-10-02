open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open NewPaymentAnalyticsEntity
open PaymentsProcessedUtils

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

    let paymentsProcessed = switch data->getArrayFromJson([])->Array.get(0) {
    | Some(val) =>
      val
      ->getArrayFromJson([])
      ->Array.map(getDictFromJsonObject)
      ->Array.map(tableItemToObjMapper)
    | _ => []
    }->Array.map(Nullable.make)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={paymentsProcessed}
        entity=paymentsProcessedTableEntity
        resultsPerPage=10
        totalResults={paymentsProcessed->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={paymentsProcessed->Array.length}
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

module PaymentsProcessedHeader = {
  open NewAnalyticsTypes
  @react.component
  let make = (
    ~title,
    ~viewType,
    ~setViewType,
    ~selectedMetric,
    ~setSelectedMetric,
    ~granularity,
    ~setGranularity,
  ) => {
    let setViewType = value => {
      setViewType(_ => value)
    }

    let setSelectedMetric = value => {
      setSelectedMetric(_ => value)
    }

    let setGranularity = value => {
      setGranularity(_ => value)
    }

    <div className="w-full px-7 py-8 grid grid-cols-1">
      // will enable it in future
      <RenderIf condition={false}>
        <div className="flex gap-2 items-center">
          <div className="text-3xl font-600"> {title->React.string} </div>
          <StatisticsCard value="8" direction={Upward} />
        </div>
        <div className="flex justify-center">
          <Tabs option={granularity} setOption={setGranularity} options={tabs} />
        </div>
      </RenderIf>
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
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)

  let (paymentsProcessedData, setpaymentsProcessedData) = React.useState(_ => JSON.Encode.array([]))
  let (paymentsProcessedMetaData, setpaymentsProcessedMetaData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let (selectedMetric, setSelectedMetric) = React.useState(_ => defaultMetric)
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let (viewType, setViewType) = React.useState(_ => Graph)
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

      let primaryBody = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
        ~granularity=granularity.value->Some,
      )
      let secondaryBody = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime="2024-08-11T18:30:00Z", // use compare by function
        ~endTime="2024-08-18T18:30:00Z", // use compare by function
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
        ~granularity=granularity.value->Some,
      )

      let primaryResponse = await updateDetails(url, primaryBody, Post)
      let secondaryResponse = await updateDetails(url, secondaryBody, Post)
      let primaryData = primaryResponse->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let primaryMetaData = primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])

      let secondaryData =
        secondaryResponse->getDictFromJsonObject->getArrayFromDict("queryData", [])
      let secondaryMetaData =
        primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
      let modifiedData =
        [primaryData, secondaryData]
        ->Array.map(data => {
          NewAnalyticsUtils.fillMissingDataPoints(
            ~data,
            ~startDate=startTimeVal,
            ~endDate=endTimeVal,
            ~timeKey="time_bucket",
            ~defaultValue={
              "payment_count": 0,
              "payment_processed_amount": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~granularity=granularity.value,
          )
        })
        ->Identity.genericTypeToJson
      setpaymentsProcessedData(_ => modifiedData)
      setpaymentsProcessedMetaData(_ =>
        [primaryMetaData, secondaryMetaData]->Identity.genericTypeToJson
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getPaymentsProcessed()->ignore
    }
    None
  }, [startTimeVal, endTimeVal])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        // Need to modify
        <PaymentsProcessedHeader
          title={paymentsProcessedMetaData->graphTitle}
          viewType
          setViewType
          selectedMetric
          setSelectedMetric
          granularity
          setGranularity
        />
        <div className="mb-5">
          {switch viewType {
          | Graph =>
            <LineGraph
              entity={chartEntity}
              data={chartEntity.getObjects(
                ~data=paymentsProcessedData,
                ~xKey=selectedMetric.value,
                ~yKey=(#time_bucket: metrics :> string),
              )}
              className="mr-3"
            />
          | Table => <TableModule data={paymentsProcessedData} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

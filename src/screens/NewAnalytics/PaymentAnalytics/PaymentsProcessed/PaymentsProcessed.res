open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open NewPaymentAnalyticsEntity
open PaymentsProcessedUtils

module TableModule = {
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let paymentsProcessed =
      data
      ->LogicUtils.getArrayDataFromJson(tableItemToObjMapper)
      ->Array.map(Nullable.make)

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

    <div className="w-full px-7 py-8 grid grid-cols-2">
      <div className="flex gap-2 items-center">
        <div className="text-3xl font-600"> {title->React.string} </div>
        <StatisticsCard value="8" direction={Upward} />
      </div>
      // will enable it in future
      <RenderIf condition={false}>
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
  open PaymentsProcessedTypes
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => JSON.Encode.array([]))
  let (selectedMetric, setSelectedMetric) = React.useState(_ => defaultMetric)
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  Js.log2(">>", filterValueJson)

  let getPaymentsProcessed = async () => {
    try {
      //let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let url = "https://integ-api.hyperswitch.io/analytics/v1/org/metrics/payments"

      let body = NewAnalyticsUtils.requestBody(
        ~dimensions=[],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupBy=entity.requestBodyConfig.groupBy,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let response = await updateDetails(url, body, Post)
      let arr =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        setpaymentsProcessed(_ => response)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      getPaymentsProcessed()->ignore
    }
    None
  }, [startTimeVal, endTimeVal])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer styleClass="w-full h-96" />} customUI={<NoData />}>
        <PaymentsProcessedHeader
          title={paymentsProcessed->graphTitle}
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
                ~data=paymentsProcessed,
                ~xKey=selectedMetric.value,
                ~yKey=TimeBucket->colMapper,
              )}
              className="mr-3"
            />
          | Table => <TableModule data={paymentsProcessed} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}

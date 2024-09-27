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
  let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => JSON.Encode.array([]))
  let (selectedMetric, setSelectedMetric) = React.useState(_ => defaultMetric)
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)
  let (viewType, setViewType) = React.useState(_ => Graph)

  let getPaymentsProcessed = async () => {
    try {
      let response = [
        {
          "queryData": [
            {"count": 24, "amount": 952, "time_bucket": "2024-08-13 01:00:00"},
            {"count": 28, "amount": 1020, "time_bucket": "2024-08-14 02:00:00"},
            {"count": 35, "amount": 1450, "time_bucket": "2024-08-15 03:00:00"},
            {"count": 30, "amount": 1150, "time_bucket": "2024-08-16 04:00:00"},
            {"count": 29, "amount": 1200, "time_bucket": "2024-08-18 06:00:00"},
            {"count": 31, "amount": 1300, "time_bucket": "2024-08-19 07:00:00"},
            {"count": 28, "amount": 1020, "time_bucket": "2024-08-22 02:00:00"},
            {"count": 40, "amount": 1600, "time_bucket": "2024-08-24 05:00:00"},
          ],
          "metaData": [{"count": 217, "amount": 8672, "currency": "USD"}],
        },
        {
          "queryData": [
            {"count": 34, "amount": 9520, "time_bucket": "2024-08-13 01:00:00"},
            {"count": 38, "amount": 10200, "time_bucket": "2024-08-14 02:00:00"},
            {"count": 40, "amount": 11500, "time_bucket": "2024-08-16 04:00:00"},
            {"count": 50, "amount": 16000, "time_bucket": "2024-08-17 05:00:00"},
            {"count": 45, "amount": 14500, "time_bucket": "2024-08-20 03:00:00"},
            {"count": 39, "amount": 12000, "time_bucket": "2024-08-26 06:00:00"},
            {"count": 41, "amount": 13000, "time_bucket": "2024-08-27 07:00:00"},
          ],
          "metaData": [{"count": 217, "amount": 8672, "currency": "USD"}],
        },
      ]->Identity.genericTypeToJson
      setpaymentsProcessed(_ => response)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    getPaymentsProcessed()->ignore
    None
  }, [granularity])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
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
    </Card>
  </div>
}

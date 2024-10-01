open NewAnalyticsTypes
open NewAnalyticsHelper
open NewPaymentAnalyticsEntity
open BarGraphTypes
open FailedPaymentsDistributionUtils

module TableModule = {
  @react.component
  let make = (~className="") => {
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
        let _request = {
          "groupByNames": ["connector"],
          "distribution": {
            "distributionFor": "payment_error_message",
          },
        }->Identity.genericTypeToJson
        let response = [
          {
            "reason": "No error message",
            "count": 4,
            "percentage": 66.67,
            "connector": "stripe",
          },
          {
            "reason": "The payment failed.",
            "count": 2,
            "percentage": 33.33,
            "connector": "checkout",
          },
        ]->Identity.genericTypeToJson

        setApiData(_ => response)
      } catch {
      | _ => ()
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
let make = (~entity: moduleEntity, ~chartEntity: chartEntity<barGraphPayload, barGraphOptions>) => {
  let (failedPaymentsDistribution, setfailedPaymentsDistribution) = React.useState(_ =>
    JSON.Encode.array([])
  )
  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)

  let getFailedPaymentsDistribution = async () => {
    try {
      let response = [
        {
          "queryData": [
            {"payments_failure_rate": 40, "connector": "stripe"},
            {"payments_failure_rate": 60, "connector": "adyen"},
            {"payments_failure_rate": 75, "connector": "paypal"},
            {"payments_failure_rate": 65, "connector": "checkout"},
          ],
          "metaData": null,
        },
      ]->Identity.genericTypeToJson

      setfailedPaymentsDistribution(_ => response)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    getFailedPaymentsDistribution()->ignore
    None
  }, [])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
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
        | Table => <TableModule className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}

open NewAnalyticsTypes
open NewAnalyticsHelper
open NewPaymentAnalyticsEntity
open BarGraphTypes
open PaymentsDistributionUtils

module TableModule = {
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-2 border-solid  border-jp-gray-940 border-collapse border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let paymentsDistribution = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={paymentsDistribution}
        entity=paymentsDistributionTableEntity
        resultsPerPage=10
        totalResults={paymentsDistribution->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={paymentsDistribution->Array.length}
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

module PaymentsDistributionHeader = {
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
  let (paymentsDistribution, setpaymentsDistribution) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)
  let (groupBy, setGroupBy) = React.useState(_ => defaulGroupBy)

  let getPaymentsDistribution = async () => {
    try {
      let response = [
        {
          "queryData": [
            {"payments_success_rate": 40, "connector": "stripe", "payment_method": "card"},
            {"payments_success_rate": 60, "connector": "adyen", "payment_method": "wallet"},
            {"payments_success_rate": 75, "connector": "paypal", "payment_method": "gpay"},
            {"payments_success_rate": 65, "connector": "checkout", "payment_method": "apple-pay"},
          ],
          "metaData": null,
        },
      ]->Identity.genericTypeToJson

      setpaymentsDistribution(_ => response)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    getPaymentsDistribution()->ignore
    None
  }, [])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PaymentsDistributionHeader viewType setViewType groupBy setGroupBy />
      <div className="mb-5">
        {switch viewType {
        | Graph =>
          <BarGraph
            entity={chartEntity}
            object={chartEntity.getObjects(
              ~data=paymentsDistribution,
              ~xKey=PaymentsSuccessRate->colMapper,
              ~yKey=groupBy.value,
            )}
            className="mr-3"
          />
        | Table => <TableModule data={paymentsDistribution} className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}

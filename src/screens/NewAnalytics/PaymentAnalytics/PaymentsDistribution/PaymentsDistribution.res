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
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

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

@react.component
let make = (~entity: moduleEntity, ~chartEntity: chartEntity<barGraphPayload, barGraphOptions>) => {
  let (paymentsDistribution, setpaymentsDistribution) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)

  let getPaymentsDistribution = async () => {
    try {
      let response = [
        {
          "queryData": [
            {"payments_success_rate": 40, "connector": "stripe"},
            {"payments_success_rate": 60, "connector": "adyen"},
            {"payments_success_rate": 75, "connector": "paypal"},
            {"payments_success_rate": 65, "connector": "checkout"},
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
      <GraphHeader title="" viewType setViewType showTabSwitch=true />
      <div className="mb-5">
        {switch viewType {
        | Graph => <BarGraph entity={chartEntity} data={paymentsDistribution} className="mr-3" />
        | Table => <TableModule data={paymentsDistribution} className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}

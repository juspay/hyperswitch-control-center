open NewAnalyticsTypes
open NewAnalyticsHelper
open SankeyGraphTypes
@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<sankeyPayload, sankeyGraphOptions>,
) => {
  let (data, setData) = React.useState(_ => JSON.Encode.null)
  let getPaymentLieCycleData = async () => {
    try {
      let response = {
        "normal_success": 10,
        "normal_failure": 10,
        "cancelled": 10,
        "smart_retried_success": 10,
        "smart_retried_failure": 10,
        "pending": 10,
        "failed": 10,
        "partial_refunded": 10,
        "refunded": 10,
        "disputed": 10,
        "pm_awaited": 10,
        "customer_awaited": 10,
      }->Identity.genericTypeToJson

      setData(_ => response)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    getPaymentLieCycleData()->ignore
    None
  }, [])
  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <div className="mr-3 my-10">
        <SankeyGraph
          entity={chartEntity} data={chartEntity.getObjects(~data, ~xKey="", ~yKey="")}
        />
      </div>
    </Card>
  </div>
}

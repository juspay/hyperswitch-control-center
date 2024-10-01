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
      let response = [
        {
          "normal_success": 0,
          "normal_failure": 0,
          "cancelled": 0,
          "smart_retried_success": 0,
          "smart_retried_failure": 0,
          "pending": 0,
          "failed": 0,
          "partial_refunded": 0,
          "refunded": 0,
          "disputed": 0,
          "pm_awaited": 0,
          "customer_awaited": 0,
        }->Identity.genericTypeToJson,
      ]->Identity.genericTypeToJson

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

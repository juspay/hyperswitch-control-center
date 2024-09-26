open NewAnalyticsTypes
open NewAnalyticsHelper
open SankeyGraphTypes
@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<sankeyPayload, sankeyGraphOptions>,
) => {
  let (paymentsLifeCycle, setPaymentsLifeCycle) = React.useState(_ => JSON.Encode.null)
  let getPaymentLieCycleData = async () => {
    try {
      setPaymentsLifeCycle(_ => JSON.Encode.null)
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
        <SankeyGraph entity={chartEntity} data={paymentsLifeCycle} />
      </div>
    </Card>
  </div>
}

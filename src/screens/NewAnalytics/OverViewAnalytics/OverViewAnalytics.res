module PaymentsProcessed = {
  open NewAnalyticsTypes
  open NewAnalyticsHelper
  open LineGraphTypes
  @react.component
  let make = (
    ~entity: moduleEntity,
    ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
  ) => {
    let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => JSON.Encode.null)
    let getPaymentsProcessed = async () => {
      try {
        setpaymentsProcessed(_ => JSON.Encode.null)
      } catch {
      | _ => ()
      }
    }
    React.useEffect(() => {
      getPaymentsProcessed()->ignore
      None
    }, [])
    <div>
      <ModuleHeader title={entity.title} />
      <Card>
        <div className="mr-3 my-10">
          <LineGraph entity={chartEntity} data={paymentsProcessed} />
        </div>
      </Card>
    </div>
  }
}
@react.component
let make = () => {
  open OverViewAnalyticsEntity

  <div className="flex flex-col gap-5 mt-5">
    <PaymentsProcessed
      entity={paymentsProcessedEntity} chartEntity={paymentsProcessedChartEntity}
    />
  </div>
}

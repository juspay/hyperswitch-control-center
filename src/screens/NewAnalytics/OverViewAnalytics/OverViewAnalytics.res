module PaymentsProcessed = {
  open NewAnalyticsTypes
  open NewAnalyticsHelper
  open LineGraphTypes
  @react.component
  let make = (~entity: entity<lineGraphPayload, lineGraphOptions>) => {
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
      <h2 className="font-600 text-xl text-jp-gray-900 pb-5"> {entity.title->React.string} </h2>
      <Card>
        <div className="mr-3 my-10">
          <LineGraph entity={entity} data={paymentsProcessed} />
        </div>
      </Card>
    </div>
  }
}
@react.component
let make = () => {
  <div className="flex flex-col gap-5 mt-5">
    <PaymentsProcessed entity={OverViewAnalyticsEntity.paymentsProcessed} />
  </div>
}

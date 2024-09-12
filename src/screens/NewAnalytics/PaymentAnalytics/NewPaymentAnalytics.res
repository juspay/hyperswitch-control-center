// html code comes here

module PaymentLifeCycle = {
  open NewAnalyticsTypes
  open NewAnalyticsHelper
  open SankeyGraphTypes
  @react.component
  let make = (~entity: entity<sankeyPayload, sankeyGraphOptions>) => {
    let data = entity.getObjects(JSON.Encode.null)
    let options = entity.getChatOptions(data)
    let (lifeCycleOptions, setLifeCycleOptions) = React.useState(_ => options)
    let getPaymentLieCycleData = async () => {
      try {
        let apiData = entity.getObjects(JSON.Encode.null)
        let options = entity.getChatOptions(apiData)
        setLifeCycleOptions(_ => options)
      } catch {
      | _ => ()
      }
    }
    React.useEffect(() => {
      getPaymentLieCycleData()->ignore
      None
    }, [])
    <div>
      <h2 className="font-600 text-xl text-jp-gray-900 pb-5"> {entity.title->React.string} </h2>
      <Card>
        <div className="mr-3 my-10">
          <SankeyGraph options={lifeCycleOptions} />
        </div>
      </Card>
    </div>
  }
}

@react.component
let make = () => {
  open NewPaymentAnalyticsEntity
  <div className="flex flex-col gap-5 mt-5">
    <PaymentLifeCycle entity={paymentLifeCycleEntity} />
  </div>
}

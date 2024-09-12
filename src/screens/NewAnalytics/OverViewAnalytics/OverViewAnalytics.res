module PaymentsProcessed = {
  open NewAnalyticsTypes
  open NewAnalyticsHelper
  open LineGraphTypes
  @react.component
  let make = (~entity: entity<lineGraphPayload, lineGraphOptions>) => {
    let data = entity.getObjects(JSON.Encode.null)
    let options = entity.getChatOptions(data)
    let (options, setOptions) = React.useState(_ => options)
    let getPaymentsProcessed = async () => {
      try {
        let apiData = entity.getObjects(JSON.Encode.null)
        let options = entity.getChatOptions(apiData)
        setOptions(_ => options)
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
          <LineGraph options={options} />
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

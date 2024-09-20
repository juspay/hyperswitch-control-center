open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  let (paymentsSuccessRate, setpaymentsSuccessRate) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)

  let getPaymentsSuccessRate = async () => {
    try {
      let response = {
        "queryData": [
          {"payments_success_rate": 40, "time_bucket": "2024-08-13 18:30:00"},
          {"payments_success_rate": 35, "time_bucket": "2024-08-14 18:30:00"},
          {"payments_success_rate": 60, "time_bucket": "2024-08-15 18:30:00"},
          {"payments_success_rate": 70, "time_bucket": "2024-08-16 18:30:00"},
          {"payments_success_rate": 75, "time_bucket": "2024-08-17 18:30:00"},
          {"payments_success_rate": 65, "time_bucket": "2024-08-18 18:30:00"},
          {"payments_success_rate": 50, "time_bucket": "2024-08-19 18:30:00"},
        ],
        "metaData": [{"payments_success_rate": 50}],
      }->Identity.genericObjectOrRecordToJson

      let data =
        response
        ->LogicUtils.getDictFromJsonObject
        ->LogicUtils.getArrayFromDict("queryData", [])
        ->JSON.Encode.array

      setpaymentsSuccessRate(_ => data)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    getPaymentsSuccessRate()->ignore
    None
  }, [])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <GraphHeader title="88 %" viewType setViewType />
      <div className="mb-5">
        {switch viewType {
        | Graph => <LineGraph entity={chartEntity} data={paymentsSuccessRate} className="mr-3" />
        | Table => <div />
        }}
      </div>
    </Card>
  </div>
}

open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  let (paymentsSuccessRate, setpaymentsSuccessRate) = React.useState(_ => JSON.Encode.array([]))

  let getPaymentsSuccessRate = async () => {
    try {
      let response = [
        {
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
        },
        {
          "queryData": [
            {"payments_success_rate": 30, "time_bucket": "2024-08-13 18:30:00"},
            {"payments_success_rate": 90, "time_bucket": "2024-08-14 18:30:00"},
            {"payments_success_rate": 60, "time_bucket": "2024-08-15 18:30:00"},
            {"payments_success_rate": 50, "time_bucket": "2024-08-16 18:30:00"},
            {"payments_success_rate": 80, "time_bucket": "2024-08-17 18:30:00"},
            {"payments_success_rate": 65, "time_bucket": "2024-08-18 18:30:00"},
            {"payments_success_rate": 80, "time_bucket": "2024-08-19 18:30:00"},
          ],
          "metaData": [{"payments_success_rate": 50}],
        },
      ]->Identity.genericTypeToJson

      setpaymentsSuccessRate(_ => response)
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
      <div className="mb-5">
        <LineGraph entity={chartEntity} data={paymentsSuccessRate} className="mr-3" />
      </div>
    </Card>
  </div>
}

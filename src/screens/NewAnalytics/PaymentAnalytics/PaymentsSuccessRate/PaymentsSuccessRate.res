open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open PaymentsSuccessRateUtils

module PaymentsSuccessRateHeader = {
  open NewAnalyticsTypes
  @react.component
  let make = (~title, ~granularity, ~setGranularity) => {
    let setGranularity = value => {
      setGranularity(_ => value)
    }

    <div className="w-full px-7 py-8 grid grid-cols-3">
      <div className="flex gap-2 items-center">
        <div className="text-3xl font-600"> {title->React.string} </div>
        <StatisticsCard value="8" direction={Upward} />
      </div>
      <div className="flex justify-center">
        <Tabs option={granularity} setOption={setGranularity} options={tabs} />
      </div>
      <div />
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  let (paymentsSuccessRate, setpaymentsSuccessRate) = React.useState(_ => JSON.Encode.array([]))
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

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
      <PaymentsSuccessRateHeader
        title={graphTitle(paymentsSuccessRate)} granularity setGranularity
      />
      <div className="mb-5">
        <LineGraph
          entity={chartEntity}
          config={chartEntity.getObjects(
            ~data=paymentsSuccessRate,
            ~xKey=PaymentSuccessRate->colMapper,
            ~yKey=TimeBucket->colMapper,
          )}
          className="mr-3"
        />
      </div>
    </Card>
  </div>
}

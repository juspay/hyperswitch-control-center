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

    <div className="w-full px-7 py-8 grid grid-cols-2">
      <div className="flex gap-2 items-center">
        <div className="text-3xl font-600"> {title->React.string} </div>
        <StatisticsCard value="8" direction={Upward} />
      </div>
      // will enable it in future
      <RenderIf condition={false}>
        <div className="flex justify-center">
          <Tabs option={granularity} setOption={setGranularity} options={tabs} />
        </div>
      </RenderIf>
      <div />
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  open LogicUtils
  open PaymentsSuccessRateTypes
  let (paymentsSuccessRate, setpaymentsSuccessRate) = React.useState(_ => JSON.Encode.array([]))
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

  let getPaymentsSuccessRate = async () => {
    try {
      let responses = [
        {
          "queryData": [
            {"payments_success_rate": 40, "time_bucket": "2024-08-13"},
            {"payments_success_rate": 60, "time_bucket": "2024-08-15"},
            {"payments_success_rate": 70, "time_bucket": "2024-08-16"},
            {"payments_success_rate": 75, "time_bucket": "2024-08-17"},
            {"payments_success_rate": 50, "time_bucket": "2024-08-19"},
          ],
          "metaData": [{"payments_success_rate": 50}],
        }->Identity.genericTypeToJson,
        {
          "queryData": [
            {"payments_success_rate": 30, "time_bucket": "2024-08-13"},
            {"payments_success_rate": 90, "time_bucket": "2024-08-14"},
            {"payments_success_rate": 60, "time_bucket": "2024-08-15"},
            {"payments_success_rate": 65, "time_bucket": "2024-08-18"},
            {"payments_success_rate": 80, "time_bucket": "2024-08-19"},
          ],
          "metaData": [{"payments_success_rate": 50}],
        }->Identity.genericTypeToJson,
      ]

      let data =
        responses
        ->Array.map(response => {
          let responseDict = response->getDictFromJsonObject->Dict.copy
          let queryData = responseDict->getArrayFromDict("queryData", [])
          let modifiedData = NewAnalyticsUtils.fillMissingDataPoints(
            ~data=queryData,
            ~startDate="2024-08-13",
            ~endDate="2024-08-19",
            ~timeKey="time_bucket",
            ~defaultValue={payments_success_rate: 0.0, time_bucket: ""}->Identity.genericTypeToJson,
            ~granularity=granularity.value,
          )
          responseDict->Dict.set("queryData", modifiedData->JSON.Encode.array)
          responseDict
        })
        ->Identity.genericTypeToJson

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
      <PaymentsSuccessRateHeader
        title={graphTitle(paymentsSuccessRate)} granularity setGranularity
      />
      <div className="mb-5">
        <LineGraph
          entity={chartEntity}
          data={chartEntity.getObjects(
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

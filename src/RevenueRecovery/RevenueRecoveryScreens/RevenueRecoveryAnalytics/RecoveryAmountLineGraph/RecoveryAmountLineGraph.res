let overallAMountMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params

  let primaryCategories = [data]->Identity.genericTypeToJson->getCategories(0, "time_bucket")

  open LogicUtilsTypes

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories=[],
    ~title="Recovery over year",
    ~metricType=Amount,
  )

  open LogicUtils
  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: [
      getLineGraphObj(
        ~array=data->getArrayFromJson([]),
        ~key="recovered_amount",
        ~name="Recovered",
        ~color="#4287EF",
        ~isAmount=true,
      ),
      getLineGraphObj(
        ~array=data->getArrayFromJson([]),
        ~key="lost_amount",
        ~name="Lost",
        ~color="#C17D10",
        ~isAmount=true,
      ),
    ],
    title: {
      text: "",
    },
    yAxisMaxValue: None,
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Amount,
      ~currency="",
      ~suffix="",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}

@react.component
let make = () => {
  open InsightsTypes

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallData, setOverallData) = React.useState(_ => [])

  let getOverallSR = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryData = [
        {"recovered_amount": 1200, "lost_amount": 2000, "time_bucket": "2025-01-05T00:00:00Z"},
        {"recovered_amount": 1300, "lost_amount": 2100, "time_bucket": "2025-01-20T00:00:00Z"},
        {"recovered_amount": 1400, "lost_amount": 2200, "time_bucket": "2025-02-05T00:00:00Z"},
        {"recovered_amount": 1500, "lost_amount": 2300, "time_bucket": "2025-02-20T00:00:00Z"},
        {"recovered_amount": 1600, "lost_amount": 2400, "time_bucket": "2025-03-08T00:00:00Z"},
        {"recovered_amount": 1700, "lost_amount": 2500, "time_bucket": "2025-03-25T00:00:00Z"},
        {"recovered_amount": 1800, "lost_amount": 2600, "time_bucket": "2025-04-10T00:00:00Z"},
        {"recovered_amount": 2000, "lost_amount": 2700, "time_bucket": "2025-04-27T00:00:00Z"},
        {"recovered_amount": 2200, "lost_amount": 2800, "time_bucket": "2025-05-15T00:00:00Z"},
        {"recovered_amount": 3050, "lost_amount": 2120, "time_bucket": "2025-05-22T00:00:00Z"},
        {"recovered_amount": 3400, "lost_amount": 1900, "time_bucket": "2025-06-10T00:00:00Z"},
        {"recovered_amount": 4100, "lost_amount": 1700, "time_bucket": "2025-06-28T00:00:00Z"},
        {"recovered_amount": 4200, "lost_amount": 1800, "time_bucket": "2025-07-15T00:00:00Z"},
        {"recovered_amount": 3900, "lost_amount": 2100, "time_bucket": "2025-08-01T00:00:00Z"},
        {"recovered_amount": 3700, "lost_amount": 2300, "time_bucket": "2025-08-18T00:00:00Z"},
        {"recovered_amount": 3500, "lost_amount": 2500, "time_bucket": "2025-09-05T00:00:00Z"},
        {"recovered_amount": 3200, "lost_amount": 2700, "time_bucket": "2025-09-22T00:00:00Z"},
        {"recovered_amount": 3000, "lost_amount": 2900, "time_bucket": "2025-10-10T00:00:00Z"},
        {"recovered_amount": 2800, "lost_amount": 3100, "time_bucket": "2025-11-01T00:00:00Z"},
        {"recovered_amount": 2600, "lost_amount": 3300, "time_bucket": "2025-12-01T00:00:00Z"},
      ]

      setOverallData(_ => primaryData)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getOverallSR()->ignore
    None
  }, [])

  let params = {
    data: overallData->Identity.genericTypeToJson,
    xKey: "recovered_amount",
    yKey: "lost_amount",
    title: "Recovery over",
  }

  let options = LineGraphUtils.getLineGraphOptions(overallAMountMapper(~params))

  <PageLoaderWrapper
    screenState
    customLoader={<InsightsHelper.Shimmer layoutId="Recovery over" className="h-64 rounded-lg" />}
    customUI={<InsightsHelper.NoData height="h-64 p-0 -m-0" />}>
    <div>
      <div className="rounded-xl border border-gray-200 w-full bg-white">
        <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
          <h2 className="font-medium text-gray-800"> {`Recovery over year`->React.string} </h2>
        </div>
        <div className="p-4">
          <LineGraph options className="mr-3" />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}

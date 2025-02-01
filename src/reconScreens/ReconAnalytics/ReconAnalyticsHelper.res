module AnalyticsCard = {
  @react.component
  let make = (
    ~title: string,
    ~value: float,
    ~statType: LogicUtilsTypes.valueType,
    ~tooltipDescription,
  ) => {
    let formattedValue = LogicUtils.valueFormatter(value, statType)
    <div className="bg-white border rounded-lg p-6">
      <div className="flex flex-col justify-between items-center gap-4">
        <div className="text-sm font-medium text-gray-600 flex gap-2">
          <p> {title->React.string} </p>
          <ToolTip
            description={tooltipDescription}
            toolTipFor={<Icon name="info-vacent" className="text-gray-400 cursor-pointer" />}
            contentAlign=Default
            justifyClass="justify-start"
            toolTipPosition=Bottom
          />
        </div>
        <div className="text-2xl font-bold text-gray-800"> {formattedValue->React.string} </div>
      </div>
    </div>
  }
}

module ReconAnalyticsCards = {
  @react.component
  let make = (~analyticsCardData) => {
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
      <AnalyticsCard
        title="Reconciled"
        value={analyticsCardData->LogicUtils.getInt("matched", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total number of transactions that have been reconciled"
      />
      <AnalyticsCard
        title="Reconciliation Success Rate"
        value={analyticsCardData->LogicUtils.getFloat("recon_success_rate", 0.0)}
        statType={Rate}
        tooltipDescription="The percentage of transactions that have been reconciled"
      />
      <AnalyticsCard
        title="Mismatched"
        value={analyticsCardData->LogicUtils.getInt("mismatched", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total number of transactions that have been mismatched"
      />
      <AnalyticsCard
        title="Missing in Merchant"
        value={analyticsCardData->LogicUtils.getInt("missing_in_system_a", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total number of transactions that are missing in the merchant system"
      />
      <AnalyticsCard
        title="Missing in Gateway"
        value={analyticsCardData->LogicUtils.getInt("missing_in_system_b", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total number of transactions that are missing in the gateway system"
      />
      <AnalyticsCard
        title="Tax Amount"
        value={analyticsCardData->LogicUtils.getInt("tax_amount", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total tax amount"
      />
      <AnalyticsCard
        title="Settlement Amount"
        value={analyticsCardData->LogicUtils.getInt("amount_settled", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total amount settled"
      />
      <AnalyticsCard
        title="Net MDR"
        value={analyticsCardData->LogicUtils.getInt("mdr_amount", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total net MDR"
      />
      <AnalyticsCard
        title="Net Amount"
        value={analyticsCardData->LogicUtils.getInt("net_amount", 0)->Int.toFloat}
        statType={Amount}
        tooltipDescription="Total net amount"
      />
    </div>
  }
}

module ReconAnalyticsBarChart = {
  @react.component
  let make = () => {
    let fetchAnalyticsListResponse = AnalyticsData.useFetchBarGraphData()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (analyticsCardData, setAnalyticsCardData) = React.useState(_ => Dict.make())

    let getAnalyticsCardList = async _ => {
      try {
        let response = await fetchAnalyticsListResponse()
        setAnalyticsCardData(_ => response->LogicUtils.getDictFromJsonObject)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    React.useEffect(() => {
      getAnalyticsCardList()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState>
      <div className="bg-white border rounded-lg p-6 my-6">
        <div className="text-lg font-medium text-gray-600">
          {"Reconciliation Results"->React.string}
        </div>
        <BarGraph
          options={BarGraphUtils.getBarGraphOptions({
            categories: [
              analyticsCardData
              ->LogicUtils.getString("reconciled_at_time", "")
              ->Js.String.slice(~from=1, ~to_=11),
            ],
            data: [
              {
                showInLegend: false,
                name: "Recon Success Rate",
                data: [analyticsCardData->LogicUtils.getFloat("recon_success_rate", 0.0)],
                color: "#006DF9CC",
              },
            ],
            title: {text: "Recon Success Rate"},
            tooltipFormatter: ReconAnalyticsUtils.bargraphTooltipFormatter(
              ~title="Recon Success Rate",
              ~metricType=Rate,
            ),
          })}
        />
      </div>
    </PageLoaderWrapper>
  }
}

module AnalyticsCard = {
  @react.component
  let make = (~title: string, ~value: option<string>, ~statType: LogicUtilsTypes.valueType) => {
    let floatValue = switch value {
    | Some(value) =>
      switch Float.fromString(value) {
      | Some(floatValue) => floatValue
      | None => 0.0
      }
    | None => 0.0
    }

    let formattedValue = LogicUtils.valueFormatter(floatValue, statType)
    <div className="bg-white border rounded-lg p-6">
      <div className="flex flex-col justify-between items-center gap-4">
        <div className="text-sm font-medium text-gray-600 flex gap-2">
          <p> {title->React.string} </p>
          <Icon name="info-vacent" className="text-gray-400" />
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
      <RenderIf condition={analyticsCardData->Dict.keysToArray->Array.length > 0}>
        <AnalyticsCard
          title="Reconciliation Success Rate"
          value={analyticsCardData
          ->Dict.get("recon_success_rate")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Rate}
        />
        <AnalyticsCard
          title="Reconciled"
          value={analyticsCardData
          ->Dict.get("matched")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Mismatched"
          value={analyticsCardData
          ->Dict.get("mismatched")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Missing in Merchant"
          value={analyticsCardData
          ->Dict.get("missing_in_system_a")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Missing in Gateway"
          value={analyticsCardData
          ->Dict.get("missing_in_system_b")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Tax Amount"
          value={analyticsCardData
          ->Dict.get("tax_amount")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Settlement Amount"
          value={analyticsCardData
          ->Dict.get("amount_settled")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Net MDR"
          value={analyticsCardData
          ->Dict.get("mdr_amount")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
        <AnalyticsCard
          title="Net Amount"
          value={analyticsCardData
          ->Dict.get("net_amount")
          ->Option.getOr(Js.Json.string("0"))
          ->Js.Json.stringifyAny}
          statType={Amount}
        />
      </RenderIf>
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
        setAnalyticsCardData(_ => response->Identity.genericTypeToDictOfJson)
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
              switch analyticsCardData->Dict.get("reconciled_at_time") {
              | Some(timestamp) => timestamp->JSON.stringify->Js.String.slice(~from=1, ~to_=11)
              | None => "N/A"
              },
            ],
            data: [
              {
                showInLegend: false,
                name: "Recon Success Rate",
                data: [
                  switch analyticsCardData->Dict.get("recon_success_rate") {
                  | Some(successRate) =>
                    successRate->JSON.stringify->Float.fromString->Option.getOr(0.0)
                  | None => 0.0
                  },
                ],
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

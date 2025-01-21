@react.component
let make = () => {
  open ReconAnalyticsHelper

  let fetchAnalyticsListResponse = AnalyticsData.useFetchAnalyticsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (analyticsCardData, setAnalyticsCardData) = React.useState(_ => Dict.make())
  let getReportsList = async _ => {
    try {
      let response = await fetchAnalyticsListResponse()
      setAnalyticsCardData(_ => response->Identity.genericTypeToDictOfJson)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getReportsList()->ignore
    None
  }, [])

  <div>
    <PageUtils.PageHeading
      title={"Reconciliation Analytics"} subTitle={"View all the reconciliation analytics here"}
    />
    <PageLoaderWrapper screenState>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4">
        <RenderIf condition={analyticsCardData->Dict.keysToArray->Array.length > 0}>
          <AnalyticsCard
            title="Reconciliation Success Rate"
            value={analyticsCardData
            ->Dict.get("recon_success_rate")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Reconciled"
            value={analyticsCardData
            ->Dict.get("matched")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Mismatched"
            value={analyticsCardData
            ->Dict.get("mismatched")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Missing in Merchant"
            value={analyticsCardData
            ->Dict.get("missing_in_system_a")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Missing in Gateway"
            value={analyticsCardData
            ->Dict.get("missing_in_system_b")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Tax Amount"
            value={analyticsCardData
            ->Dict.get("tax_amount")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Settlement Amount"
            value={analyticsCardData
            ->Dict.get("amount_settled")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
          <AnalyticsCard
            title="Net MDR"
            value={analyticsCardData
            ->Dict.get("mdr_amount")
            ->Option.getOr(Js.Json.string("0"))
            ->Js.Json.stringifyAny}
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}

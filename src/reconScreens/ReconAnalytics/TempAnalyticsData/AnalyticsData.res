let getAnalyticsReports = () => {
  let url = `http://localhost:8000/q/internal/query?api-type=singlestat-timeseries&metrics=recon_success_rate,matched,mismatched,missing_in_system_a,missing_in_system_b,tax_amount,amount_settled,mdr_amount`
  let body = {
    "metric": [
      "recon_success_rate",
      "matched",
      "mismatched",
      "missing_in_system_a",
      "missing_in_system_b",
      "tax_amount",
      "amount_settled",
      "mdr_amount",
      "net_amount",
      "total_deductions",
    ],
    "dimensions": [
      {
        "timeZone": "Asia/Kolkata",
        "intervalCol": "reconciled_at",
        "granularity": {
          "unit": "hour",
          "duration": 1,
        },
      },
    ],
    "domain": "reconsettlement",
    "interval": {
      "start": "2025-01-19T18:30:00Z",
      "end": "2025-01-20T10:39:59Z",
    },
  }->Identity.genericTypeToJson
  (url, body)
}

let useFetchAnalyticsList = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (url, body) = getAnalyticsReports()

  async _ => {
    try {
      let res = await updateAPIHook(url, body, Post)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

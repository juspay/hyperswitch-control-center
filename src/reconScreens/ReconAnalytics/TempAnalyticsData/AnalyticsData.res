let getAnalyticsCardList = (~start: string, ~end: string) => {
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
    ],
    "dimensions": [
      {
        "timeZone": "Asia/Kolkata",
        "intervalCol": "reconciled_at",
        "granularity": {
          "unit": "day",
          "duration": 1,
        },
      },
    ],
    "domain": "reconsettlement",
    "interval": {
      "start": start,
      "end": end,
    },
  }->Identity.genericTypeToJson
  (url, body)
}

let useFetchAnalyticsCardList = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)

  async (~start, ~end) => {
    try {
      let (url, body) = getAnalyticsCardList(~start, ~end)
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

let getBarGraphData = () => {
  let url = `http://localhost:8000/q/internal/query?api-type=Top-Chart-timeseries&metrics=recon_success_rate`
  let body = {
    "metric": "recon_success_rate",
    "dimensions": [
      {
        "timeZone": "Asia/Kolkata",
        "intervalCol": "reconciled_at",
        "granularity": {
          "unit": "day",
          "duration": 1,
        },
      },
    ],
    "domain": "reconsettlement",
    "interval": {
      "start": "2025-01-31T18:30:00Z",
      "end": "2025-02-01T07:59:59Z",
    },
  }->Identity.genericTypeToJson
  (url, body)
}

let useFetchBarGraphData = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (url, body) = getBarGraphData()

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

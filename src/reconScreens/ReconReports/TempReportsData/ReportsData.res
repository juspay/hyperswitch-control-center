let getReconReports = (~merchantId) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/dashboard/reports/recon`
  let body = {
    "merchant_id": merchantId,
    "start_date": "2025-01-01T00:00:00",
    "end_date": "2025-01-31T16:12:37",
    "offset": 0,
    "limit": 100,
  }->Identity.genericTypeToJson
  (url, body)
}

let useFetchReportsList = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  let (url, body) = getReconReports(~merchantId)

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

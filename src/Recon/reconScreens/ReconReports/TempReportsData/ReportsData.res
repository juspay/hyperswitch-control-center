let getReconReports = (~merchantId, ~startDate, ~endDate) => {
  let url = `http://localhost:9000/recon-settlement-api/recon/settlements/v1/dashboard/reports/recon`
  let body = {
    "merchant_id": merchantId,
    "start_date": `${startDate}T00:00:00`,
    "end_date": `${endDate}T23:59:59`,
    "offset": 0,
    "limit": 100,
  }->Identity.genericTypeToJson
  (url, body)
}

let useFetchReportsList = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  async (~startDate, ~endDate) => {
    try {
      let (url, body) = getReconReports(~merchantId, ~startDate, ~endDate)
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

let getReconHistoryList = (~merchantId, ~startDate, ~endDate) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/runrecon/list?limit=50&offset=0&start_date=${startDate}T00:00:00&end_date=${endDate}T23:59:59&merchant_id=${merchantId}`
  url
}

let useFetchHistoryList = () => {
  open APIUtils
  let getAPIHook = useGetMethod(~showErrorToast=false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  async (~startDate, ~endDate) => {
    try {
      let url = getReconHistoryList(~merchantId, ~startDate, ~endDate)
      let res = await getAPIHook(url)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

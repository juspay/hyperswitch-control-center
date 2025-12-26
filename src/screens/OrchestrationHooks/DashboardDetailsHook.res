open HyperswitchAtom

let useFetchDashboardDetails = () => {
  let getURL = APIUtils.useGetURL()
  let setDashboardDetails = dashboardDetailsAtom->Recoil.useSetRecoilState
  let fetchDetails = APIUtils.useGetMethod()

  async (~version: UserInfoTypes.version=V1) => {
    try {
      let dashboardDetailsJSON = switch version {
      | V1 => {
          let accountUrl = getURL(~entityName=V1(MERCHANT_ACCOUNT_DETAILS), ~methodType=Get)
          await fetchDetails(accountUrl)
        }
      | V2 => {
          let accountUrl = getURL(~entityName=V2(MERCHANT_ACCOUNT_DETAILS), ~methodType=Get)
          await fetchDetails(accountUrl, ~version=V2)
        }
      }

      let dashboardDetails =
        dashboardDetailsJSON->DashboardDetailsMapper.getDashboardDetails(~version)
      setDashboardDetails(_ => dashboardDetails)
      dashboardDetails
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch dashboard details!")
        Exn.raiseError(err)
      }
    }
  }
}

let useDashboardDetailsValue = () => Recoil.useRecoilValueFromAtom(dashboardDetailsAtom)

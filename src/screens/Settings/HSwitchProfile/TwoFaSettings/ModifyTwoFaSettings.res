@react.component
let make = () => {
  open APIUtils

  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let twofactorAuthType = url.search->LogicUtils.getDictFromUrlSearchParams->Dict.get("type")
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (checkTwoFaStatusResponse, setCheckTwoFaStatusResponse) = React.useState(_ =>
    JSON.Encode.null->TwoFaUtils.jsonTocheckTwofaResponseType
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let checkTwoFaStatus = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#CHECK_TWO_FACTOR_AUTH_STATUS_V2,
        ~methodType=Get,
      )
      let response = await fetchDetails(url)
      setCheckTwoFaStatusResponse(_ => response->TwoFaUtils.jsonTocheckTwofaResponseType)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        showToast(~message="Failed to fetch 2FA status!", ~toastType=ToastError)
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/account-settings/profile"))
      }
    }
  }

  React.useEffect(() => {
    checkTwoFaStatus()->ignore
    None
  }, [])

  let pageTitle = switch twofactorAuthType->HSwitchProfileUtils.getTwoFaEnumFromString {
  | ResetTotp => "Reset totp"
  | RegenerateRecoveryCode => "Regenerate recovery codes"
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title=pageTitle />
      <BreadCrumbNavigation
        path=[{title: "Profile", link: "/account-settings/profile"}]
        currentPageTitle=pageTitle
      />
    </div>
    {switch twofactorAuthType->HSwitchProfileUtils.getTwoFaEnumFromString {
    | ResetTotp => <ResetTotp checkTwoFaStatusResponse checkTwoFaStatus />
    | RegenerateRecoveryCode => <RegenerateRC checkTwoFaStatusResponse checkTwoFaStatus />
    }}
  </PageLoaderWrapper>
}

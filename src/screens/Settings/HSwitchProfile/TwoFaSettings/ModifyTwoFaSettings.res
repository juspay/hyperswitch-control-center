@react.component
let make = () => {
  open APIUtils
  open HSwitchProfileUtils

  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let twofactorAuthType = url.search->LogicUtils.getDictFromUrlSearchParams->Dict.get("type")
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (checkStatusResponse, setCheckStatusResponse) = React.useState(_ =>
    Dict.make()->typedValueForCheckStatus
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let checkTwoFaStatus = async () => {
    try {
      open LogicUtils
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#CHECK_TWO_FACTOR_AUTH_STATUS, ~methodType=Get)
      let res = await fetchDetails(url)
      setCheckStatusResponse(_ => res->getDictFromJsonObject->typedValueForCheckStatus)
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
        cursorStyle="cursor-pointer"
      />
    </div>
    {switch twofactorAuthType->HSwitchProfileUtils.getTwoFaEnumFromString {
    | ResetTotp => <ResetTotp checkStatusResponse />
    | RegenerateRecoveryCode => <RegenerateRC checkStatusResponse />
    }}
  </PageLoaderWrapper>
}

let p2Regular = HSwitchUtils.getTextClass((P2, Regular))

module AttemptsExpiredComponent = {
  @react.component
  let make = (~expiredType, ~setTwoFaPageState, ~setTwoFaStatus) => {
    open TwoFaTypes
    open HSwitchUtils
    let handleLogout = APIUtils.useHandleLogout()
    let expiredComponent = switch expiredType {
    | TOTP_ATTEMPTS_EXPIRED =>
      <div
        className="bg-white px-6 py-12 rounded-md border w-1/3 text-center font-semibold flex flex-col gap-4">
        <p>
          {"There have been multiple unsuccessful TOTP attempts for this account. Please wait a moment before trying again."->React.string}
        </p>
        <p className={`${p2Regular} text-jp-gray-700`}>
          {"or "->React.string}
          <span
            className="cursor-pointer underline underline-offset-2 text-blue-600"
            onClick={_ => {
              setTwoFaStatus(_ => TwoFaNotExpired)
              setTwoFaPageState(_ => TOTP_INPUT_RECOVERY_CODE)
            }}>
            {"Use recovery-code"->React.string}
          </span>
        </p>
      </div>

    | RC_ATTEMPTS_EXPIRED =>
      <div
        className="bg-white px-6 py-12 rounded-md border w-1/3 text-center font-semibold flex flex-col gap-4">
        <p>
          {"There have been multiple unsuccessful Recovery code attempts for this account. Please wait a moment before trying again."->React.string}
        </p>
        <p className={`${p2Regular} text-jp-gray-700`}>
          {"or "->React.string}
          <span
            className="cursor-pointer underline underline-offset-2 text-blue-600"
            onClick={_ => {
              setTwoFaStatus(_ => TwoFaNotExpired)
              setTwoFaPageState(_ => TOTP_SHOW_QR)
            }}>
            {"Use totp"->React.string}
          </span>
        </p>
      </div>

    | TWO_FA_EXPIRED =>
      <div
        className="bg-white px-6 py-12 rounded-md border w-1/3 text-center font-semibold flex flex-col gap-4">
        <p>
          {"There have been multiple unsuccessful two-factor attempts for this account. Please wait a moment before trying again."->React.string}
        </p>
      </div>
    }

    <BackgroundImageWrapper>
      <div className="h-full w-full flex flex-col gap-4 items-center justify-center p-6 ">
        {expiredComponent}
        <div className="text-grey-200 flex gap-2">
          {"Log in with a different account?"->React.string}
          <p
            className="underline cursor-pointer underline-offset-2 hover:text-blue-700"
            onClick={_ => handleLogout()->ignore}>
            {"Click here to log out."->React.string}
          </p>
        </div>
      </div>
    </BackgroundImageWrapper>
  }
}

@react.component
let make = () => {
  open TwoFaTypes
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (twoFaStatus, setTwoFaStatus) = React.useState(_ => TwoFaNotExpired)
  let (twoFaPageState, setTwoFaPageState) = React.useState(_ => TOTP_SHOW_QR)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isSkippable, setIsSkippable) = React.useState(_ => true)
  let (checkTwoFaResonse, setCheckTwoFaResponse) = React.useState(_ =>
    JSON.Encode.null->TwoFaUtils.jsonTocheckTwofaResponseType
  )

  let handlePageBasedOnAttempts = responseDict => {
    switch responseDict {
    | Some(value) =>
      if value.totp.attemptsRemaining > 0 && value.recoveryCode.attemptsRemaining > 0 {
        setTwoFaStatus(_ => TwoFaNotExpired)
        setTwoFaPageState(_ => TOTP_SHOW_QR)
      } else if value.totp.attemptsRemaining == 0 && value.recoveryCode.attemptsRemaining == 0 {
        setTwoFaStatus(_ => TwoFaExpired(TWO_FA_EXPIRED))
      } else if value.totp.attemptsRemaining == 0 {
        setTwoFaStatus(_ => TwoFaExpired(TOTP_ATTEMPTS_EXPIRED))
      } else if value.recoveryCode.attemptsRemaining == 0 {
        setTwoFaStatus(_ => TwoFaExpired(RC_ATTEMPTS_EXPIRED))
      }
    | None => setTwoFaStatus(_ => TwoFaNotExpired)
    }
  }

  let checkTwofaStatus = async () => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#CHECK_TWO_FACTOR_AUTH_STATUS_V2,
        ~methodType=Get,
      )
      let response = await fetchDetails(url)
      let responseDict = response->TwoFaUtils.jsonTocheckTwofaResponseType
      handlePageBasedOnAttempts(responseDict.status)
      setCheckTwoFaResponse(_ => responseDict)
      setIsSkippable(_ => responseDict.isSkippable)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch!"))
        setAuthStatus(LoggedOut)
      }
    }
  }

  let errorHandling = () => {
    checkTwofaStatus()->ignore
  }

  React.useEffect(() => {
    checkTwofaStatus()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState sectionHeight="h-screen">
    {switch twoFaStatus {
    | TwoFaExpired(expiredType) =>
      <AttemptsExpiredComponent expiredType setTwoFaPageState setTwoFaStatus />
    | TwoFaNotExpired =>
      <TotpSetup twoFaPageState setTwoFaPageState errorHandling isSkippable checkTwoFaResonse />
    }}
  </PageLoaderWrapper>
}

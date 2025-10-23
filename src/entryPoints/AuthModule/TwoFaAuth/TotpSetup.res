let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module EnterAccessCode = {
  @react.component
  let make = (
    ~setTwoFaPageState,
    ~onClickVerifyAccessCode,
    ~errorHandling,
    ~isSkippable,
    ~showOnlyRc=false,
  ) => {
    let showToast = ToastState.useShowToast()
    let verifyRecoveryCodeLogic = TotpHooks.useVerifyRecoveryCode()
    let (recoveryCode, setRecoveryCode) = React.useState(_ => "")
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

    let verifyAccessCode = async _ => {
      open LogicUtils
      try {
        setButtonState(_ => Button.Loading)

        if recoveryCode->String.length > 0 {
          let body = [("recovery_code", recoveryCode->JSON.Encode.string)]->getJsonFromArrayOfJson
          let _ = await verifyRecoveryCodeLogic(body)
          onClickVerifyAccessCode(~skip_2fa=false)->ignore
        } else {
          showToast(~message="Recovery code cannot be empty!", ~toastType=ToastError)
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Something went wrong")
          let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
          let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
          if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_49 {
            errorHandling()
          }
          if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_39 {
            showToast(~message=errorMessage, ~toastType=ToastError)
          }
          setRecoveryCode(_ => "")
          setButtonState(_ => Button.Normal)
        }
      }
    }

    let handleKeyUp = ev => {
      open ReactEvent.Keyboard
      let key = ev->key
      let keyCode = ev->keyCode

      if key === "Enter" || keyCode === 13 {
        verifyAccessCode()->ignore
      }
    }
    React.useEffect(() => {
      if recoveryCode->String.length == 9 {
        Window.addEventListener("keyup", handleKeyUp)
      } else {
        Window.removeEventListener("keyup", handleKeyUp)
      }

      Some(
        () => {
          Window.removeEventListener("keyup", handleKeyUp)
        },
      )
    }, [recoveryCode])

    <div className={`bg-white h-20-rem w-200 rounded-2xl flex flex-col`}>
      <div className="p-6 border-b-2 flex justify-between items-center">
        <p className={`${h2TextStyle} text-grey-900`}> {"Enter access code"->React.string} </p>
      </div>
      <div className="px-12 py-8 flex flex-col gap-8 justify-between flex-1">
        <div className="flex flex-col justify-center items-center gap-4">
          <TwoFaElements.RecoveryCodesInput recoveryCode setRecoveryCode />
          <RenderIf condition={!showOnlyRc}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => setTwoFaPageState(_ => TwoFaTypes.TOTP_SHOW_QR)}>
                {"Use totp instead"->React.string}
              </span>
            </p>
          </RenderIf>
        </div>
        <div className="flex justify-end gap-4">
          <RenderIf condition={isSkippable}>
            <Button
              text="Skip now"
              buttonType={Secondary}
              buttonSize=Small
              onClick={_ => onClickVerifyAccessCode(~skip_2fa=true)->ignore}
              dataTestId="skip-now"
            />
          </RenderIf>
          <Button
            text="Verify recovery code"
            buttonType=Primary
            buttonSize=Small
            buttonState={recoveryCode->String.length < 9 ? Disabled : buttonState}
            customButtonStyle="group"
            onClick={_ => verifyAccessCode()->ignore}
          />
        </div>
      </div>
    </div>
  }
}

module ConfigureTotpScreen = {
  @react.component
  let make = (
    ~isQrVisible,
    ~totpUrl,
    ~twoFaStatus,
    ~setTwoFaPageState,
    ~terminateTwoFactorAuth,
    ~errorHandling,
    ~isSkippable,
    ~showOnlyTotp=false,
  ) => {
    open TwoFaTypes

    let verifyTotpLogic = TotpHooks.useVerifyTotp()

    let showToast = ToastState.useShowToast()
    let (otp, setOtp) = React.useState(_ => "")
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
    let (hasOtpError, setHasOtpError) = React.useState(_ => false)

    let verifyTOTP = async () => {
      open LogicUtils
      try {
        setButtonState(_ => Button.Loading)

        if otp->String.length > 0 {
          let body = [("totp", otp->JSON.Encode.string)]->getJsonFromArrayOfJson
          let methodType: Fetch.requestMethod = twoFaStatus === TWO_FA_SET ? Post : Put
          let _ = await verifyTotpLogic(body, methodType)

          if twoFaStatus === TWO_FA_SET {
            terminateTwoFactorAuth(~skip_2fa=false)->ignore
          } else {
            setTwoFaPageState(_ => TwoFaTypes.TOTP_SHOW_RC)
          }
        } else {
          showToast(~message="OTP field cannot be empty!", ~toastType=ToastError)
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Something went wrong")
          let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
          if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_48 {
            errorHandling()
          }
          if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_37 {
            showToast(~message="Incorrect code, please try again", ~toastType=ToastError)
            setHasOtpError(_ => true)
          }
          setOtp(_ => "")
          setButtonState(_ => Button.Normal)
        }
      }
    }

    let skipTotpSetup = async () => {
      terminateTwoFactorAuth(~skip_2fa=true)->ignore
    }

    let buttonText = twoFaStatus === TWO_FA_SET ? "Verify OTP" : "Enter Code"
    let modalHeaderText =
      twoFaStatus === TWO_FA_SET ? "Enter TOTP Code" : "Enable Two Factor Authentication"

    let handleKeyUp = ev => {
      open ReactEvent.Keyboard
      let key = ev->key
      let keyCode = ev->keyCode

      if key === "Enter" || keyCode === 13 {
        verifyTOTP()->ignore
      }
    }
    React.useEffect(() => {
      if otp->String.length == 6 {
        Window.addEventListener("keyup", handleKeyUp)
      } else {
        Window.removeEventListener("keyup", handleKeyUp)
      }

      Some(
        () => {
          Window.removeEventListener("keyup", handleKeyUp)
        },
      )
    }, [otp])

    React.useEffect(() => {
      if hasOtpError && otp->String.length > 0 {
        setHasOtpError(_ => false)
      }
      None
    }, [otp])

    <div 
      className={`bg-white ${twoFaStatus === TWO_FA_SET
              ? "h-20-rem"
              : "h-40-rem"} w-200 rounded-2xl flex flex-col`}>
      <div className="p-5 border-b-1.5 border-gray-150 flex justify-between items-center">
        <p className="px-4 text-2xl text-fs-20 font-semibold leading-8"> {modalHeaderText->React.string} </p>
      </div>
      <div className="px-8 py-2 flex flex-col gap-8 justify-end flex-1">
        <RenderIf condition={twoFaStatus === TWO_FA_NOT_SET}>
          <TwoFaElements.TotpScanQR totpUrl isQrVisible />
        </RenderIf>
        <div className="flex flex-col justify-center items-center gap-4">
          <TwoFaElements.TotpInput otp setOtp hasError={hasOtpError} isLoginFlow={twoFaStatus === TWO_FA_SET} />
          <RenderIf condition={twoFaStatus === TWO_FA_SET && !showOnlyTotp}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => setTwoFaPageState(_ => TOTP_INPUT_RECOVERY_CODE)}>
                {"Use recovery-code"->React.string}
              </span>
            </p>
          </RenderIf>
        </div>
      </div>
      <div className="p-9 border-t-1.5 border-gray-150 flex justify-end items-center">
        <div className="flex justify-end gap-4">
          <RenderIf condition={isSkippable}>
            <Button
              text="Skip now"
              buttonType={Secondary}
              buttonSize=Small
              onClick={_ => skipTotpSetup()->ignore}
              dataTestId="skip-now"
            />
          </RenderIf>
          <Button
            text=buttonText
            buttonType=Primary
            buttonSize=Small
            customButtonStyle="group"
            buttonState={otp->String.length === 6 ? buttonState : Disabled}
            onClick={_ => verifyTOTP()->ignore}
          />
        </div>  
      </div>
    </div>
  }
}

@react.component
let make = (
  ~setTwoFaPageState,
  ~twoFaPageState,
  ~errorHandling,
  ~isSkippable,
  ~checkTwoFaResonse: TwoFaTypes.checkTwofaResponseType,
) => {
  open HSwitchUtils
  open TwoFaTypes

  let getURL = APIUtils.useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchDetails = APIUtils.useGetMethod()
  let handleLogout = APIUtils.useHandleLogout()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isQrVisible, setIsQrVisible) = React.useState(_ => false)
  let (totpUrl, setTotpUrl) = React.useState(_ => "")
  let (twoFaStatus, setTwoFaStatus) = React.useState(_ => TWO_FA_NOT_SET)
  let (showNewQR, setShowNewQR) = React.useState(_ => false)

  let delayTimer = () => {
    let timeoutId = {
      setTimeout(_ => {
        setIsQrVisible(_ => true)
      }, 1000)
    }

    Some(
      () => {
        clearTimeout(timeoutId)
      },
    )
  }

  let terminateTwoFactorAuth = async (~skip_2fa) => {
    open LogicUtils
    try {
      open AuthUtils

      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#TERMINATE_TWO_FACTOR_AUTH,
        ~methodType=Get,
        ~queryParamerters=Some(`skip_two_factor_auth=${skip_2fa->getStringFromBool}`),
      )

      let response = await fetchDetails(url)
      setAuthStatus(PreLogin(getPreLoginInfo(response)))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")

        if (
          errorCode->CommonAuthUtils.errorSubCodeMapper === UR_40 ||
            errorCode->CommonAuthUtils.errorSubCodeMapper === UR_41
        ) {
          setTwoFaPageState(_ => TOTP_SHOW_QR)
          showToast(~message="Failed to complete 2fa!", ~toastType=ToastError)
          setShowNewQR(prev => !prev)
        } else {
          showToast(~message="Something went wrong", ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
  }

  let getTOTPString = async () => {
    open LogicUtils
    try {
      setTotpUrl(_ => "")
      let url = getURL(~entityName=V1(USERS), ~userType=#BEGIN_TOTP, ~methodType=Get)
      let response = await fetchDetails(url)
      let responseDict = response->getDictFromJsonObject->getJsonObjectFromDict("secret")
      switch responseDict->JSON.Classify.classify {
      | Object(objectValue) => {
          let otpUrl = objectValue->getString("totp_url", "")
          setTotpUrl(_ => otpUrl)
        }
      | _ => setTwoFaStatus(_ => TWO_FA_SET)
      }
      setScreenState(_ => PageLoaderWrapper.Success)
      // NOTE : added delay to show the QR code after loading animation
      delayTimer()->ignore
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch!"))
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect(() => {
    getTOTPString()->ignore
    None
  }, [showNewQR])

  let (showOnlyTotp, showOnlyRc) = React.useMemo1(() => {
    switch checkTwoFaResonse.status {
    | Some(value) =>
      if value.totp.attemptsRemaining === 0 && value.recoveryCode.attemptsRemaining > 0 {
        (false, true)
      } else if value.recoveryCode.attemptsRemaining === 0 && value.totp.attemptsRemaining > 0 {
        (true, false)
      } else {
        (false, false)
      }
    | None => (true, true)
    }
  }, [checkTwoFaResonse.status])

  <PageLoaderWrapper screenState sectionHeight="h-screen">
    <BackgroundImageWrapper>
      <div className="h-full w-full flex flex-col gap-4 items-center justify-center p-6">
        {switch twoFaPageState {
        | TOTP_SHOW_QR =>
          <ConfigureTotpScreen
            isQrVisible
            totpUrl
            twoFaStatus
            setTwoFaPageState
            terminateTwoFactorAuth
            errorHandling
            isSkippable
            showOnlyTotp
          />
        | TOTP_SHOW_RC =>
          <TotpRecoveryCodes
            setTwoFaPageState onClickDownload={terminateTwoFactorAuth} setShowNewQR
          />
        | TOTP_INPUT_RECOVERY_CODE =>
          <EnterAccessCode
            setTwoFaPageState
            onClickVerifyAccessCode={terminateTwoFactorAuth}
            errorHandling
            isSkippable
            showOnlyRc
          />
        }}
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
  </PageLoaderWrapper>
}

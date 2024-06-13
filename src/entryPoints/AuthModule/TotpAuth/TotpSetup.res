let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module EnterAccessCode = {
  @react.component
  let make = (~setTwoFaPageState, ~onClickVerifyAccessCode) => {
    let showToast = ToastState.useShowToast()
    let verifyRecoveryCodeLogic = TotpHooks.useVerifyRecoveryCode()
    let (recoveryCode, setRecoveryCode) = React.useState(_ => "")
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

    let verifyAccessCode = async () => {
      try {
        open LogicUtils

        setButtonState(_ => Button.Loading)

        if recoveryCode->String.length > 0 {
          let body = [("recovery_code", recoveryCode->JSON.Encode.string)]->getJsonFromArrayOfJson
          let _ = await verifyRecoveryCodeLogic(body)
          onClickVerifyAccessCode(~skip_2fa=false)->ignore
        } else {
          showToast(~message="Recovery code cannot be empty!", ~toastType=ToastError, ())
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | _ => {
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
    React.useEffect1(() => {
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
      <div className="px-12 py-8 flex flex-col gap-12 justify-between flex-1">
        <div className="flex flex-col justify-center items-center gap-4">
          <TwoFaElements.RecoveryCodesInput recoveryCode setRecoveryCode />
          <p className={`${p2Regular} text-jp-gray-700`}>
            {"Didn't get a code? "->React.string}
            <span
              className="cursor-pointer underline underline-offset-2 text-blue-600"
              onClick={_ => setTwoFaPageState(_ => TotpTypes.TOTP_SHOW_QR)}>
              {"Use totp instead"->React.string}
            </span>
          </p>
        </div>
        <div className="flex justify-end gap-4">
          <Button
            text="Skip now"
            buttonType={Secondary}
            buttonSize=Small
            onClick={_ => onClickVerifyAccessCode(~skip_2fa=true)->ignore}
          />
          <Button
            text="Verify recovery code"
            buttonType=Primary
            buttonSize=Small
            buttonState={recoveryCode->String.length < 9 ? Disabled : buttonState}
            customButtonStyle="group"
            rightIcon={CustomIcon(
              <Icon
                name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
              />,
            )}
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
  ) => {
    open TotpTypes

    let verifyTotpLogic = TotpHooks.useVerifyTotp()

    let showToast = ToastState.useShowToast()
    let (otp, setOtp) = React.useState(_ => "")
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

    let verifyTOTP = async () => {
      try {
        open LogicUtils

        setButtonState(_ => Button.Loading)

        if otp->String.length > 0 {
          let body = [("totp", otp->JSON.Encode.string)]->getJsonFromArrayOfJson
          let methodType = twoFaStatus === TWO_FA_SET ? Fetch.Post : Fetch.Put
          let _ = await verifyTotpLogic(body, methodType)

          if twoFaStatus === TWO_FA_SET {
            terminateTwoFactorAuth(~skip_2fa=false)->ignore
          } else {
            setTwoFaPageState(_ => TotpTypes.TOTP_SHOW_RC)
          }
        } else {
          showToast(~message="OTP field cannot be empty!", ~toastType=ToastError, ())
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | _ => {
          setOtp(_ => "")
          setButtonState(_ => Button.Normal)
        }
      }
    }

    let skipTotpSetup = async () => {
      terminateTwoFactorAuth(~skip_2fa=true)->ignore
    }

    let buttonText = twoFaStatus === TWO_FA_SET ? "Verify OTP" : "Enable 2FA"
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
    React.useEffect1(() => {
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

    <div
      className={`bg-white ${twoFaStatus === TWO_FA_SET
          ? "h-20-rem"
          : "h-40-rem"} w-200 rounded-2xl flex flex-col`}>
      <div className="p-6 border-b-2 flex justify-between items-center">
        <p className={`${h2TextStyle} text-grey-900`}> {modalHeaderText->React.string} </p>
      </div>
      <div className="px-12 py-8 flex flex-col gap-12 justify-between flex-1">
        <UIUtils.RenderIf condition={twoFaStatus === TWO_FA_NOT_SET}>
          <TwoFaElements.TotpScanQR totpUrl isQrVisible />
        </UIUtils.RenderIf>
        <div className="flex flex-col justify-center items-center gap-4">
          <TwoFaElements.TotpInput otp setOtp />
          <UIUtils.RenderIf condition={twoFaStatus === TWO_FA_SET}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => setTwoFaPageState(_ => TOTP_INPUT_RECOVERY_CODE)}>
                {"Use recovery-code"->React.string}
              </span>
            </p>
          </UIUtils.RenderIf>
        </div>
        <div className="flex justify-end gap-4">
          <Button
            text="Skip now"
            buttonType={Secondary}
            buttonSize=Small
            onClick={_ => skipTotpSetup()->ignore}
          />
          <Button
            text=buttonText
            buttonType=Primary
            buttonSize=Small
            customButtonStyle="group"
            buttonState={otp->String.length === 6 ? buttonState : Disabled}
            onClick={_ => verifyTOTP()->ignore}
            rightIcon={CustomIcon(
              <Icon
                name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
              />,
            )}
          />
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open HSwitchUtils
  open TotpTypes

  let getURL = APIUtils.useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchDetails = APIUtils.useGetMethod()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isQrVisible, setIsQrVisible) = React.useState(_ => false)
  let (totpUrl, setTotpUrl) = React.useState(_ => "")
  let (twoFaStatus, setTwoFaStatus) = React.useState(_ => TWO_FA_NOT_SET)
  let (twoFaPageState, setTwoFaPageState) = React.useState(_ => TotpTypes.TOTP_SHOW_QR)
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
      open TotpUtils

      let url = `${getURL(
          ~entityName=USERS,
          ~userType=#TERMINATE_TWO_FACTOR_AUTH,
          ~methodType=Get,
          (),
        )}?skip_two_factor_auth=${skip_2fa->getStringFromBool}`

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
          setTwoFaPageState(_ => TotpTypes.TOTP_SHOW_QR)
          showToast(~message="Failed to complete 2fa!", ~toastType=ToastError, ())
          setShowNewQR(prev => !prev)
        } else {
          showToast(~message="Something went wrong", ~toastType=ToastError, ())
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
  }

  let getTOTPString = async () => {
    open LogicUtils
    try {
      setTotpUrl(_ => "")
      let url = getURL(~entityName=USERS, ~userType=#BEGIN_TOTP, ~methodType=Get, ())
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

  React.useEffect1(() => {
    getTOTPString()->ignore
    None
  }, [showNewQR])

  <PageLoaderWrapper screenState>
    <BackgroundImageWrapper>
      <div className="h-full w-full flex flex-col gap-4 items-center justify-center p-6">
        {switch twoFaPageState {
        | TOTP_SHOW_QR =>
          <ConfigureTotpScreen
            isQrVisible totpUrl twoFaStatus setTwoFaPageState terminateTwoFactorAuth
          />
        | TOTP_SHOW_RC =>
          <TotpRecoveryCodes
            setTwoFaPageState onClickDownload={terminateTwoFactorAuth} setShowNewQR
          />
        | TOTP_INPUT_RECOVERY_CODE =>
          <EnterAccessCode setTwoFaPageState onClickVerifyAccessCode={terminateTwoFactorAuth} />
        }}
        <div className="text-grey-200 flex gap-2">
          {"Log in with a different account?"->React.string}
          <p
            className="underline cursor-pointer underline-offset-2 hover:text-blue-700"
            onClick={_ => setAuthStatus(LoggedOut)}>
            {"Click here to log out."->React.string}
          </p>
        </div>
      </div>
    </BackgroundImageWrapper>
  </PageLoaderWrapper>
}

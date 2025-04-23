let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module TwoFaVerifyModal = {
  @react.component
  let make = (
    ~showVerifyModal,
    ~setShowVerifyModal,
    ~buttonState,
    ~handleModalClose,
    ~otpInModal,
    ~setOtpInModal,
    ~setErrorMessage,
    ~errorMessage,
    ~recoveryCode,
    ~setRecoveryCode,
    ~twoFaState,
    ~setTwoFaState,
    ~handle2FaVerify,
    ~showOnlyTotp=false,
    ~showOnlyRc=false,
  ) => {
    open HSwitchSettingTypes

    <Modal
      modalHeading={twoFaState === Totp ? "Verify OTP" : "Verify recovery code"}
      showModal=showVerifyModal
      setShowModal=setShowVerifyModal
      onCloseClickCustomFun={handleModalClose}
      modalClass="w-fit m-auto">
      <div className="flex flex-col gap-12">
        <TwoFaHelper.Verify2FAModalComponent
          twoFaState
          setTwoFaState
          otp={otpInModal}
          setOtp={setOtpInModal}
          recoveryCode
          setRecoveryCode
          errorMessage
          setErrorMessage
          showOnlyTotp
          showOnlyRc
        />
        <div className="flex flex-1 justify-end">
          <Button
            text={twoFaState === Totp ? "Verify OTP" : "Verify recovery code"}
            buttonType=Primary
            buttonSize=Small
            buttonState={otpInModal->String.length < 6 && recoveryCode->String.length < 9
              ? Disabled
              : buttonState}
            onClick={_ => handle2FaVerify()->ignore}
            rightIcon={CustomIcon(
              <Icon
                name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
              />,
            )}
          />
        </div>
      </div>
    </Modal>
  }
}

@react.component
let make = (~checkTwoFaStatusResponse: TwoFaTypes.checkTwofaResponseType, ~checkTwoFaStatus) => {
  open LogicUtils
  open HSwitchSettingTypes
  open APIUtils

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchDetails = APIUtils.useGetMethod()
  let verifyTotpLogic = TotpHooks.useVerifyTotp()
  let verifyRecoveryCodeLogic = TotpHooks.useVerifyRecoveryCode()
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (otpInModal, setOtpInModal) = React.useState(_ => "")
  let (otp, setOtp) = React.useState(_ => "")
  let (recoveryCode, setRecoveryCode) = React.useState(_ => "")
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let (totpSecret, setTotpSecret) = React.useState(_ => RegenerateQR)
  let (twoFaState, setTwoFaState) = React.useState(_ => Totp)
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (twofaExpiredModal, setTwofaExpiredModal) = React.useState(_ => TwoFaTypes.TwoFaNotExpired)

  let generateNewSecret = async () => {
    try {
      setButtonState(_ => Button.Loading)
      let url = getURL(~entityName=V1(USERS), ~userType=#RESET_TOTP, ~methodType=Get)
      let res = await fetchDetails(url)
      setTotpSecret(_ => ShowNewTotp(
        res->getDictFromJsonObject->getDictfromDict("secret")->getString("totp_url", ""),
      ))
      setOtp(_ => "")
      setButtonState(_ => Button.Normal)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        if errorCode->CommonAuthUtils.errorSubCodeMapper === UR_40 {
          setShowVerifyModal(_ => true)
        }
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_39 {
          showToast(~message=errorMessage, ~toastType=ToastError)
        }
        setOtp(_ => "")
        setButtonState(_ => Button.Normal)
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/account-settings/profile"))
      }
    }
  }

  let verifyTOTP = async (~fromModal, ~methodType, ~otp) => {
    try {
      setButtonState(_ => Button.Loading)
      if otpInModal->String.length > 0 || otp->String.length > 0 {
        let body = [("totp", otp->JSON.Encode.string)]->getJsonFromArrayOfJson

        let _ = await verifyTotpLogic(body, methodType)
        if fromModal {
          setShowVerifyModal(_ => false)
          generateNewSecret()->ignore
        } else {
          showToast(~message="Successfully reset the totp !", ~toastType=ToastSuccess)
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/account-settings/profile"))
        }
        setOtp(_ => "")
        setOtpInModal(_ => "")
      } else {
        showToast(~message="OTP field cannot be empty!", ~toastType=ToastError)
      }
      setButtonState(_ => Button.Normal)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        if errorCode->CommonAuthUtils.errorSubCodeMapper === UR_42 {
          setTotpSecret(_ => RegenerateQR)
        }
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_48 {
          checkTwoFaStatus()->ignore
        }
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_37 && !fromModal {
          showToast(~message=errorMessage, ~toastType=ToastError)
        }
        setOtpInModal(_ => "")
        setOtp(_ => "")
        setErrorMessage(_ => errorMessage)
        setButtonState(_ => Button.Normal)
      }
    }
  }

  let verifyRecoveryCode = async () => {
    try {
      setButtonState(_ => Button.Loading)
      if recoveryCode->String.length > 0 {
        let body = [("recovery_code", recoveryCode->JSON.Encode.string)]->getJsonFromArrayOfJson
        let _ = await verifyRecoveryCodeLogic(body)
        setShowVerifyModal(_ => false)
      } else {
        showToast(~message="Recovery code cannot be empty!", ~toastType=ToastError)
      }
      setRecoveryCode(_ => "")
      setButtonState(_ => Button.Normal)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_49 {
          checkTwoFaStatus()->ignore
        }
        setRecoveryCode(_ => "")
        setErrorMessage(_ => errorMessage)
        setButtonState(_ => Button.Normal)
      }
    }
  }

  let handle2FaVerify = () => {
    switch twoFaState {
    | Totp => verifyTOTP(~fromModal=true, ~methodType=Post, ~otp={otpInModal})
    | RecoveryCode => verifyRecoveryCode()
    }
  }
  React.useEffect(() => {
    switch checkTwoFaStatusResponse.status {
    | Some(value) =>
      if value.totp.attemptsRemaining == 0 && value.recoveryCode.attemptsRemaining == 0 {
        setTwofaExpiredModal(_ => TwoFaExpired(TWO_FA_EXPIRED))
      } else if value.totp.attemptsRemaining == 0 {
        setTwofaExpiredModal(_ => TwoFaExpired(TOTP_ATTEMPTS_EXPIRED))
      } else if value.recoveryCode.attemptsRemaining == 0 {
        setTwofaExpiredModal(_ => TwoFaExpired(RC_ATTEMPTS_EXPIRED))
      } else if value.totp.isCompleted || value.recoveryCode.isCompleted {
        generateNewSecret()->ignore
      } else {
        setShowVerifyModal(_ => true)
      }

    | None => ()
    }

    None
  }, [])
  let handleKeyUp = ev => {
    open ReactEvent.Keyboard
    let key = ev->key
    let keyCode = ev->keyCode

    if key === "Enter" || keyCode === 13 {
      handle2FaVerify()->ignore
    }
  }

  React.useEffect(() => {
    if otpInModal->String.length == 6 || recoveryCode->String.length == 9 {
      Window.addEventListener("keyup", handleKeyUp)
    } else {
      Window.removeEventListener("keyup", handleKeyUp)
    }

    Some(
      () => {
        Window.removeEventListener("keyup", handleKeyUp)
      },
    )
  }, [otpInModal, recoveryCode])

  let handleModalClose = () => {
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/account-settings/profile`))
    setTwofaExpiredModal(_ => TwoFaNotExpired)
  }

  let handleConfirmAction = expiredType => {
    open TwoFaTypes
    switch expiredType {
    | TOTP_ATTEMPTS_EXPIRED =>
      setOtp(_ => "")
      setOtpInModal(_ => "")
      setErrorMessage(_ => "")
      setTwofaExpiredModal(_ => TwoFaNotExpired)
      setTwoFaState(_ => RecoveryCode)
      setShowVerifyModal(_ => true)

    | RC_ATTEMPTS_EXPIRED => {
        setRecoveryCode(_ => "")
        setErrorMessage(_ => "")
        setTwoFaState(_ => Totp)
        setShowVerifyModal(_ => true)
        setTwofaExpiredModal(_ => TwoFaNotExpired)
      }
    | TWO_FA_EXPIRED => handleModalClose()
    }
  }

  let (showOnlyTotp, showOnlyRc) = React.useMemo1(() => {
    switch checkTwoFaStatusResponse.status {
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
  }, [checkTwoFaStatusResponse.status])

  <div>
    {switch twofaExpiredModal {
    | TwoFaExpired(expiredType) =>
      <TwoFaHelper.TwoFaWarningModal
        expiredType handleConfirmAction handleOkAction={handleModalClose}
      />
    | TwoFaNotExpired =>
      <TwoFaVerifyModal
        showVerifyModal
        setShowVerifyModal
        buttonState
        handleModalClose
        otpInModal
        setOtpInModal
        setErrorMessage
        errorMessage
        recoveryCode
        setRecoveryCode
        twoFaState
        setTwoFaState
        handle2FaVerify
        showOnlyTotp
        showOnlyRc
      />
    }}
    <div className={`bg-white h-40-rem w-200 rounded-2xl flex flex-col border`}>
      <div className="p-6 border-b-2 flex justify-between items-center">
        <p className={`${h2TextStyle} text-grey-900`}> {"Enable new 2FA"->React.string} </p>
      </div>
      <div className="px-12 py-8 flex flex-col gap-12 justify-between flex-1">
        {switch totpSecret {
        | ShowNewTotp(totpUrl) =>
          <>
            <TwoFaElements.TotpScanQR totpUrl isQrVisible=true />
            <div className="flex flex-col justify-center items-center gap-4">
              <TwoFaElements.TotpInput otp setOtp />
            </div>
          </>
        | RegenerateQR => <TwoFaElements.TotpScanQR totpUrl="" isQrVisible=true />
        }}
        <div className="flex justify-end gap-4">
          {switch totpSecret {
          | RegenerateQR =>
            <Button
              text="Regenerate QR"
              buttonType=Primary
              buttonSize=Small
              customButtonStyle="group"
              buttonState
              onClick={_ => generateNewSecret()->ignore}
              rightIcon={CustomIcon(
                <Icon
                  name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
                />,
              )}
            />

          | _ =>
            <Button
              text="Verify new OTP"
              buttonType=Primary
              buttonSize=Small
              customButtonStyle="group"
              buttonState={otp->String.length === 6 ? buttonState : Disabled}
              onClick={_ => verifyTOTP(~fromModal=false, ~methodType=Put, ~otp)->ignore}
              rightIcon={CustomIcon(
                <Icon
                  name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
                />,
              )}
            />
          }}
        </div>
      </div>
    </div>
  </div>
}

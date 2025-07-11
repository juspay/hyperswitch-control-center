let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))

module TwoFaVerifyModal = {
  @react.component
  let make = (
    ~showVerifyModal,
    ~setShowVerifyModal,
    ~errorMessage,
    ~setErrorMessage,
    ~otpInModal,
    ~setOtpInModal,
    ~buttonState,
    ~verifyTOTP,
    ~handleModalClose,
  ) => {
    <Modal
      modalHeading="Verify OTP"
      showModal=showVerifyModal
      setShowModal=setShowVerifyModal
      onCloseClickCustomFun={handleModalClose}
      modalClass="w-fit m-auto">
      <div className="flex flex-col gap-12">
        <TwoFaHelper.Verify2FAModalComponent
          twoFaState=Totp
          setTwoFaState={_ => ()}
          otp={otpInModal}
          setOtp={setOtpInModal}
          errorMessage
          setErrorMessage
          showOnlyTotp=true
        />
        <div className="flex flex-1 justify-end">
          <Button
            text={"Verify OTP"}
            buttonType=Primary
            buttonSize=Small
            buttonState={otpInModal->String.length < 6 ? Disabled : buttonState}
            onClick={_ => verifyTOTP()->ignore}
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
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let verifyTotpLogic = TotpHooks.useVerifyTotp()
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (otpInModal, setOtpInModal) = React.useState(_ => "")
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let (recoveryCodes, setRecoveryCodes) = React.useState(_ => [])
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (twofaExpiredModal, setTwofaExpiredModal) = React.useState(_ => TwoFaTypes.TwoFaNotExpired)

  let generateRecoveryCodes = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(USERS), ~userType=#GENERATE_RECOVERY_CODES, ~methodType=Get)
      let response = await fetchDetails(url)
      let recoveryCodesValue = response->getDictFromJsonObject->getStrArray("recovery_codes")
      setRecoveryCodes(_ => recoveryCodesValue)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setButtonState(_ => Button.Normal)
        showToast(~message="Failed to generate recovery codes!", ~toastType=ToastError)
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/account-settings/profile`))
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  let handleModalClose = () => {
    setTwofaExpiredModal(_ => TwoFaNotExpired)
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/account-settings/profile`))
  }

  let verifyTOTP = async () => {
    try {
      setButtonState(_ => Button.Loading)
      if otpInModal->String.length > 0 {
        let body = [("totp", otpInModal->JSON.Encode.string)]->getJsonFromArrayOfJson
        let _ = await verifyTotpLogic(body, Post)
        setShowVerifyModal(_ => false)
        generateRecoveryCodes()->ignore
      } else {
        showToast(~message="OTP field cannot be empty!", ~toastType=ToastError)
      }
      setOtpInModal(_ => "")
      setButtonState(_ => Button.Normal)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_48 {
          checkTwoFaStatus()->ignore
        }
        setOtpInModal(_ => "")
        setErrorMessage(_ => errorMessage)
        setButtonState(_ => Button.Normal)
      }
    }
  }

  React.useEffect(() => {
    switch checkTwoFaStatusResponse.status {
    | Some(value) =>
      if value.totp.attemptsRemaining == 0 {
        setTwofaExpiredModal(_ => TwoFaExpired(TWO_FA_EXPIRED))
      } else if value.totp.isCompleted {
        generateRecoveryCodes()->ignore
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
      verifyTOTP()->ignore
    }
  }

  React.useEffect(() => {
    if otpInModal->String.length == 6 {
      Window.addEventListener("keyup", handleKeyUp)
    } else {
      Window.removeEventListener("keyup", handleKeyUp)
    }

    Some(
      () => {
        Window.removeEventListener("keyup", handleKeyUp)
      },
    )
  }, [otpInModal])

  let copyRecoveryCodes = ev => {
    ev->ReactEvent.Mouse.stopPropagation
    Clipboard.writeText(JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3))
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
  }

  let handleConfirmAction = expiredType => {
    open TwoFaTypes
    switch expiredType {
    | RC_ATTEMPTS_EXPIRED => {
        setOtpInModal(_ => "")
        setErrorMessage(_ => "")
        setTwofaExpiredModal(_ => TwoFaNotExpired)
        setShowVerifyModal(_ => true)
      }
    | _ => handleModalClose()
    }
  }

  <PageLoaderWrapper screenState>
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
          errorMessage
          setErrorMessage
          otpInModal
          setOtpInModal
          buttonState
          verifyTOTP
          handleModalClose
        />
      }}
      <div className={`bg-white border h-40-rem w-133 rounded-2xl flex flex-col`}>
        <div className="p-6 border-b-2 flex justify-between items-center">
          <p className={`${h2TextStyle} text-grey-900`}>
            {"Two factor recovery codes"->React.string}
          </p>
        </div>
        <div className="px-8 py-8 flex flex-col flex-1 justify-between">
          <div className="flex flex-col  gap-6">
            <p className="text-jp-gray-700">
              {"Recovery codes provide a way to access your account if you lose your device and can't receive two-factor authentication codes."->React.string}
            </p>
            <HSwitchUtils.AlertBanner
              bannerContent={<div>
                {"These codes are the last resort for accessing your account in case you lose your password and second factors. If you cannot find these codes, you will lose access to your account."->React.string}
              </div>}
              bannerType=Warning
            />
            <TwoFaElements.ShowRecoveryCodes recoveryCodes />
          </div>
          <div className="flex gap-4 justify-end">
            <Button
              leftIcon={CustomIcon(<Icon name="nd-copy" className="cursor-pointer" />)}
              text={"Copy"}
              buttonType={Secondary}
              buttonSize={Small}
              onClick={copyRecoveryCodes}
            />
            <Button
              leftIcon={FontAwesome("download-api-key")}
              text={"Download"}
              buttonType={Primary}
              buttonSize={Small}
              onClick={_ => {
                TwoFaUtils.downloadRecoveryCodes(~recoveryCodes)
                showToast(
                  ~message="Successfully regenerated new recovery codes !",
                  ~toastType=ToastSuccess,
                )
                RescriptReactRouter.push(
                  GlobalVars.appendDashboardPath(~url="/account-settings/profile"),
                )
              }}
            />
          </div>
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}

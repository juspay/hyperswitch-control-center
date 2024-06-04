let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module Verify2FAModalComponent = {
  @react.component
  let make = (
    ~twoFaState,
    ~setTwoFaState,
    ~errorMessage,
    ~setErrorMessage,
    ~otp="",
    ~setOtp=_ => (),
    ~recoveryCode="",
    ~setRecoveryCode=_ => (),
    ~showOnlyTotp=false,
  ) => {
    open HSwitchSettingTypes
    <div className="flex flex-col items-center gap-2 ">
      {switch twoFaState {
      | Totp =>
        <>
          <TwoFaElements.TotpInput otp setOtp />
          <UIUtils.RenderIf condition={!showOnlyTotp}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => {
                  setOtp(_ => "")
                  setErrorMessage(_ => "")
                  setTwoFaState(_ => RecoveryCode)
                }}>
                {"Use recovery-code"->React.string}
              </span>
            </p>
          </UIUtils.RenderIf>
        </>

      | RecoveryCode =>
        <>
          <TwoFaElements.RecoveryCodesInput recoveryCode setRecoveryCode />
          <p className={`${p2Regular} text-jp-gray-700`}>
            {"Didn't get a code? "->React.string}
            <span
              className="cursor-pointer underline underline-offset-2 text-blue-600"
              onClick={_ => {
                setRecoveryCode(_ => "")
                setErrorMessage(_ => "")
                setTwoFaState(_ => Totp)
              }}>
              {"Use totp instead"->React.string}
            </span>
          </p>
        </>
      }}
      <UIUtils.RenderIf condition={errorMessage->String.length > 0}>
        <div className="text-sm text-red-600"> {`Error: ${errorMessage}`->React.string} </div>
      </UIUtils.RenderIf>
    </div>
  }
}

module ResetTotp = {
  @react.component
  let make = (~checkStatusResponse) => {
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

    let generateNewSecret = async () => {
      try {
        setButtonState(_ => Button.Loading)
        let url = getURL(~entityName=USERS, ~userType=#RESET_TOTP, ~methodType=Get, ())
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
          setOtp(_ => "")
          setButtonState(_ => Button.Normal)
          RescriptReactRouter.push(
            HSwitchGlobalVars.appendDashboardPath(~url="/account-settings/profile"),
          )
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
            showToast(~message="Successfully reset the totp !", ~toastType=ToastSuccess, ())
            RescriptReactRouter.push(
              HSwitchGlobalVars.appendDashboardPath(~url="/account-settings/profile"),
            )
          }
        } else {
          showToast(~message="OTP field cannot be empty!", ~toastType=ToastError, ())
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
          showToast(~message="Recovery code cannot be empty!", ~toastType=ToastError, ())
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Verification Failed")
          let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
          setRecoveryCode(_ => "")
          setErrorMessage(_ => errorMessage)
          setButtonState(_ => Button.Normal)
        }
      }
    }

    let handle2FaVerify = () => {
      switch twoFaState {
      | Totp => verifyTOTP(~fromModal=true, ~methodType=Fetch.Post, ~otp={otpInModal})
      | RecoveryCode => verifyRecoveryCode()
      }
    }

    React.useEffect0(() => {
      if checkStatusResponse.totp || checkStatusResponse.recovery_code {
        generateNewSecret()->ignore
      } else {
        setShowVerifyModal(_ => true)
      }
      None
    })

    let handleModalClose = () => {
      RescriptReactRouter.push(
        HSwitchGlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
      )
    }

    <div>
      <Modal
        modalHeading={twoFaState === Totp ? "Verify OTP" : "Verify recovery code"}
        showModal=showVerifyModal
        setShowModal=setShowVerifyModal
        onCloseClickCustomFun={handleModalClose}
        modalClass="w-fit m-auto">
        <div className="flex flex-col gap-12">
          <Verify2FAModalComponent
            twoFaState
            setTwoFaState
            otp={otpInModal}
            setOtp={setOtpInModal}
            recoveryCode
            setRecoveryCode
            errorMessage
            setErrorMessage
          />
          <div className="flex flex-1 justify-end">
            <Button
              text={twoFaState === Totp ? "Verify OTP" : "Verify recovery code"}
              buttonType=Primary
              buttonSize=Small
              buttonState={otpInModal->String.length === 0 && recoveryCode->String.length === 0
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
                onClick={_ => verifyTOTP(~fromModal=false, ~methodType=Fetch.Put, ~otp)->ignore}
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
}

module RegenerateRecoveryCodes = {
  @react.component
  let make = (~checkStatusResponse: HSwitchSettingTypes.checkStatusType) => {
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

    let generateRecoveryCodes = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=USERS, ~userType=#GENERATE_RECOVERY_CODES, ~methodType=Get, ())
        let response = await fetchDetails(url)
        let recoveryCodesValue = response->getDictFromJsonObject->getStrArray("recovery_codes")
        setRecoveryCodes(_ => recoveryCodesValue)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setButtonState(_ => Button.Normal)
          showToast(~message="Failed to generate recovery codes!", ~toastType=ToastError, ())
          RescriptReactRouter.push(
            HSwitchGlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
          )
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      }
    }

    let handleModalClose = () => {
      RescriptReactRouter.push(
        HSwitchGlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
      )
    }

    let verifyTOTP = async () => {
      try {
        setButtonState(_ => Button.Loading)
        if otpInModal->String.length > 0 {
          let body = [("totp", otpInModal->JSON.Encode.string)]->getJsonFromArrayOfJson
          let _ = await verifyTotpLogic(body, Fetch.Post)
          setShowVerifyModal(_ => false)
          generateRecoveryCodes()->ignore
        } else {
          showToast(~message="OTP field cannot be empty!", ~toastType=ToastError, ())
        }
        setButtonState(_ => Button.Normal)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Verification Failed")
          let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
          setOtpInModal(_ => "")
          setErrorMessage(_ => errorMessage)
          setButtonState(_ => Button.Normal)
        }
      }
    }

    React.useEffect0(() => {
      if checkStatusResponse.totp {
        generateRecoveryCodes()->ignore
      } else {
        setShowVerifyModal(_ => true)
      }
      None
    })

    let copyRecoveryCodes = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3))
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    <PageLoaderWrapper screenState>
      <div>
        <Modal
          modalHeading="Verify OTP"
          showModal=showVerifyModal
          setShowModal=setShowVerifyModal
          onCloseClickCustomFun={handleModalClose}
          modalClass="w-fit m-auto">
          <div className="flex flex-col gap-12">
            <Verify2FAModalComponent
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
                buttonState={otpInModal->String.length === 0 ? Disabled : buttonState}
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
              <HSwitchUtils.WarningArea
                warningText="These codes are the last resort for accessing your account in case you lose your password and second factors. If you cannot find these codes, you will lose access to your account."
              />
              <TwoFaElements.ShowRecoveryCodes recoveryCodes />
            </div>
            <div className="flex gap-4 justify-end">
              <Button
                leftIcon={CustomIcon(<img src={`/assets/CopyToClipboard.svg`} />)}
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
                  TotpUtils.downloadRecoveryCodes(~recoveryCodes)
                  showToast(
                    ~message="Successfully regenerated new recovery codes !",
                    ~toastType=ToastSuccess,
                    (),
                  )
                  RescriptReactRouter.push(
                    HSwitchGlobalVars.appendDashboardPath(~url="/account-settings/profile"),
                  )
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

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
      let url = getURL(
        ~entityName=USERS,
        ~userType=#CHECK_TWO_FACTOR_AUTH_STATUS,
        ~methodType=Get,
        (),
      )
      let res = await fetchDetails(url)
      setCheckStatusResponse(_ => res->getDictFromJsonObject->typedValueForCheckStatus)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        showToast(~message="Failed to fetch 2FA status!", ~toastType=ToastError, ())
        RescriptReactRouter.push(
          HSwitchGlobalVars.appendDashboardPath(~url="/account-settings/profile"),
        )
      }
    }
  }

  React.useEffect0(() => {
    checkTwoFaStatus()->ignore
    None
  })

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
    | RegenerateRecoveryCode => <RegenerateRecoveryCodes checkStatusResponse />
    }}
  </PageLoaderWrapper>
}

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
  ) => {
    open HSwitchSettingTypes
    <div className="flex flex-col items-center gap-2 ">
      {switch twoFaState {
      | Totp =>
        <>
          <TwoFaElements.TotpInput otp setOtp />
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
        modalHeading="Verify OTP"
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

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title="Reset totp" />
      <BreadCrumbNavigation
        path=[{title: "Profile", link: "/account-settings/profile"}]
        currentPageTitle="Reset totp"
        cursorStyle="cursor-pointer"
      />
    </div>
    {switch twofactorAuthType->HSwitchProfileUtils.getTwoFaEnumFromString {
    | ResetTotp => <ResetTotp checkStatusResponse />
    | RegenerateRecoveryCode => React.null
    }}
  </PageLoaderWrapper>
}

let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module ConfirmPopUpElement = {
  @react.component
  let make = (~recoveryCodes, ~downloadRecoveryCodes) => {
    open LogicUtils
    let showToast = ToastState.useShowToast()

    let firstHalf = recoveryCodes->Array.copy
    firstHalf->Array.splice(~start=0, ~remove=recoveryCodes->Array.length / 2, ~insert=[])

    let secondHalf = recoveryCodes->Array.copy
    secondHalf->Array.splice(
      ~start=recoveryCodes->Array.length / 2,
      ~remove=recoveryCodes->Array.length,
      ~insert=[],
    )

    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3))
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    <div className="flex flex-col gap-2 w-full">
      <div className="flex gap-1">
        <p>
          {"Have you secured your recovery codes? If not,"->React.string}
          <span
            className="text-blue-600 underline underline-offset-2 mx-1 cursor-pointer"
            onClick={_ => downloadRecoveryCodes()}>
            {"download"->React.string}
          </span>
          {"them now as this prompt may not reappear."->React.string}
        </p>
      </div>
      <UIUtils.RenderIf condition={recoveryCodes->Array.length > 0}>
        <div className="border border-gray-200 rounded-md bg-jp-gray-300 p-4 flex justify-between">
          <div className="flex gap-6">
            <div className="flex flex-col gap-2 ">
              {firstHalf
              ->Array.map(recoveryCode => <p> {recoveryCode->React.string} </p>)
              ->React.array}
            </div>
            <div className="flex flex-col gap-2 ">
              {secondHalf
              ->Array.map(recoveryCode => <p> {recoveryCode->React.string} </p>)
              ->React.array}
            </div>
          </div>
          <img
            src={`/assets/CopyToClipboard.svg`}
            className="cursor-pointer h-fit w-fit"
            onClick={onCopyClick}
          />
        </div>
      </UIUtils.RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  open HSwitchUtils
  open APIUtils

  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let getURL = useGetURL()

  let (otp, setOtp) = React.useState(_ => "")
  let (totpUrl, setTotpUrl) = React.useState(_ => "")
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (showQR, setShowQR) = React.useState(_ => true)
  let (recoveryCodes, setRecoveryCodes) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let (isQrVisible, setIsQrVisible) = React.useState(_ => false)

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
          let recoveryCodes = objectValue->getStrArray("recovery_codes")
          setTotpUrl(_ => otpUrl)
          setRecoveryCodes(_ => recoveryCodes)
        }
      | _ => setShowQR(_ => false)
      }

      setScreenState(_ => PageLoaderWrapper.Success)

      // NOTE : added delay to show the QR code after loading animation
      delayTimer()->ignore
    } catch {
    | _ => {
        setButtonState(_ => Button.Normal)
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch!"))
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    getTOTPString()->ignore
    None
  })

  let verifyTotpLogic = async body => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#VERIFY_TOTP, ~methodType=Get, ())
      let response = await updateDetails(url, body, Post, ())
      response
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let verifyTOTP = async () => {
    try {
      open LogicUtils
      open TotpUtils

      setButtonState(_ => Button.Loading)
      if otp->String.length > 0 {
        let body = [("totp", otp->JSON.Encode.string)]->getJsonFromArrayOfJson
        let response = await verifyTotpLogic(body)
        setAuthStatus(LoggedIn(TotpAuth(getTotpAuthInfo(response))))
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
    try {
      open LogicUtils
      open TotpUtils
      setButtonState(_ => Button.Loading)
      let body = [("totp", JSON.Encode.null)]->getJsonFromArrayOfJson
      let response = await verifyTotpLogic(body)
      setAuthStatus(LoggedIn(TotpAuth(getTotpAuthInfo(response))))
      setButtonState(_ => Button.Normal)
    } catch {
    | _ => {
        setButtonState(_ => Button.Normal)
        showToast(~message="Something went wrong!", ~toastType=ToastError, ())
      }
    }
  }

  let downloadRecoveryCodes = () => {
    open LogicUtils
    try {
      DownloadUtils.downloadOld(
        ~fileName="recoveryCodes.txt",
        ~content=JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3),
      )
    } catch {
    | _ => showToast(~message="Failed to fetch recovery codes!", ~toastType=ToastError, ())
    }
  }

  let confirmRecoveryCodesPopUp = () => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Confirm action",
      description: <ConfirmPopUpElement recoveryCodes downloadRecoveryCodes />,
      handleConfirm: {
        text: "Continue",
        onClick: _ => verifyTOTP()->ignore,
      },
    })
  }

  let handleTotpSubmitClick = () => {
    if recoveryCodes->Array.length > 0 {
      confirmRecoveryCodesPopUp()
    } else {
      verifyTOTP()->ignore
    }
  }

  let buttonText = showQR ? "Enable 2FA" : "Verify OTP"
  let modalHeaderText = showQR ? "Enable Two Factor Authentication" : "Enter TOTP Code"

  <PageLoaderWrapper screenState>
    <BackgroundImageWrapper>
      <div className="h-full w-full flex flex-col gap-4 items-center justify-center p-6">
        <div
          className={`bg-white ${showQR
              ? "h-40-rem"
              : "h-20-rem"} w-200 rounded-2xl flex flex-col`}>
          <div className="p-6 border-b-2 flex justify-between items-center">
            <p className={`${h2TextStyle} text-grey-900`}> {modalHeaderText->React.string} </p>
          </div>
          <div className="px-12 py-8 flex flex-col gap-12 justify-between flex-1">
            <UIUtils.RenderIf condition={showQR}>
              <div className="grid grid-cols-4 gap-4 w-full">
                <div className="flex flex-col gap-10 col-span-3">
                  <p> {"Use any authenticator app to complete the setup"->React.string} </p>
                  <div className="flex flex-col gap-4">
                    <p className=p2Regular>
                      {"Follow these steps to configure two factor authentication:"->React.string}
                    </p>
                    <div className="flex flex-col gap-4 ml-2">
                      <p className={`${p2Regular} opacity-60 flex gap-2 items-center`}>
                        <div className="text-white rounded-full bg-grey-900 opacity-50 px-2 py-0.5">
                          {"1"->React.string}
                        </div>
                        {"Scan the QR code shown on the screen with your authenticator application"->React.string}
                      </p>
                      <p className={`${p2Regular} opacity-60 flex gap-2 items-center`}>
                        <div className="text-white rounded-full bg-grey-900 opacity-50 px-2 py-0.5">
                          {"2"->React.string}
                        </div>
                        {"Enter the OTP code displayed on the authenticator app in below text field or textbox"->React.string}
                      </p>
                    </div>
                  </div>
                </div>
                <div
                  className={`flex flex-col gap-2 col-span-1 items-center justify-center  ${totpUrl->String.length > 0
                      ? "blur-none"
                      : "blur-sm"}`}>
                  <p className=p3Regular> {"Scan the QR Code into your app"->React.string} </p>
                  {if isQrVisible {
                    <ReactQRCode value=totpUrl size=150 />
                  } else {
                    <Icon
                      name="spinner"
                      size=20
                      className="animate-spin"
                      parentClass="w-full h-full flex justify-center items-center"
                    />
                  }}
                </div>
              </div>
              <div className="h-px w-11/12 bg-grey-200 opacity-50" />
            </UIUtils.RenderIf>
            <div className="flex flex-col gap-4 items-center">
              <p>
                {"Enter a 6-digit authentication code generated by you authenticator app"->React.string}
              </p>
              <OtpInput value={otp} setValue={setOtp} />
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
                onClick={_ => handleTotpSubmitClick()}
                rightIcon={CustomIcon(
                  <Icon
                    name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
                  />,
                )}
              />
            </div>
          </div>
        </div>
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

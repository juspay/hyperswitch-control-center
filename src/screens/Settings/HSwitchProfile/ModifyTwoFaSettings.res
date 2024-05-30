let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module ResetTotp = {
  @react.component
  let make = (~checkStatusResponse) => {
    open LogicUtils

    let showToast = ToastState.useShowToast()
    // let fetchDetails = APIUtils.useGetMethod()
    // let verifyTotpLogic = TotpHooks.useVerifyTotp()
    let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
    let (otpInModal, setOtpInModal) = React.useState(_ => "")
    let (otp, setOtp) = React.useState(_ => "")
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
    let (totpUrl, setTotpUrl) = React.useState(_ => "")

    let generateNewSecret = async () => {
      try {
        // TODO: add generate new secret api
        // let url = getURL(~entityName=USERS, ~userType=#RESET_TOTP, ~methodType=Get, ())
        // let res =fetchDetails(url)
        let secretObj =
          [
            ("secret", "aerf"->JSON.Encode.string),
            ("totp_url", "otpauth:wefrq3"->JSON.Encode.string),
          ]
          ->Dict.fromArray
          ->JSON.Encode.object
        let res = [("secret", secretObj)]->Dict.fromArray->JSON.Encode.object

        setTotpUrl(_ =>
          res->getDictFromJsonObject->getDictfromDict("secret")->getString("totp_url", "")
        )
      } catch {
      | _ => {
          setOtp(_ => "")
          setButtonState(_ => Button.Normal)
        }
      }
    }

    let verifyTOTP = async (~fromModal, ~methodType) => {
      try {
        setButtonState(_ => Button.Loading)
        if otpInModal->String.length > 0 || otp->String.length > 0 {
          // let body = [("totp", otp->JSON.Encode.string)]->getJsonFromArrayOfJson

          // let _ = await verifyTotpLogic(body, methodType)
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
      | _ => {
          setOtpInModal(_ => "")
          setOtp(_ => "")
          setButtonState(_ => Button.Normal)
        }
      }
    }

    React.useEffect0(() => {
      if (
        checkStatusResponse->getBool("totp", false) ||
          checkStatusResponse->getBool("recovery_code", false)
      ) {
        generateNewSecret()->ignore
      } else {
        setShowVerifyModal(_ => true)
      }
      None
    })

    <div>
      <Modal
        modalHeading="Verify OTP"
        showModal=showVerifyModal
        setShowModal=setShowVerifyModal
        modalClass="w-fit m-auto">
        <div className="flex flex-col gap-12">
          <TwoFaElements.TotpInput otp={otpInModal} setOtp={setOtpInModal} />
          <div className="flex flex-1 justify-end">
            <Button
              text="Verify OTP"
              buttonType=Primary
              buttonSize=Small
              buttonState={buttonState}
              onClick={_ => verifyTOTP(~fromModal=true, ~methodType=Fetch.Post)->ignore}
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
          <TwoFaElements.TotpScanQR totpUrl isQrVisible=true />
          <div className="flex flex-col justify-center items-center gap-4">
            <TwoFaElements.TotpInput otp setOtp />
          </div>
          <div className="flex justify-end gap-4">
            <Button
              text="Verify new OTP"
              buttonType=Primary
              buttonSize=Small
              customButtonStyle="group"
              buttonState={otp->String.length === 6 ? buttonState : Disabled}
              onClick={_ => verifyTOTP(~fromModal=false, ~methodType=Fetch.Put)->ignore}
              rightIcon={CustomIcon(
                <Icon
                  name="thin-right-arrow" size=20 className="group-hover:scale-125 cursor-pointer"
                />,
              )}
            />
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils

  let url = RescriptReactRouter.useUrl()
  let twofactorAuthType = url.search->LogicUtils.getDictFromUrlSearchParams->Dict.get("type")
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (checkStatusResponse, setCheckStatusResponse) = React.useState(_ => Dict.make())
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
      setCheckStatusResponse(_ => res->getDictFromJsonObject)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
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
    | RegenerateRecoveryCodes => React.null
    }}
  </PageLoaderWrapper>
}

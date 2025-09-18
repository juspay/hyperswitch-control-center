let p2Regular = HSwitchUtils.getTextClass((P2, Regular))

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
    ~showOnlyRc=false,
  ) => {
    open HSwitchSettingTypes
    let handleOnClick = (~stateToSet) => {
      setOtp(_ => "")
      setRecoveryCode(_ => "")
      setErrorMessage(_ => "")
      setTwoFaState(_ => stateToSet)
    }

    <div className="flex flex-col items-center gap-2 ">
      {switch twoFaState {
      | Totp =>
        <>
          <TwoFaElements.TotpInput otp setOtp />
          <RenderIf condition={!showOnlyTotp}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => handleOnClick(~stateToSet=RecoveryCode)}>
                {"Use recovery-code"->React.string}
              </span>
            </p>
          </RenderIf>
        </>

      | RecoveryCode =>
        <>
          <TwoFaElements.RecoveryCodesInput recoveryCode setRecoveryCode />
          <RenderIf condition={!showOnlyRc}>
            <p className={`${p2Regular} text-jp-gray-700`}>
              {"Didn't get a code? "->React.string}
              <span
                className="cursor-pointer underline underline-offset-2 text-blue-600"
                onClick={_ => handleOnClick(~stateToSet=Totp)}>
                {"Use totp instead"->React.string}
              </span>
            </p>
          </RenderIf>
        </>
      }}
      <RenderIf condition={errorMessage->LogicUtils.isNonEmptyString}>
        <div className="text-sm text-red-600"> {`Error: ${errorMessage}`->React.string} </div>
      </RenderIf>
    </div>
  }
}

module TwoFaWarningModal = {
  @react.component
  let make = (~expiredType, ~handleConfirmAction, ~handleOkAction) => {
    open TwoFaTypes
    open PopUpState
    let showPopUp = PopUpState.useShowPopUp()

    {
      switch expiredType {
      | TOTP_ATTEMPTS_EXPIRED =>
        showPopUp({
          popUpType: (Warning, WithIcon),
          heading: "Maximum Attempts Reached",
          description: React.string(
            "You've reached the maximum number of TOTP attempts. To continue, please use your recovery code or wait sometime before trying again.",
          ),
          handleCancel: {text: "OK", onClick: {_ => handleOkAction()}},
          handleConfirm: {
            text: "Use recovery code",
            onClick: {_ => handleConfirmAction(expiredType)},
          },
          showCloseIcon: false,
        })
      | RC_ATTEMPTS_EXPIRED =>
        showPopUp({
          popUpType: (Warning, WithIcon),
          heading: "Maximum Attempts Reached",
          description: React.string(
            "You've reached the maximum number of recovery code attempts. To continue, please use your TOTP or wait a while before trying again.",
          ),
          handleCancel: {text: "OK", onClick: {_ => handleOkAction()}},
          handleConfirm: {text: "Use totp code", onClick: {_ => handleConfirmAction(expiredType)}},
          showCloseIcon: false,
        })
      | TWO_FA_EXPIRED =>
        showPopUp({
          popUpType: (Warning, WithIcon),
          heading: "Maximum Attempts Reached",
          description: React.string(
            "You have exceeded the maximum number of TOTP and recovery code attempts. Please wait a while before trying again.",
          ),
          handleConfirm: {
            text: "OK",
            onClick: {_ => handleConfirmAction(expiredType)},
          },
          showCloseIcon: false,
        })
      }
    }

    React.null
  }
}

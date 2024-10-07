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
          <p className={`${p2Regular} text-jp-gray-700`}>
            {"Didn't get a code? "->React.string}
            <span
              className="cursor-pointer underline underline-offset-2 text-blue-600"
              onClick={_ => handleOnClick(~stateToSet=Totp)}>
              {"Use totp instead"->React.string}
            </span>
          </p>
        </>
      }}
      <RenderIf condition={errorMessage->LogicUtils.isNonEmptyString}>
        <div className="text-sm text-red-600"> {`Error: ${errorMessage}`->React.string} </div>
      </RenderIf>
    </div>
  }
}

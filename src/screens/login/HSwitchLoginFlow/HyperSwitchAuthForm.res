open HyperSwitchAuthUtils
let fieldWrapperClass = "w-full flex flex-col"
let labelClass = "!text-black !font-medium"
module EmailPasswordForm = {
  @react.component
  let make = (~setAuthType) => {
    let {email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    <div className="flex flex-col gap-3">
      <FormRenderer.FieldRenderer field=emailField labelClass fieldWrapperClass />
      <div className="flex flex-col gap-3">
        <FormRenderer.FieldRenderer field=passwordField labelClass fieldWrapperClass />
        <UIUtils.RenderIf condition={email}>
          <AddDataAttributes attributes=[("data-testid", "forgot-password")]>
            <label
              className={`not-italic text-[12px] font-semibold font-ibm-plex text-blue-500 cursor-pointer`}
              onClick={_ => setAuthType(_ => HyperSwitchAuthTypes.ForgetPassword)}>
              {"Forgot Password?"->React.string}
            </label>
          </AddDataAttributes>
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}

module EmailForm = {
  @react.component
  let make = () => {
    <FormRenderer.FieldRenderer field=emailField labelClass fieldWrapperClass />
  }
}

module ResetPasswordForm = {
  @react.component
  let make = () => {
    <>
      <FormRenderer.FieldRenderer field=createPasswordField labelClass fieldWrapperClass />
      <FormRenderer.FieldRenderer field=confirmPasswordField labelClass fieldWrapperClass />
    </>
  }
}

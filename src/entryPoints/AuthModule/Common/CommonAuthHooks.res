let useNote = (authType, setAuthType, isMagicLinkEnabled) => {
  open CommonAuthTypes
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id", ())
  let getFooterLinkComponent = (~btnText, ~authType, ~path) => {
    <div
      onClick={_ => {
        setAuthType(_ => authType)
        GlobalVars.appendDashboardPath(~url=path)->RescriptReactRouter.push
      }}
      className={`text-sm text-center ${textColor.primaryNormal} cursor-pointer hover:underline underline-offset-2`}>
      {btnText->React.string}
    </div>
  }

  <div className="w-96">
    {switch authType {
    | LoginWithEmail =>
      getFooterLinkComponent(
        ~btnText="or sign in using password",
        ~authType=LoginWithPassword,
        ~path=`/login?auth_id${authId}`,
      )
    | LoginWithPassword =>
      <RenderIf condition={isMagicLinkEnabled}>
        {getFooterLinkComponent(
          ~btnText="or sign in with an email",
          ~authType=LoginWithEmail,
          ~path=`/login?auth_id${authId}`,
        )}
      </RenderIf>
    | SignUP =>
      <RenderIf condition={isMagicLinkEnabled}>
        <p className="text-center text-sm">
          {"We'll be emailing you a magic link for a password-free experience, you can always choose to setup a password later."->React.string}
        </p>
      </RenderIf>
    | ForgetPassword | MagicLinkEmailSent | ForgetPasswordEmailSent | ResendVerifyEmailSent =>
      <div className="w-full flex justify-center">
        <div
          onClick={_ => {
            let backState = switch authType {
            | MagicLinkEmailSent => SignUP
            | ForgetPasswordEmailSent => ForgetPassword
            | ResendVerifyEmailSent => ResendVerifyEmail
            | ForgetPassword | _ => LoginWithPassword
            }
            setAuthType(_ => backState)
          }}
          className={`text-sm text-center ${textColor.primaryNormal} hover:underline underline-offset-2 cursor-pointer w-fit`}>
          {"Cancel"->React.string}
        </div>
      </div>
    | _ => React.null
    }}
  </div>
}

let defaultAuthInfo: CommonAuthTypes.commonAuthInfo = {
  token: None,
  merchantId: "",
  name: "",
  email: "",
  userRole: "",
}

let useCommonAuthInfo = () => {
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let {merchantId, roleId, name, email} = React.useContext(UserInfoProvider.defaultContext)
  let authInfo: option<CommonAuthTypes.commonAuthInfo> = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | BasicAuth({token, merchant_id, name, email, user_role}) =>
      Some({
        token: token->Option.getOr("")->LogicUtils.getNonEmptyString,
        merchantId: merchant_id->Option.getOr(""),
        name: name->Option.getOr(""),
        email: email->Option.getOr(""),
        userRole: user_role->Option.getOr(""),
      })
    | Auth({token}) =>
      Some({
        token,
        merchantId,
        name,
        email,
        userRole: roleId,
      })
    }
  | _ => None
  }
  authInfo
}

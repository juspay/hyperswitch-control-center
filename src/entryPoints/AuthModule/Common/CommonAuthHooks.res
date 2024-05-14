let useNote = (authType, setAuthType, isMagicLinkEnabled) => {
  open UIUtils
  open CommonAuthTypes
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
  let getFooterLinkComponent = (~btnText, ~authType, ~path) => {
    <div
      onClick={_ => {
        setAuthType(_ => authType)
        HSwitchGlobalVars.appendDashboardPath(~url=path)->RescriptReactRouter.push
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
        ~path="/login",
      )
    | LoginWithPassword =>
      <RenderIf condition={isMagicLinkEnabled}>
        {getFooterLinkComponent(
          ~btnText="or sign in with an email",
          ~authType=LoginWithEmail,
          ~path="/login",
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
  token: "",
  merchantId: "",
  username: "",
  email: "",
  userRole: "",
}

let useCommonAuthInfo = () => {
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let authInfo: option<CommonAuthTypes.commonAuthInfo> = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | BasicAuth({token, merchantId, username, email, userRole}) =>
      Some({
        token: token->Option.getOr(""),
        merchantId: merchantId->Option.getOr(""),
        username: username->Option.getOr(""),
        email: email->Option.getOr(""),
        userRole: userRole->Option.getOr(""),
      })
    | ToptAuth({token, merchantId, username, email, userRole}) =>
      Some({
        token: token->Option.getOr(""),
        merchantId: merchantId->Option.getOr(""),
        username: username->Option.getOr(""),
        email: email->Option.getOr(""),
        userRole: userRole->Option.getOr(""),
      })
    }
  | _ => {
      setAuthStatus(LoggedOut)
      None
    }
  }
  authInfo
}

module TermsAndCondition = {
  @react.component
  let make = () => {
    <div id="tc-text" className="text-center text-sm text-gray-300">
      {"By continuing, you agree to our "->React.string}
      <a
        className="underline cursor-pointer"
        href="https://hyperswitch.io/terms-of-services"
        target="__blank">
        {"Terms of Service"->React.string}
      </a>
      {" & "->React.string}
      <a
        className="underline cursor-pointer"
        href="https://hyperswitch.io/privacyPolicy"
        target="__blank">
        {"Privacy Policy"->React.string}
      </a>
    </div>
  }
}

module PageFooterSection = {
  @react.component
  let make = () => {
    <div
      className="justify-center text-base flex flex-col md:flex-row md:gap-3 items-center py-5 md:py-7">
      <div id="footer" className="flex items-center gap-2">
        {"An open-source initiative by "->React.string}
        <a href="https://juspay.in/" target="__blank">
          <img src={`/icons/juspay-logo-dark.svg`} className="h-3" />
        </a>
      </div>
    </div>
  }
}

module Header = {
  @react.component
  let make = (~authType, ~setAuthType, ~email) => {
    open CommonAuthTypes
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let {isSignUpAllowed} = AuthModuleHooks.useAuthMethods()
    let form = ReactFinalForm.useForm()
    let {email: isMagicLinkEnabled} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id", ())

    let headerStyle = switch authType {
    | MagicLinkEmailSent
    | ForgetPasswordEmailSent
    | ForgetPassword
    | ResendVerifyEmailSent => "flex flex-col justify-center items-center"
    | _ => "flex flex-col"
    }

    let cardHeaderText = switch authType {
    | LoginWithPassword | LoginWithEmail => "Hey there, Welcome back!"
    | SignUP => "Welcome to Hyperswitch"
    | MagicLinkEmailSent
    | ForgetPasswordEmailSent
    | ResendVerifyEmailSent => "Please check your inbox"
    | ResetPassword => "Reset Password"
    | ForgetPassword => "Forgot Password?"
    | ResendVerifyEmail => "Resend Verify Email"
    | _ => ""
    }

    let getNoteUI = info => {
      <div className="flex-col items-center justify-center">
        <div> {info->React.string} </div>
        <div className="w-full flex justify-center text-center font-bold">
          {email->React.string}
        </div>
      </div>
    }

    let getHeaderLink = (~prefix, ~authType, ~path, ~sufix) => {
      <div className="flex text-sm items-center gap-2">
        <div className="text-grey-650"> {prefix->React.string} </div>
        <div
          onClick={_ => {
            form.resetFieldState("email")
            form.reset(JSON.Encode.object(Dict.make())->Nullable.make)
            setAuthType(_ => authType)
            HSwitchGlobalVars.appendDashboardPath(~url=path)->RescriptReactRouter.push
          }}
          id="card-subtitle"
          className={`font-semibold ${textColor.primaryNormal} cursor-pointer`}>
          {sufix->React.string}
        </div>
      </div>
    }

    let showInfoIcon = switch authType {
    | MagicLinkEmailSent
    | ForgetPassword
    | ForgetPasswordEmailSent
    | ResendVerifyEmailSent
    | ResendVerifyEmail => true
    | _ => false
    }
    let (signUpAllowed, _) = isSignUpAllowed()
    <div className={`${headerStyle} gap-2 h-fit mb-7 w-96`}>
      <UIUtils.RenderIf condition={showInfoIcon}>
        <div className="flex justify-center my-5">
          {switch authType {
          | MagicLinkEmailSent | ForgetPasswordEmailSent | ResendVerifyEmailSent =>
            <img className="w-48" src={`/assets/mail.svg`} />
          | ForgetPassword => <img className="w-24" src={`/assets/key-password.svg`} />
          | _ => React.null
          }}
        </div>
      </UIUtils.RenderIf>
      <h1 id="card-header" className="font-semibold text-xl md:text-2xl">
        {cardHeaderText->React.string}
      </h1>
      {switch authType {
      | LoginWithPassword | LoginWithEmail =>
        <UIUtils.RenderIf condition={signUpAllowed}>
          {getHeaderLink(
            ~prefix="New to Hyperswitch?",
            ~authType=SignUP,
            ~path="/register",
            ~sufix="Sign up",
          )}
        </UIUtils.RenderIf>

      | SignUP =>
        getHeaderLink(
          ~prefix="Already using Hyperswitch?",
          ~authType=isMagicLinkEnabled ? LoginWithEmail : LoginWithPassword,
          ~path=`/login?auth_id=${authId}`,
          ~sufix="Sign in",
        )
      | ForgetPassword =>
        <div className="text-md text-center text-grey-650 w-full max-w-md">
          {"Enter your email address associated with your account, and we'll send you a link to reset your password."->React.string}
        </div>
      | MagicLinkEmailSent => "A magic link has been sent to "->getNoteUI
      | ForgetPasswordEmailSent => "A reset password link has been sent to "->getNoteUI
      | ResendVerifyEmailSent => "A verify email link has been sent to "->getNoteUI
      | _ => React.null
      }}
    </div>
  }
}

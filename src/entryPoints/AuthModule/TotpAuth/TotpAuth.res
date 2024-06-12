@react.component
let make = (~setAuthStatus, ~authType, ~setAuthType) => {
  open APIUtils
  open CommonAuthForm
  open HSwitchGlobalVars
  open LogicUtils
  open TotpUtils
  open AuthProviderTypes
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let initialValues = Dict.make()->JSON.Encode.object
  let clientCountry = HSwitchUtils.getBrowswerDetails().clientCountry
  let country = clientCountry.isoAlpha2->CountryUtils.getCountryCodeStringFromVarient
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (email, setEmail) = React.useState(_ => "")
  let featureFlagValues = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let handleAuthError = e => {
    open CommonAuthUtils
    let error = e->parseErrorMessage
    switch error.code->errorSubCodeMapper {
    | UR_03 => "An account already exists with this email"
    | UR_05 => {
        setAuthType(_ => CommonAuthTypes.ResendVerifyEmail)
        "Kindly verify your account"
      }
    | UR_16 => "Please use a valid email"
    | UR_01 => "Incorrect email or password"
    | _ => "Register failed, Try again"
    }
  }

  let getUserWithEmail = async body => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#CONNECT_ACCOUNT, ~methodType=Post, ())
      let res = await updateDetails(url, body, Post, ())
      let valuesDict = res->getDictFromJsonObject
      let magicLinkSent = valuesDict->LogicUtils.getBool("is_email_sent", false)

      if magicLinkSent {
        setAuthType(_ => MagicLinkEmailSent)
      } else {
        showToast(~message="Failed to send an email, Try again", ~toastType=ToastError, ())
      }
    } catch {
    | Exn.Error(e) => showToast(~message={e->handleAuthError}, ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let getUserWithEmailPassword = async (body, userType) => {
    try {
      let url = getURL(~entityName=USERS, ~userType, ~methodType=Post, ())
      let res = await updateDetails(url, body, Post, ())
      setAuthStatus(PreLogin(getPreLoginInfo(res)))
    } catch {
    | Exn.Error(e) => showToast(~message={e->handleAuthError}, ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let openPlayground = _ => {
    open CommonAuthUtils
    let body = getEmailPasswordBody(playgroundUserEmail, playgroundUserPassword, country)
    getUserWithEmailPassword(body, #SIGNINV2)->ignore
    HSLocalStorage.setIsPlaygroundInLocalStorage(true)
  }

  let setResetPassword = async body => {
    try {
      // Need to check this
      let url = getURL(~entityName=USERS, ~userType=#RESET_PASSWORD, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post, ())
      LocalStorage.clear()
      showToast(~message=`Password Changed Successfully`, ~toastType=ToastSuccess, ())
      setAuthType(_ => LoginWithEmail)
    } catch {
    | _ => showToast(~message="Password Reset Failed, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let setForgetPassword = async body => {
    try {
      // Need to check this
      let url = getURL(~entityName=USERS, ~userType=#FORGOT_PASSWORD, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post, ())
      setAuthType(_ => ForgetPasswordEmailSent)
      showToast(~message="Please check your registered e-mail", ~toastType=ToastSuccess, ())
    } catch {
    | _ => showToast(~message="Forgot Password Failed, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let resendVerifyEmail = async body => {
    try {
      // Need to check this
      let url = getURL(~entityName=USERS, ~userType=#VERIFY_EMAIL_REQUEST, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post, ())
      setAuthType(_ => ResendVerifyEmailSent)
      showToast(~message="Please check your registered e-mail", ~toastType=ToastSuccess, ())
    } catch {
    | _ => showToast(~message="Resend mail failed, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let logMixpanelEvents = email => {
    open CommonAuthTypes
    switch authType {
    | LoginWithPassword => mixpanelEvent(~eventName=`signin_using_email&password`, ~email, ())
    | LoginWithEmail => mixpanelEvent(~eventName=`signin_using_magic_link`, ~email, ())
    | SignUP => mixpanelEvent(~eventName=`signup_using_magic_link`, ~email, ())
    | _ => ()
    }
  }

  let onSubmit = async (values, _) => {
    try {
      open CommonAuthUtils
      let valuesDict = values->getDictFromJsonObject
      let email = valuesDict->getString("email", "")
      setEmail(_ => email)
      logMixpanelEvents(email)

      let _ = await (
        switch (featureFlagValues.email, authType) {
        | (true, SignUP) | (true, LoginWithEmail) => {
            let body = getEmailBody(email, ~country, ())
            getUserWithEmail(body)
          }

        | (true, ResendVerifyEmail) =>
          let body = email->getEmailBody()
          resendVerifyEmail(body)

        | (false, SignUP) => {
            let password = getString(valuesDict, "password", "")
            let body = getEmailPasswordBody(email, password, country)
            getUserWithEmailPassword(body, #SIGNUP_TOKEN_ONLY)
          }
        | (_, LoginWithPassword) => {
            let password = getString(valuesDict, "password", "")
            let body = getEmailPasswordBody(email, password, country)
            getUserWithEmailPassword(body, #SIGNINV2_TOKEN_ONLY)
          }
        | (_, ResetPassword) => {
            let queryDict = url.search->getDictFromUrlSearchParams
            let password_reset_token = queryDict->Dict.get("token")->Option.getOr("")
            let password = getString(valuesDict, "create_password", "")
            let body = getResetpasswordBodyJson(password, password_reset_token)
            setResetPassword(body)
          }
        | _ =>
          switch (featureFlagValues.email, authType) {
          | (true, ForgetPassword) =>
            let body = email->getEmailBody()

            setForgetPassword(body)
          | _ => Promise.make((resolve, _) => resolve(. Nullable.null))
          }
        }
      )
    } catch {
    | _ => showToast(~message="Something went wrong, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let resendEmail = () => {
    open CommonAuthUtils
    let body = email->getEmailBody()
    switch authType {
    | MagicLinkEmailSent => getUserWithEmail(body)->ignore
    | ForgetPasswordEmailSent => setForgetPassword(body)->ignore
    | ResendVerifyEmailSent => resendVerifyEmail(body)->ignore
    | _ => ()
    }
  }

  let submitBtnText = switch authType {
  | LoginWithPassword | LoginWithEmail => "Continue"
  | ResetPassword => "Confirm"
  | ForgetPassword => "Reset password"
  | ResendVerifyEmail => "Send mail"
  | _ => "Get started, for free!"
  }

  let validateKeys = switch authType {
  | ForgetPassword
  | ResendVerifyEmail
  | SignUP
  | LoginWithEmail => ["email"]
  | LoginWithPassword => ["email", "password"]
  | ResetPassword => ["create_password", "comfirm_password"]
  | _ => []
  }

  React.useEffect0(() => {
    if url.hash === "playground" {
      openPlayground()
    }
    None
  })
  let note = CommonAuthHooks.useNote(authType, setAuthType, featureFlagValues.email)
  <ReactFinalForm.Form
    key="auth"
    initialValues
    subscription=ReactFinalForm.subscribeToValues
    validate={values => validateTotpForm(values, validateKeys)}
    onSubmit
    render={({handleSubmit}) => {
      <>
        <CommonAuth.Header authType setAuthType email />
        <form
          onSubmit={handleSubmit}
          className={`flex flex-col justify-evenly gap-5 h-full w-full !overflow-visible text-grey-600`}>
          {switch authType {
          | LoginWithPassword => <EmailPasswordForm setAuthType />
          | ForgetPassword =>
            <UIUtils.RenderIf condition={featureFlagValues.email}>
              <EmailForm />
            </UIUtils.RenderIf>
          | LoginWithEmail
          | ResendVerifyEmail
          | SignUP =>
            featureFlagValues.email ? <EmailForm /> : <EmailPasswordForm setAuthType />
          | ResetPassword => <ResetPasswordForm />
          | MagicLinkEmailSent | ForgetPasswordEmailSent | ResendVerifyEmailSent =>
            <ResendBtn callBackFun={resendEmail} />
          | _ => React.null
          }}
          <div id="auth-submit-btn" className="flex flex-col gap-2">
            {switch authType {
            | LoginWithPassword
            | LoginWithEmail
            | ResetPassword
            | ForgetPassword
            | ResendVerifyEmail
            | SignUP =>
              <FormRenderer.SubmitButton
                customSumbitButtonStyle="!w-full !rounded"
                text=submitBtnText
                userInteractionRequired=true
                showToolTip=false
                loadingText="Loading..."
              />
            | _ => React.null
            }}
          </div>
          <AddDataAttributes attributes=[("data-testid", "card-foot-text")]>
            <div> {note} </div>
          </AddDataAttributes>
        </form>
      </>
    }}
  />
}

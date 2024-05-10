@react.component
let make = (~flowType) => {
  open APIUtils
  open LogicUtils
  open FramerMotion.Motion
  open CommonAuthTypes
  open CommonAuthUtils
  open CommonAuthForm
  open BasicAuthUtils

  let url = RescriptReactRouter.useUrl()
  let initialValues = Dict.make()->JSON.Encode.object
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let setResetPassword = async body => {
    try {
      // TODO : replace with the actual route for reset password
      // and also write the logic for force_set_password & reset_password
      let url = getURL(
        ~entityName=USERS,
        ~userType=#RESET_PASSWORD_TOKEN_ONLY,
        ~methodType=Post,
        (),
      )
      Js.log2("bodybodybody", body)
      let _ = await updateDetails(url, body, Post, ())
      setAuthStatus(LoggedOut)
      LocalStorage.clear()
      showToast(~message=`Password Changed Successfully`, ~toastType=ToastSuccess, ())
      RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url=`/login`))
    } catch {
    | _ => showToast(~message="Password Reset Failed, Try again", ~toastType=ToastError, ())
    }
  }

  let rotatePassword = async password => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#ROTATE_PASSWORD, ~methodType=Post, ())

      let body = [("password", password->JSON.Encode.string)]->getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post, ())
      setAuthStatus(LoggedOut)
      LocalStorage.clear()
      showToast(~message=`Password Changed Successfully`, ~toastType=ToastSuccess, ())
      RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url=`/login`))
    } catch {
    | _ => showToast(~message="Password Reset Failed, Try again", ~toastType=ToastError, ())
    }
  }

  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (logoVariant, iconUrl) = switch (Window.env.logoUrl, branding) {
  | (Some(url), true) => (IconWithURL, Some(url))
  | (Some(url), false) => (IconWithURL, Some(url))
  | _ => (IconWithText, None)
  }

  let confirmButtonAction = (password, password_reset_token) => {
    open TotpTypes
    switch flowType {
    | FORCE_SET_PASSWORD => rotatePassword(password)
    | _ => {
        let body = getResetpasswordBodyJson(password, password_reset_token)
        setResetPassword(body)
      }
    }
  }

  let onSubmit = async (values, _) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let queryDict = url.search->getDictFromUrlSearchParams
      let password_reset_token = queryDict->Dict.get("token")->Option.getOr("")
      let password = getString(valuesDict, "create_password", "")
      confirmButtonAction(password, password_reset_token)->ignore
    } catch {
    | _ => showToast(~message="Something went wrong, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let headerText = switch flowType {
  | FORCE_SET_PASSWORD => "Change password"
  | _ => "Reset password"
  }

  <HSwitchUtils.BackgroundImageWrapper
    customPageCss="flex flex-col items-center justify-center overflow-scroll ">
    <div
      className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
      <div className="flex flex-col items-center justify-center gap-6 flex-1 mt-4 w-30-rem">
        <Div layoutId="form" className="bg-white w-full text-black mobile:border rounded-lg">
          <div className="px-7 py-6">
            <Div layoutId="logo">
              <HyperSwitchLogo logoHeight="h-8" theme={Dark} logoVariant iconUrl />
            </Div>
          </div>
          <Div layoutId="border" className="border-b w-full" />
          <div className="p-7">
            <ReactFinalForm.Form
              key="auth"
              initialValues
              subscription=ReactFinalForm.subscribeToValues
              validate={values => validateForm(values, ["create_password", "comfirm_password"])}
              onSubmit
              render={({handleSubmit}) => {
                <div className="flex flex-col gap-6">
                  <h1 id="card-header" className="font-semibold text-xl md:text-2xl">
                    {headerText->React.string}
                  </h1>
                  <form
                    onSubmit={handleSubmit}
                    className={`flex flex-col justify-evenly gap-5 h-full w-full !overflow-visible text-grey-600`}>
                    <ResetPasswordForm />
                    <div id="auth-submit-btn" className="flex flex-col gap-2">
                      <FormRenderer.SubmitButton
                        customSumbitButtonStyle="!w-full !rounded"
                        text="Confirm"
                        userInteractionRequired=true
                        showToolTip=false
                        loadingText="Loading..."
                      />
                    </div>
                  </form>
                </div>
              }}
            />
          </div>
        </Div>
      </div>
    </div>
  </HSwitchUtils.BackgroundImageWrapper>
}

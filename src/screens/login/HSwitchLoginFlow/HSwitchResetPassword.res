@react.component
let make = () => {
  open HyperSwitchAuthUtils
  open APIUtils
  open HyperSwitchAuthForm
  open LogicUtils
  open FramerMotion.Motion
  open HyperSwitchAuthTypes

  let url = RescriptReactRouter.useUrl()
  let initialValues = Dict.make()->JSON.Encode.object
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (email, setEmail) = React.useState(_ => "")
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let setResetPassword = async body => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#RESET_PASSWORD, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post, ())
      setAuthStatus(LoggedOut)
      LocalStorage.clear()
      showToast(~message=`Password Changed Successfully`, ~toastType=ToastSuccess, ())
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
  let onSubmit = async (values, _) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let email = valuesDict->getString("email", "")
      setEmail(_ => email)

      let queryDict = url.search->getDictFromUrlSearchParams
      let password_reset_token = queryDict->Dict.get("token")->Option.getOr("")
      let password = getString(valuesDict, "create_password", "")
      let body = getResetpasswordBodyJson(password, password_reset_token)
      let _ = setResetPassword(body)
    } catch {
    | _ => showToast(~message="Something went wrong, Try again", ~toastType=ToastError, ())
    }
    Nullable.null
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
                    {"Reset Password"->React.string}
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

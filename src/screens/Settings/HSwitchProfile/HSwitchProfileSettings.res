let titleClass = "text-hyperswitch_black text-base w-1/5"
let subTitleClass = "text-hyperswitch_black opacity-50 text-base font-semibold break-all"
let sectionHeadingClass = "font-semibold text-fs-18"
let p1Leading1TextClass = HSwitchUtils.getTextClass((P1, Regular))
let p3RegularTextClass = `${HSwitchUtils.getTextClass((P3, Regular))} text-gray-700 opacity-50`

module ChangePasswordModal = {
  @react.component
  let make = (~setShowModal) => {
    open APIUtils
    open LogicUtils
    open CommonAuthUtils
    let getURL = useGetURL()
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let handleLogout = useHandleLogout()
    let onSubmit = async (values, _) => {
      let valuesDict = values->getDictFromJsonObject
      let oldPassword = getString(valuesDict, "old_password", "")
      let newPassword = getString(valuesDict, "new_password", "")
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#CHANGE_PASSWORD, ~methodType=Post)
        let body =
          [
            ("old_password", oldPassword->JSON.Encode.string),
            ("new_password", newPassword->JSON.Encode.string),
          ]->getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Post)
        showToast(~message="Password Changed Successfully", ~toastType=ToastSuccess)
        let _ = handleLogout()->ignore
        setShowModal(_ => false)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Something went wrong")
          let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
          let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
          setShowModal(_ => false)
          if errorCode->errorSubCodeMapper === UR_06 {
            showToast(~message=errorMessage, ~toastType=ToastError)
          } else {
            showToast(~message="Password Change Failed, Try again", ~toastType=ToastError)
          }
        }
      }
      Nullable.null
    }

    <Modal
      modalHeading="Change Password"
      setShowModal
      showModal=true
      closeOnOutsideClick=true
      modalClass="w-full md:w-4/12 mx-auto my-auto">
      <Form
        key="auth"
        validate={values =>
          TwoFaUtils.validateTotpForm(values, ["old_password", "new_password", "confirm_password"])}
        onSubmit>
        <div className="flex flex-col gap-6 m-2">
          <div
            className="flex flex-col justify-evenly gap-5 h-full w-full !overflow-visible text-grey-600">
            <CommonAuthForm.ChangePasswordForm />
            <div id="auth-submit-btn" className="flex flex-col gap-2">
              <FormRenderer.SubmitButton
                customSumbitButtonStyle="!w-full"
                text="Confirm"
                userInteractionRequired=true
                showToolTip=false
                loadingText="Loading..."
              />
            </div>
          </div>
        </div>
      </Form>
    </Modal>
  }
}

module ChangePassword = {
  @react.component
  let make = () => {
    let (showModal, setShowModal) = React.useState(_ => false)
    <div className="flex gap-10 items-center">
      <p className="text-hyperswitch_black text-base  w-1/5"> {"Password:"->React.string} </p>
      <div className="flex flex-col gap-5 items-start md:flex-row md:items-center flex-wrap">
        <p className="text-hyperswitch_black opacity-50 text-base font-semibold break-all">
          {"********"->React.string}
        </p>
        <Button
          text={"Change Password"}
          buttonType=Secondary
          buttonSize={Small}
          onClick={_ => setShowModal(_ => true)}
        />
        {showModal ? <ChangePasswordModal setShowModal /> : React.null}
      </div>
    </div>
  }
}

module ResetPassword = {
  @react.component
  let make = () => {
    open APIUtils
    open CommonAuthHooks
    let getURL = useGetURL()
    let (isLoading, setIsLoading) = React.useState(_ => false)
    let {email} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
    let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id")
    let themeId = HyperSwitchEntryUtils.getThemeIdfromStore()->Option.getOr("")
    let domain = HSLocalStorage.getDomainfromStore()->Option.getOr("")
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let showToast = ToastState.useShowToast()

    let resetPassword = async body => {
      setIsLoading(_ => true)
      try {
        let url = getURL(
          ~entityName=V1(USERS),
          ~userType=#FORGOT_PASSWORD,
          ~methodType=Post,
          ~queryParameters=Some(`auth_id=${authId}&domain=${domain}&theme_id=${themeId}`),
        )
        let _ = await updateDetails(url, body, Post)
        showToast(~message="Please check your registered e-mail", ~toastType=ToastSuccess)
        setIsLoading(_ => false)
      } catch {
      | _ => {
          showToast(~message="Reset Password Failed, Try again", ~toastType=ToastError)
          setIsLoading(_ => false)
        }
      }
    }

    let setPassword = () => {
      let body = email->CommonAuthUtils.getEmailBody
      body->resetPassword->ignore
    }

    <div className="flex gap-10 items-center">
      <p className="text-hyperswitch_black text-base  w-1/5"> {"Password:"->React.string} </p>
      <div className="flex flex-col gap-5 items-start md:flex-row md:items-center flex-wrap">
        <p className="text-hyperswitch_black opacity-50 text-base font-semibold break-all">
          {"********"->React.string}
        </p>
        <RenderIf condition={!isPlayground}>
          <Button
            text={"Reset Password"}
            loadingText="Sending mail..."
            buttonState={isLoading ? Loading : Normal}
            buttonType=Secondary
            buttonSize={Small}
            onClick={_ => setPassword()}
          />
        </RenderIf>
      </div>
    </div>
  }
}

module TwoFactorAuthenticationDetails = {
  @react.component
  let make = () => {
    <div>
      <div className="border bg-gray-50 rounded-t-lg w-full px-10 py-6">
        <p className=sectionHeadingClass> {"Two factor authentication"->React.string} </p>
      </div>
      <div
        className="flex flex-col gap-5 bg-white border border-t-0 rounded-b-lg w-full px-10 pt-6 pb-10">
        <div className="flex gap-10 items-center justify-between">
          <p className={`${p1Leading1TextClass} flex flex-col gap-1`}>
            {"Change app / device"->React.string}
            <span className=p3RegularTextClass>
              {"Reset TOTP to regain access if you've changed or lost your device."->React.string}
            </span>
          </p>
          <Button
            text="Edit"
            buttonSize=Small
            onClick={_ => {
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(
                  ~url=`/account-settings/profile/2fa?type=reset_totp`,
                ),
              )
            }}
          />
        </div>
        <hr />
        <div className="flex gap-10 items-center justify-between">
          <p className={`${p1Leading1TextClass} flex flex-col gap-1`}>
            {"Regenerate recovery codes"->React.string}
            <span className=p3RegularTextClass>
              {"Regenerate your access code to ensure continued access and security for your account."->React.string}
            </span>
          </p>
          <Button
            text="Edit"
            buttonSize=Small
            onClick={_ => {
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(
                  ~url=`/account-settings/profile/2fa?type=regenerate_recovery_code`,
                ),
              )
            }}
          />
        </div>
      </div>
    </div>
  }
}

module BasicDetailsSection = {
  @react.component
  let make = () => {
    open CommonAuthHooks
    let {name: userName, email} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let userTitle = LogicUtils.userNameToTitle(userName)

    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    <div>
      <div className="border bg-gray-50 rounded-t-lg w-full px-10 py-6">
        <p className=sectionHeadingClass> {"User Info"->React.string} </p>
      </div>
      <div
        className="flex flex-col gap-5 bg-white border border-t-0 rounded-b-lg w-full px-10 pt-6 pb-10">
        <div className="flex gap-10 items-center">
          <p className=titleClass> {"Name:"->React.string} </p>
          <p className=subTitleClass>
            {(userName->LogicUtils.isNonEmptyString ? userTitle : "--")->React.string}
          </p>
        </div>
        <hr />
        <div className="flex gap-10 items-center">
          <p className=titleClass> {"Email:"->React.string} </p>
          <p className=subTitleClass> {email->React.string} </p>
        </div>
        <hr />
        <RenderIf condition={featureFlagDetails.email}>
          <ResetPassword />
        </RenderIf>
        <RenderIf condition={!featureFlagDetails.email}>
          <ChangePassword />
        </RenderIf>
      </div>
    </div>
  }
}
@react.component
let make = () => {
  let {isTwoFactorAuthSetup} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getResolvedUserInfo()

  <div className="flex flex-col overflow-scroll gap-8">
    <PageUtils.PageHeading title="Profile" subTitle="Manage your profile settings here" />
    <div className="flex flex-col flex-wrap  gap-12">
      <BasicDetailsSection />
      <RenderIf condition={isTwoFactorAuthSetup}>
        <TwoFactorAuthenticationDetails />
      </RenderIf>
    </div>
  </div>
}

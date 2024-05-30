let titleClass = "text-hyperswitch_black text-base w-1/5"
let subTitleClass = "text-hyperswitch_black opacity-50 text-base font-semibold break-all"
let sectionHeadingClass = "font-semibold text-fs-18"
let p1Leading1TextClass = HSwitchUtils.getTextClass((P1, Regular))
let p3RegularTextClass = `${HSwitchUtils.getTextClass((P3, Regular))} text-gray-700 opacity-50`

module MerchantDetailsSection = {
  @react.component
  let make = () => {
    open HSwitchProfileSettingsEntity
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (offset, setOffset) = React.useState(_ => 0)

    let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()
    let switchMerchantListValue = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.switchMerchantListAtom,
    )

    React.useEffect0(() => {
      try {
        let _ = fetchSwitchMerchantList()
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Custom)
      }
      None
    })

    <PageLoaderWrapper screenState sectionHeight="h-40-vh">
      <div>
        <div className="border bg-gray-50 rounded-t-lg border-b-0 w-full px-10 py-6">
          <p className=sectionHeadingClass> {"Merchant Info"->React.string} </p>
        </div>
        <LoadedTable
          title="Merchant Info"
          hideTitle=true
          resultsPerPage=7
          visibleColumns
          entity={merchantTableEntity}
          actualData={switchMerchantListValue->Array.map(Nullable.make)}
          totalResults={switchMerchantListValue->Array.length}
          offset
          setOffset
          currrentFetchCount={switchMerchantListValue->Array.length}
        />
      </div>
    </PageLoaderWrapper>
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

    let updateDetails = useUpdateMethod(~showErrorToast=false, ())
    let showToast = ToastState.useShowToast()

    let resetPassword = async body => {
      setIsLoading(_ => true)
      try {
        let url = getURL(~entityName=USERS, ~userType=#FORGOT_PASSWORD, ~methodType=Post, ())
        let _ = await updateDetails(url, body, Post, ())
        showToast(~message="Please check your registered e-mail", ~toastType=ToastSuccess, ())
        setIsLoading(_ => false)
      } catch {
      | _ => {
          showToast(~message="Reset Password Failed, Try again", ~toastType=ToastError, ())
          setIsLoading(_ => false)
        }
      }
    }

    let setPassword = () => {
      let body = email->CommonAuthUtils.getEmailBody()
      body->resetPassword->ignore
    }

    <div className="flex gap-10 items-center">
      <p className="text-hyperswitch_black text-base  w-1/5"> {"Password:"->React.string} </p>
      <div className="flex flex-col gap-5 items-start md:flex-row md:items-center flex-wrap">
        <p className="text-hyperswitch_black opacity-50 text-base font-semibold break-all">
          {"********"->React.string}
        </p>
        <UIUtils.RenderIf condition={!isPlayground}>
          <Button
            text={"Reset Password"}
            loadingText="Sending mail..."
            buttonState={isLoading ? Loading : Normal}
            buttonType=Secondary
            buttonSize={Small}
            onClick={_ => setPassword()}
          />
        </UIUtils.RenderIf>
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
            buttonSize={XSmall}
            onClick={_ => {
              RescriptReactRouter.push(
                HSwitchGlobalVars.appendDashboardPath(
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
            buttonSize={XSmall}
            onClick={_ => {
              RescriptReactRouter.push(
                HSwitchGlobalVars.appendDashboardPath(
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

    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

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
        <UIUtils.RenderIf condition={!isPlayground && featureFlagDetails.email}>
          <ResetPassword />
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}
@react.component
let make = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  <div className="flex flex-col overflow-scroll gap-8">
    <PageUtils.PageHeading title="Profile" subTitle="Manage your profile settings here" />
    <div className="flex flex-col flex-wrap  gap-12">
      <BasicDetailsSection />
      <MerchantDetailsSection />
      <UIUtils.RenderIf condition={featureFlagDetails.totp}>
        <TwoFactorAuthenticationDetails />
      </UIUtils.RenderIf>
    </div>
  </div>
}

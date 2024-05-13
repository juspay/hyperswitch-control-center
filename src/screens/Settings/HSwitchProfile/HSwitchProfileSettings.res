module MerchantDetailsSection = {
  @react.component
  let make = () => {
    open HSwitchProfileSettingsEntity
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (offset, setOffset) = React.useState(_ => 0)
    let sectionHeadingClass = "font-semibold text-fs-18"

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
    open HSLocalStorage
    open APIUtils
    let (isLoading, setIsLoading) = React.useState(_ => false)
    let email = getFromMerchantDetails("email")
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

module BasicDetailsSection = {
  @react.component
  let make = () => {
    open HSLocalStorage
    let titleClass = "text-hyperswitch_black text-base  w-1/5"
    let subTitleClass = "text-hyperswitch_black opacity-50 text-base font-semibold break-all"
    let sectionHeadingClass = "font-semibold text-fs-18"
    let userName = getFromUserDetails("name")
    let userTitle = LogicUtils.userNameToTitle(userName)

    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

    let getMerchantInfoValue = value => {
      let merchantDetails = getInfoFromLocalStorage(~lStorageKey="merchant")
      merchantDetails->LogicUtils.getString(value, "Not Added")
    }
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
          <p className=subTitleClass> {getMerchantInfoValue("email")->React.string} </p>
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
  <div className="flex flex-col overflow-scroll gap-8">
    <PageUtils.PageHeading title="Profile" subTitle="Manage your profile settings here" />
    <div className="flex flex-col flex-wrap  gap-12">
      <BasicDetailsSection />
      <MerchantDetailsSection />
    </div>
  </div>
}

module MerchantDetailsSection = {
  @react.component
  let make = () => {
    let fetchDetails = APIUtils.useGetMethod()
    let (merchantInfo, setMerchantInfo) = React.useState(_ => Dict.make())
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let titleClass = "text-hyperswitch_black text-base w-1/5"
    let subTitleClass = "text-hyperswitch_black opacity-50 text-base font-semibold "
    let sectionHeadingClass = "font-semibold text-fs-18"

    let getMerchantDetails = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountUrl = APIUtils.getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
        let merchantDetailsJSON = await fetchDetails(accountUrl)
        let merchantInfoDict = merchantDetailsJSON->LogicUtils.getDictFromJsonObject
        let requiredInfo =
          [
            (
              "merchant_id",
              merchantInfoDict->LogicUtils.getString("merchant_id", "")->Js.Json.string,
            ),
            (
              "merchant_name",
              merchantInfoDict->LogicUtils.getString("merchant_name", "")->Js.Json.string,
            ),
          ]->Dict.fromArray
        setMerchantInfo(_ => requiredInfo)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Js.Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }
    React.useEffect0(() => {
      getMerchantDetails()->ignore
      None
    })

    <PageLoaderWrapper screenState sectionHeight="h-40-vh">
      <div className="flex flex-col gap-10  bg-white border rounded w-full px-10 pt-6 pb-10">
        <p className=sectionHeadingClass> {"Merchant Info"->React.string} </p>
        <div className="flex gap-10 ">
          <p className=titleClass> {"Merchant Name"->React.string} </p>
          <p className=subTitleClass>
            {merchantInfo->LogicUtils.getString("merchant_name", "")->React.string}
          </p>
        </div>
        <div className="flex gap-10 ">
          <p className=titleClass> {"Merchant Id"->React.string} </p>
          <p className=subTitleClass>
            {merchantInfo->LogicUtils.getString("merchant_id", "")->React.string}
          </p>
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

module ResetPassword = {
  @react.component
  let make = () => {
    open HSLocalStorage
    open APIUtils
    open HyperSwitchAuthUtils
    let (isLoading, setIsLoading) = React.useState(_ => false)
    let email = getFromMerchantDetails("email")
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

    let updateDetails = useUpdateMethod(~showErrorToast=false, ())
    let showToast = ToastState.useShowToast()

    let resetPassword = async body => {
      setIsLoading(_ => true)
      try {
        let url = getURL(~entityName=USERS, ~userType=#FORGOT_PASSWORD, ~methodType=Post, ())
        let _ = await updateDetails(url, body, Post)
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
      let body = email->getEmailBody()
      body->resetPassword->ignore
    }

    <div className="flex gap-10 items-center">
      <p className="text-hyperswitch_black text-base  w-1/5"> {"Password"->React.string} </p>
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
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

    let getMerchantInfoValue = value => {
      let merchantDetails = getInfoFromLocalStorage(~lStorageKey="merchant")
      merchantDetails->LogicUtils.getString(value, "Not Added")
    }
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    <div className="flex flex-col gap-10 bg-white border rounded w-full px-10 pt-6 pb-10">
      <p className=sectionHeadingClass> {"User Info"->React.string} </p>
      <div className="flex gap-10 items-center">
        <p className=titleClass> {"Email"->React.string} </p>
        <p className=subTitleClass> {getMerchantInfoValue("email")->React.string} </p>
      </div>
      <div className="flex gap-10 items-center">
        <p className=titleClass> {"Name"->React.string} </p>
        <p className=subTitleClass>
          {(userName->String.length === 0 ? "--" : userName)->React.string}
        </p>
      </div>
      <UIUtils.RenderIf condition={!isPlayground && featureFlagDetails.magicLink}>
        <ResetPassword />
      </UIUtils.RenderIf>
    </div>
  }
}
@react.component
let make = () => {
  <div className="flex flex-col overflow-scroll gap-8">
    <PageUtils.PageHeading
      title="Profile" subTitle="View, customise and manage your personal profile and preferences."
    />
    <div className="flex flex-col flex-wrap  gap-12">
      <BasicDetailsSection />
      <MerchantDetailsSection />
    </div>
  </div>
}

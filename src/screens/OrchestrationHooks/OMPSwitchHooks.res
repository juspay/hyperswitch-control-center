type userInfo = {
  getUserInfo: unit => promise<UserInfoTypes.userInfo>,
  updateTransactionEntity: UserInfoTypes.entity => unit,
  updateAnalytcisEntity: UserInfoTypes.entity => unit,
}
let useUserInfo = () => {
  open LogicUtils
  let fetchApi = AuthHooks.useApiFetcher()
  let {setUserInfoData, userInfo} = React.useContext(UserInfoProvider.defaultContext)
  let url = `${Window.env.apiBaseUrl}/user`
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    try {
      let res = await fetchApi(
        `${url}`,
        ~method_=Get,
        ~xFeatureRoute,
        ~forceCookies,
        ~merchantId={userInfo.merchantId},
        ~profileId={userInfo.profileId},
      )
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapper
      let themeId = userInfo.themeId
      HyperSwitchEntryUtils.setThemeIdtoStore(themeId)
      userInfo
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
  let updateTransactionEntity = (transactionEntity: UserInfoTypes.entity) => {
    let updateInfo = {
      ...userInfo,
      transactionEntity,
    }
    setUserInfoData(updateInfo)
  }
  let updateAnalytcisEntity = (analyticsEntity: UserInfoTypes.entity) => {
    let updateInfo = {
      ...userInfo,
      analyticsEntity,
    }
    setUserInfoData(updateInfo)
  }
  {getUserInfo, updateTransactionEntity, updateAnalytcisEntity}
}

let useOrgSwitch = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {getUserInfo} = useUserInfo()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedOrgId, ~currentOrgId, ~defaultValue, ~version=UserInfoTypes.V1) => {
    try {
      if expectedOrgId !== currentOrgId {
        let url = getURL(~entityName=V1(USERS), ~userType=#SWITCH_ORG, ~methodType=Post)
        let body =
          [("org_id", expectedOrgId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        mixpanelEvent(~eventName=`switch_org`, ~metadata=expectedOrgId->JSON.Encode.string)
        let responseDict = await updateDetails(url, body, Post, ~version)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
        showToast(
          ~message=`Your organization has been switched successfully.`,
          ~toastType=ToastSuccess,
        )
        userInfoRes
      } else {
        defaultValue
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useMerchantSwitch = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {getUserInfo} = useUserInfo()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedMerchantId, ~currentMerchantId, ~defaultValue, ~version=UserInfoTypes.V1) => {
    try {
      if expectedMerchantId !== currentMerchantId {
        let body =
          [
            ("merchant_id", expectedMerchantId->JSON.Encode.string),
          ]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = switch version {
        | V1 => {
            let url = getURL(
              ~entityName=V1(USERS),
              ~userType=#SWITCH_MERCHANT_NEW,
              ~methodType=Post,
            )

            await updateDetails(url, body, Post)
          }
        | V2 => {
            let url = getURL(
              ~entityName=V2(USERS),
              ~userType=#SWITCH_MERCHANT_NEW,
              ~methodType=Post,
            )
            await updateDetails(url, body, Post, ~version=V2)
          }
        }
        mixpanelEvent(
          ~eventName=`switch_merchant`,
          ~metadata=expectedMerchantId->JSON.Encode.string,
        )
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
        showToast(~message=`Your merchant has been switched successfully.`, ~toastType=ToastSuccess)
        userInfoRes
      } else {
        defaultValue
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useProfileSwitch = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {getUserInfo} = useUserInfo()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedProfileId, ~currentProfileId, ~defaultValue, ~version=UserInfoTypes.V1) => {
    try {
      // Need to remove the Empty string check once userInfo contains the profileId
      if expectedProfileId !== currentProfileId && currentProfileId->LogicUtils.isNonEmptyString {
        let url = getURL(~entityName=V1(USERS), ~userType=#SWITCH_PROFILE, ~methodType=Post)
        let body =
          [("profile_id", expectedProfileId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        mixpanelEvent(~eventName=`switch_profile`, ~metadata=expectedProfileId->JSON.Encode.string)
        let responseDict = await updateDetails(url, body, Post, ~version)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
        showToast(~message=`Your profile has been switched successfully.`, ~toastType=ToastSuccess)
        userInfoRes
      } else {
        defaultValue
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useInternalSwitch = () => {
  let orgSwitch = useOrgSwitch()
  let merchSwitch = useMerchantSwitch()
  let profileSwitch = useProfileSwitch()

  let {userInfo, setUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let url = RescriptReactRouter.useUrl()
  async (
    ~expectedOrgId=None,
    ~expectedMerchantId=None,
    ~expectedProfileId=None,
    ~version=UserInfoTypes.V1,
    ~changePath=false,
  ) => {
    try {
      let userInfoResFromSwitchOrg = await orgSwitch(
        ~expectedOrgId=expectedOrgId->Option.getOr(userInfo.orgId),
        ~currentOrgId=userInfo.orgId,
        ~defaultValue=userInfo,
        ~version,
      )

      let userInfoResFromSwitchMerch = await merchSwitch(
        ~expectedMerchantId=expectedMerchantId->Option.getOr(userInfoResFromSwitchOrg.merchantId),
        ~currentMerchantId=userInfoResFromSwitchOrg.merchantId,
        ~defaultValue=userInfoResFromSwitchOrg,
        ~version,
      )

      let userInfoFromProfile = await profileSwitch(
        ~expectedProfileId=expectedProfileId->Option.getOr(userInfoResFromSwitchMerch.profileId),
        ~currentProfileId=userInfoResFromSwitchMerch.profileId,
        ~defaultValue=userInfoResFromSwitchMerch,
        ~version,
      )
      setUserInfoData(userInfoFromProfile)
      if changePath {
        // When the internal switch is triggered from the dropdown,
        // and the current path is "/dashboard/payment/id",
        // update the path to "/dashboard/payment" by removing the "id" part.
        let currentUrl = GlobalVars.extractModulePath(~path=url.path, ~query="", ~end=2)
        RescriptReactRouter.replace(currentUrl)
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to switch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useOMPData = () => {
  open OMPSwitchUtils
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let {userInfo} = React.useContext(UserInfoProvider.defaultContext)

  let getList: unit => OMPSwitchTypes.ompList = _ => {
    {
      orgList,
      merchantList,
      profileList,
    }
  }

  let getNameForId = entityType =>
    switch entityType {
    | #Organization => currentOMPName(orgList, userInfo.orgId)
    | #Merchant => currentOMPName(merchantList, userInfo.merchantId)
    | #Profile => currentOMPName(profileList, userInfo.profileId)
    | _ => ""
    }

  (getList, getNameForId)
}

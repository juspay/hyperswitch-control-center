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
  let {xFeatureRoute} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute)
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapper
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
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedOrgId, ~currentOrgId, ~defaultValue) => {
    try {
      if expectedOrgId !== currentOrgId {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_ORG, ~methodType=Post)
        let body =
          [("org_id", expectedOrgId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
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
  let {getUserInfo} = useUserInfo()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedMerchantId, ~currentMerchantId, ~defaultValue) => {
    try {
      if expectedMerchantId !== currentMerchantId {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT_NEW, ~methodType=Post)
        let body =
          [
            ("merchant_id", expectedMerchantId->JSON.Encode.string),
          ]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
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
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  async (~expectedProfileId, ~currentProfileId, ~defaultValue) => {
    try {
      // Need to remove the Empty string check once userInfo contains the profileId
      if expectedProfileId !== currentProfileId && currentProfileId->LogicUtils.isNonEmptyString {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_PROFILE, ~methodType=Post)
        let body =
          [("profile_id", expectedProfileId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
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

  async (~expectedOrgId=None, ~expectedMerchantId=None, ~expectedProfileId=None) => {
    try {
      let userInfoResFromSwitchOrg = await orgSwitch(
        ~expectedOrgId=expectedOrgId->Option.getOr(userInfo.orgId),
        ~currentOrgId=userInfo.orgId,
        ~defaultValue=userInfo,
      )

      let userInfoResFromSwitchMerch = await merchSwitch(
        ~expectedMerchantId=expectedMerchantId->Option.getOr(userInfoResFromSwitchOrg.merchantId),
        ~currentMerchantId=userInfoResFromSwitchOrg.merchantId,
        ~defaultValue=userInfoResFromSwitchOrg,
      )

      let userInfoFromProfile = await profileSwitch(
        ~expectedProfileId=expectedProfileId->Option.getOr(userInfoResFromSwitchMerch.profileId),
        ~currentProfileId=userInfoResFromSwitchMerch.profileId,
        ~defaultValue=userInfoResFromSwitchMerch,
      )
      setUserInfoData(userInfoFromProfile)
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

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
      setUserInfoData(userInfo)
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
  let {userInfo: userInfoDefault} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedOrgId, ~currentOrgId) => {
    try {
      if expectedOrgId !== currentOrgId {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_ORG, ~methodType=Post)
        let body =
          [("org_id", expectedOrgId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
        Js.log2("test: responseDict",responseDict)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await getUserInfo()
        Js.log2("test: userInfoRes",userInfoRes)
//         let a = {
//     "email": "gitanjli524@gmail.com",
//     "isTwoFactorAuthSetup": false,
//     "merchantId": "merchant_1716809171",
//     "name": "gitanjli524",
//     "orgId": "org_BsTT8ircCeGGzQetAMC0",
//     "roleId": "org_admin",
//     "profileId": "pro_QhK4H8ICiLeN6Q3fZcYE",
//     "userEntity": "Organization",
//     "transactionEntity": "Merchant",
//     "analyticsEntity": "Organization"
// }
        userInfoRes
        // a
      } else {
        userInfoDefault
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
  let {userInfo: userInfoDefault} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedMerchantId, ~currentMerchantId) => {
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
        userInfoDefault
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
  let {userInfo: userInfoDefault} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedProfileId, ~currentProfileId) => {
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
        userInfoDefault
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

  let {userInfo: {orgId: currentOrgId}} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedOrgId=None, ~expectedMerchantId=None, ~expectedProfileId=None) => {
    try {
      let userInfoResFromSwitchOrg = await orgSwitch(
        ~expectedOrgId=expectedOrgId->Option.getOr(currentOrgId),
        ~currentOrgId,
      )
      let userInfoResFromSwitchMerch = await merchSwitch(
        ~expectedMerchantId=expectedMerchantId->Option.getOr(userInfoResFromSwitchOrg.merchantId),
        ~currentMerchantId=userInfoResFromSwitchOrg.merchantId,
      )
      let _ = await profileSwitch(
        ~expectedProfileId=expectedProfileId->Option.getOr(userInfoResFromSwitchMerch.profileId),
        ~currentProfileId=userInfoResFromSwitchMerch.profileId,
      )
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

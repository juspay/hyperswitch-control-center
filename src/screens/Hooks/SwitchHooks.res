let useUserInfo = () => {
  open LogicUtils
  let fetchApi = AuthHooks.useApiFetcher()
  let {setUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let url = `${Window.env.apiBaseUrl}/user`

  async _ => {
    try {
      let res = await fetchApi(`${url}`, ~method_=Get)
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
}

let useOrgSwitch = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let userDetails = useUserInfo()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let {userInfo: userInfoDefault} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedOrgId, ~currentOrgId) => {
    try {
      if expectedOrgId !== currentOrgId {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_ORG, ~methodType=Post)
        let body =
          [("org_id", expectedOrgId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await userDetails()
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

let useMerchantSwitch = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let userDetails = useUserInfo()
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
        let userInfoRes = await userDetails()
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
  let userDetails = useUserInfo()
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let {userInfo: userInfoDefault} = React.useContext(UserInfoProvider.defaultContext)

  async (~expectedProfileId, ~currentProfileId) => {
    try {
      if expectedProfileId !== currentProfileId {
        let url = getURL(~entityName=USERS, ~userType=#SWITCH_PROFILE, ~methodType=Post)
        let body =
          [("profile_id", expectedProfileId->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let responseDict = await updateDetails(url, body, Post)
        setAuthStatus(LoggedIn(Auth(AuthUtils.getAuthInfo(responseDict))))
        let userInfoRes = await userDetails()
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

  let {userInfo: {orgId: currentOrgId, merchantId: currentMerchantId}} = React.useContext(
    UserInfoProvider.defaultContext,
  )

  let currentProfileId = "afvedfve"

  async (~expectedOrgId=None, ~expectedMerchantId=None, ~expectedProfileId=None) => {
    try {
      let userInfoResFromSwitchOrg = await orgSwitch(
        ~expectedOrgId=expectedOrgId->Option.getOr(currentOrgId),
        ~currentOrgId,
      )
      let userInfoResFromSwitchMerch = await merchSwitch(
        ~expectedMerchantId=expectedMerchantId->Option.getOr(currentMerchantId),
        ~currentMerchantId=userInfoResFromSwitchOrg.merchantId,
      )
      // Change the ~currentProfileId=userInfoResFromSwitchMerch.orgId to userInfoResFromSwitchMerch.profileId
      let _ = await profileSwitch(
        ~expectedProfileId=expectedProfileId->Option.getOr(currentProfileId),
        ~currentProfileId=userInfoResFromSwitchMerch.orgId,
      )
    } catch {
    | _ => ()
    }
  }
}

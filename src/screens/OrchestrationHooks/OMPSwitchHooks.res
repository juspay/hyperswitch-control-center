type userInfo = {
  getUserInfo: unit => promise<UserInfoTypes.userInfo>,
  updateTransactionEntity: UserInfoTypes.entity => unit,
  updateAnalytcisEntity: UserInfoTypes.entity => unit,
}

let useUserInfo = () => {
  open LogicUtils
  let fetchApi = AuthHooks.useApiFetcher()
  let {
    getCommonSessionDetails,
    setUpdatedDashboardSessionInfo,
    getResolvedUserInfo,
  } = React.useContext(UserInfoProvider.defaultContext)
  let {profileId, merchantId} = getCommonSessionDetails()

  let url = `${Window.env.apiBaseUrl}/user`
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    try {
      let res = await fetchApi(
        `${url}`,
        ~method_=Get,
        ~xFeatureRoute,
        ~forceCookies,
        ~merchantId={merchantId},
        ~profileId={profileId},
      )
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapperToDashboardUserType
      HyperSwitchEntryUtils.setThemeIdtoStore(userInfo.themeId)
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
      ...getResolvedUserInfo(),
      transactionEntity,
    }
    setUpdatedDashboardSessionInfo(updateInfo)
  }
  let updateAnalytcisEntity = (analyticsEntity: UserInfoTypes.entity) => {
    let updateInfo = {
      ...getResolvedUserInfo(),
      analyticsEntity,
    }
    setUpdatedDashboardSessionInfo(updateInfo)
  }
  {getUserInfo, updateTransactionEntity, updateAnalytcisEntity}
}

let useOrgSwitch = (~setActiveProductValue) => {
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
        switch setActiveProductValue {
        | Some(fn) => fn(ProductTypes.UnknownProduct)
        | None => ()
        }
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

let useMerchantSwitch = (~setActiveProductValue) => {
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
        switch setActiveProductValue {
        | Some(fn) => fn(ProductTypes.UnknownProduct)
        | None => ()
        }
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

let useInternalSwitch = (~setActiveProductValue: option<ProductTypes.productTypes => unit>=?) => {
  open HyperswitchAtom
  let orgSwitch = useOrgSwitch(~setActiveProductValue)
  let merchSwitch = useMerchantSwitch(~setActiveProductValue)
  let {product_type} = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let profileSwitch = useProfileSwitch()
  let {getCommonSessionDetails, setApplicationState, getResolvedUserInfo} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {orgId} = getCommonSessionDetails()
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
        ~expectedOrgId=expectedOrgId->Option.getOr(orgId),
        ~currentOrgId=orgId,
        ~defaultValue=getResolvedUserInfo(),
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

      setApplicationState(_ => DashboardSession(userInfoFromProfile))

      if changePath {
        // When the internal switch is triggered from the dropdown,
        // and the current path is "/dashboard/payment/id",
        // update the path to "/dashboard/payment" by removing the "id" part.
        let currentUrl = GlobalVars.extractModulePath(~path=url.path, ~query="", ~end=2)
        RescriptReactRouter.replace(currentUrl)
      }
    } catch {
    | Exn.Error(e) => {
        switch setActiveProductValue {
        | Some(fn) => fn(product_type)
        | None => ()
        }
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
  let {orgId, profileId, merchantId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()

  let getList: unit => OMPSwitchTypes.ompList = _ => {
    {
      orgList,
      merchantList,
      profileList,
    }
  }

  let getNameForId = entityType =>
    switch entityType {
    | #Organization => currentOMPName(orgList, orgId)
    | #Merchant => currentOMPName(merchantList, merchantId)
    | #Profile => currentOMPName(profileList, profileId)
    | _ => ""
    }

  (getList, getNameForId)
}

let useOMPType = () => {
  let {merchant_account_type} = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  )
  let {organization_type} = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.organizationDetailsValueAtom,
  )

  let isCurrentMerchantPlatform = switch merchant_account_type {
  | #platform => true
  | _ => false
  }

  let isCurrentOrganizationPlatform = switch organization_type {
  | #platform => true
  | _ => false
  }

  (isCurrentMerchantPlatform, isCurrentOrganizationPlatform)
}

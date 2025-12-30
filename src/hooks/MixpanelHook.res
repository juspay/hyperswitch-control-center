type functionType = (~eventName: string=?, ~email: string=?, ~description: option<string>=?) => unit

let useSendEvent = () => {
  open GlobalVars
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let {name, email: authInfoEmail} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getResolvedUserInfo()

  let deviceId = switch LocalStorage.getItem("deviceId")->Nullable.toOption {
  | Some(id) => id
  | None => authInfoEmail
  }

  let parseEmail = email => {
    email->String.length == 0 ? authInfoEmail : email
  }

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {clientCountry} = HSwitchUtils.getBrowswerDetails()
  let country = clientCountry.isoAlpha2->CountryUtils.getCountryCodeStringFromVarient

  let environment = GlobalVars.hostType->getEnvironment

  let url = RescriptReactRouter.useUrl()

  let getUrlEndpoint = () => {
    switch GlobalVars.dashboardBasePath {
    | Some(_) => url.path->List.toArray->Array.get(1)->Option.getOr("")
    | _ => url.path->List.toArray->Array.get(0)->Option.getOr("")
    }
  }

  let trackApi = async (
    ~email,
    ~merchantId,
    ~description,
    ~event,
    ~section,
    ~metadata=JSON.Encode.null,
  ) => {
    let mixpanel_token = Window.env.mixpanelToken

    let body = {
      "event": event,
      "properties": {
        "section": section,
        "metadata": metadata,
        "token": mixpanel_token,
        "distinct_id": deviceId,
        "$device_id": deviceId->String.split(":")->Array.get(1),
        "$screen_height": Screen.screenHeight,
        "$screen_width": Screen.screenWidth,
        "name": email,
        "merchantName": name,
        "email": email,
        "mp_lib": "restapi",
        "merchantId": merchantId,
        "environment": environment,
        "description": description,
        "lang": Navigator.browserLanguage,
        "$os": Navigator.platform,
        "$browser": Navigator.browserName,
        "mp_country_code": country,
      },
    }

    try {
      let _ = await fetchApi(
        `${getHostUrl}/mixpanel/track`,
        ~method_=Post,
        ~bodyStr=`data=${body->JSON.stringifyAny->Option.getOr("")->encodeURI}`,
        ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
        ~forceCookies=featureFlagDetails.forceCookies,
      )
    } catch {
    | _ => ()
    }
  }

  (~eventName, ~email="", ~description=None, ~section="", ~metadata=JSON.Encode.null) => {
    let section = section->LogicUtils.isNonEmptyString ? section : getUrlEndpoint()
    let eventName = eventName->String.toLowerCase

    if featureFlagDetails.mixpanel {
      trackApi(
        ~email={email->parseEmail},
        ~merchantId,
        ~description,
        ~event={eventName},
        ~section,
        ~metadata,
      )->ignore
    }
  }
}

let usePageView = () => {
  open GlobalVars
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let {name, email} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()

  let environment = GlobalVars.hostType->getEnvironment
  let {clientCountry} = HSwitchUtils.getBrowswerDetails()
  let country = clientCountry.isoAlpha2->CountryUtils.getCountryCodeStringFromVarient
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  async (~path) => {
    let mixpanel_token = Window.env.mixpanelToken
    let body = {
      "event": "page_view",
      "properties": {
        "token": mixpanel_token,
        "distinct_id": email,
        "$device_id": email->String.split(":")->Array.get(1),
        "$screen_height": Screen.screenHeight,
        "$screen_width": Screen.screenWidth,
        "name": email,
        "merchantName": name,
        "email": email,
        "mp_lib": "restapi",
        "merchantId": merchantId,
        "environment": environment,
        "lang": Navigator.browserLanguage,
        "$os": Navigator.platform,
        "$browser": Navigator.browserName,
        "mp_country_code": country,
        "page": path,
      },
    }

    try {
      if featureFlagDetails.mixpanel {
        let _ = await fetchApi(
          `${getHostUrl}/mixpanel/track`,
          ~method_=Post,
          ~bodyStr=`data=${body->JSON.stringifyAny->Option.getOr("")->encodeURI}`,
          ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
          ~forceCookies=featureFlagDetails.forceCookies,
        )
      }
    } catch {
    | _ => ()
    }
  }
}

let useSetIdentity = () => {
  open GlobalVars
  let fetchApi = AuthHooks.useApiFetcher()
  let mixpanel_token = Window.env.mixpanelToken
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  async (~distinctId) => {
    let name = distinctId->LogicUtils.getNameFromEmail
    let body = {
      "event": `$identify`,
      "properties": {
        "distinct_id": distinctId,
        "token": mixpanel_token,
      },
    }
    let peopleProperties = {
      "$token": mixpanel_token,
      "$distinct_id": distinctId,
      "$set": {
        "$email": distinctId,
        "$first_name": name,
      },
    }

    try {
      if featureFlagDetails.mixpanel {
        let _ = await fetchApi(
          `${getHostUrl}/mixpanel/track`,
          ~method_=Post,
          ~bodyStr=`data=${body->JSON.stringifyAny->Option.getOr("")->encodeURI}`,
          ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
          ~forceCookies=featureFlagDetails.forceCookies,
        )
        let _ = await fetchApi(
          `${getHostUrl}/mixpanel/engage`,
          ~method_=Post,
          ~bodyStr=`data=${peopleProperties->JSON.stringifyAny->Option.getOr("")->encodeURI}`,
          ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
          ~forceCookies=featureFlagDetails.forceCookies,
        )
      }
    } catch {
    | _ => ()
    }
  }
}

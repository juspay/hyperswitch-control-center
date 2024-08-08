type functionType = (~eventName: string=?, ~email: string=?, ~description: option<string>=?) => unit

let useSendEvent = () => {
  open GlobalVars
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let {email: authInfoEmail, merchantId, name} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)

  let deviceId = switch LocalStorage.getItem("deviceid")->Nullable.toOption {
  | Some(id) => id
  | None => authInfoEmail
  }

  let parseEmail = email => {
    email->String.length == 0 ? authInfoEmail : email
  }

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {clientCountry} = HSwitchUtils.getBrowswerDetails()
  let country = clientCountry.isoAlpha2->CountryUtils.getCountryCodeStringFromVarient

  let environment = switch GlobalVars.hostType {
  | Live => "production"
  | Sandbox => "sandbox"
  | Netlify => "netlify"
  | Local => "localhost"
  }

  let mixpanel_token = Window.env.mixpanelToken

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
    ~metadata=Dict.make(),
  ) => {
    let body = {
      "section": section,
      "event": event,
      "metadata": metadata,
      "properties": {
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
      )
    } catch {
    | _ => ()
    }
  }

  (~eventName, ~email="", ~description=None, ~section="", ~metadata=Dict.make()) => {
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

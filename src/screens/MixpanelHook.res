type functionType = (
  ~eventName: string=?,
  ~email: string=?,
  ~description: option<string>=?,
  unit,
) => unit

let useSendEvent = () => {
  open HSwitchGlobalVars
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let {email: authInfoEmail, merchant_id, name} =
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

  let environment = switch HSwitchGlobalVars.hostType {
  | Live => "production"
  | Sandbox => "sandbox"
  | Netlify => "netlify"
  | Local => "localhost"
  }

  let mixpanelToken = Window.env.mixpanelToken

  let trackApi = async (~email, ~merchantId, ~description, ~event) => {
    let body = {
      "event": event,
      "properties": {
        "token": mixpanelToken,
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
        ~method_=Fetch.Post,
        ~bodyStr=`data=${body->JSON.stringifyAny->Option.getOr("")->encodeURI}`,
        (),
      )
    } catch {
    | _ => ()
    }
  }

  (~eventName, ~email="", ~description=None, ()) => {
    let eventName = eventName->String.toLowerCase

    if featureFlagDetails.mixpanel {
      trackApi(
        ~email={email->parseEmail},
        ~merchantId=merchant_id,
        ~description,
        ~event={eventName},
      )->ignore
    }
  }
}

type functionType = (
  ~eventName: Js.String2.t=?,
  ~email: Js.String.t=?,
  ~description: option<string>=?,
  unit,
) => unit

let useSendEvent = () => {
  open HSwitchGlobalVars
  open HSLocalStorage
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let name = getFromUserDetails("name")
  let deviceId = switch LocalStorage.getItem("deviceid")->Js.Nullable.toOption {
  | Some(id) => id
  | None => getFromUserDetails("email")
  }

  let parseEmail = email => {
    email->String.length == 0 ? getFromMerchantDetails("email") : email
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

  let trackApi = async (~email, ~merchantId, ~description, ~event) => {
    let body = {
      "event": event,
      "properties": {
        "token": mixpanelToken,
        "distinct_id": deviceId,
        "$device_id": deviceId->String.split(":")->Belt.Array.get(1),
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
        `${dashboardUrl}/mixpanel/track`,
        ~method_=Fetch.Post,
        ~bodyStr=`data=${body
          ->Js.Json.stringifyAny
          ->Belt.Option.getWithDefault("")
          ->Js.Global.encodeURI}`,
        (),
      )
    } catch {
    | _ => ()
    }
  }

  (~eventName, ~email="", ~description=None, ()) => {
    let eventName = eventName->String.toLowerCase
    let merchantId = getFromMerchantDetails("merchant_id")

    if featureFlagDetails.mixpanel {
      trackApi(~email={email->parseEmail}, ~merchantId, ~description, ~event={eventName})->ignore
    }
    if featureFlagDetails.mixpanelSdk {
      MixPanel.track(
        eventName,
        {
          "email": email->parseEmail,
          "merchantId": merchantId,
          "environment": environment,
          "description": description,
        },
      )
    }
  }
}

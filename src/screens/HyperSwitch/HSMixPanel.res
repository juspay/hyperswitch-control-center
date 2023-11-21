type functionType = (
  ~eventName: option<Js.String2.t>=?,
  ~email: Js.String.t=?,
  ~pageName: string=?,
  ~actionName: string=?,
  ~contextName: string=?,
  ~description: option<string>=?,
  ~isApiFailure: bool=?,
  ~apiUrl: string=?,
  ~apiMethodName: string=?,
  ~xRequestId: option<string>=?,
  ~responseStatusCode: option<int>=?,
  unit,
) => unit

let useSendEvent = () => {
  open HSwitchGlobalVars
  open HSLocalStorage
  open Window
  let fetchApi = AuthHooks.useApiFetcher()
  let url = RescriptReactRouter.useUrl()
  let name = getFromUserDetails("name")
  let deviceId = switch LocalStorage.getItem("deviceid")->Js.Nullable.toOption {
  | Some(id) => id
  | None => getFromUserDetails("email")
  }
  let currentUrl = `${hyperSwitchFEPrefix}/${url.path->Js.List.hd->Belt.Option.getWithDefault("")}`

  let parseEmail = email => {
    email->Js.String.length == 0 ? getFromMerchantDetails("email") : email
  }

  let featureFlagDetails =
    HyperswitchAtom.featureFlagAtom
    ->Recoil.useRecoilValueFromAtom
    ->LogicUtils.safeParse
    ->FeatureFlagUtils.featureFlagType

  let environment = switch HSwitchGlobalVars.hostType {
  | Integ => "staging"
  | Live => "production"
  | Sandbox => "sandbox"
  | Netlify => "netlify"
  | Local => "localhost"
  }

  let trackApi = async (
    ~email,
    ~merchantId,
    ~description: option<string>=None,
    ~requestId,
    ~statusCode,
    ~event,
  ) => {
    let body = {
      "event": event,
      "properties": {
        "token": mixpanelToken,
        "distinct_id": deviceId,
        "$device_id": deviceId->Js.String2.split(":")->Belt.Array.get(1),
        "$screen_height": Screen.screenHeight,
        "$screen_width": Screen.screenWidth,
        "name": email,
        "merchantName": name,
        "email": email,
        "mp_lib": "restapi",
        "merchantId": merchantId,
        "environment": environment,
        "description": description,
        "x-request-id": requestId,
        "responseStatusCode": statusCode,
        "$current_url": currentUrl,
        "lang": Navigator.browserLanguage,
        "$os": Navigator.platform,
        "$browser": Navigator.browserName,
      },
    }

    try {
      let _res = await fetchApi(
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

  (
    ~eventName=None,
    ~email="",
    ~pageName="",
    ~actionName="",
    ~contextName="",
    ~description=None,
    ~isApiFailure=false,
    ~apiUrl="",
    ~apiMethodName=Fetch.Post->LogicUtils.methodStr,
    ~xRequestId=None,
    ~responseStatusCode=None,
    (),
  ) => {
    // Use eventName if the event is not of the form pageName_contextName_actionName
    let eventName = switch eventName {
    | Some(event_name) => event_name
    | None => `${pageName}_${contextName}_${actionName}`
    }->Js.String2.toLowerCase

    let apiFailureMessage = `Hyperswitch API Failure - ${apiMethodName} - ${apiUrl}`
    let someRequestId = xRequestId->Belt.Option.getWithDefault("")
    let someStatusCode = responseStatusCode->Belt.Option.getWithDefault(0)
    let merchantId = getFromMerchantDetails("merchant_id")

    if featureFlagDetails.mixPanel {
      MixPanel.track(
        isApiFailure ? apiFailureMessage : eventName,
        {
          "email": email->parseEmail,
          "merchantId": merchantId,
          "environment": environment,
          "description": description,
          "x-request-id": someRequestId,
          "responseStatusCode": someStatusCode,
        },
      )
      trackApi(
        ~email={email->parseEmail},
        ~merchantId,
        ~description,
        ~requestId={someRequestId},
        ~statusCode={someStatusCode},
        ~event={isApiFailure ? apiFailureMessage : eventName},
      )->ignore
    }
  }
}

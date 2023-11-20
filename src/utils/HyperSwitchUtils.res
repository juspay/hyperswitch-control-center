let fetchRequestIdFromAPI = res => {
  Fetch.Headers.get("x-request-id")(res->Fetch.Response.headers)->Belt.Option.getWithDefault("")
}

//to remove
let getErrorStringifiedJson = (json, key) => {
  json
  ->Js.Json.decodeObject
  ->Belt.Option.getWithDefault(Js.Dict.empty())
  ->LogicUtils.getJsonObjectFromDict(key)
  ->Js.Json.stringifyAny
  ->Belt.Option.getWithDefault("")
}

let parseErrorJson = json => {
  open LogicUtils
  let valuesDict = json->getDictFromJsonObject
  let errorDict = valuesDict->getObj("error", Js.Dict.empty())
  errorDict->getString("message", "")
}

let getMixpanelRouteName = (pageTitle, url: RescriptReactRouter.url) => {
  switch (url.path, url.search) {
  | (list{"payments", ""}, _)
  | (list{"refunds", ""}, _)
  | (list{"disputes", ""}, _)
  | (list{"connectors", ""}, _)
  | (list{"routing", ""}, _)
  | (list{"settings"}, "") =>
    `/${pageTitle}`
  | (list{"onboarding"}, "") => `/${pageTitle}`
  | (list{"payments", _}, _) => `/${pageTitle}/paymentid`
  | (list{"refunds", _}, _) => `/${pageTitle}/refundid`
  | (list{"disputes", _}, _) => `/${pageTitle}/disputeid`
  | (list{"connectors", "new"}, _) => `/${pageTitle}/newconnector`
  | (list{"connectors", _}, _) => `/${pageTitle}/updateconnector`
  | (list{"routing", routingType}, "") => `/${pageTitle}/${routingType}/newrouting`
  | (list{"routing", routingType}, _) => `/${pageTitle}/${routingType}/oldrouting`
  | (list{"settings"}, searchParamValue) => {
      let type_ =
        LogicUtils.getDictFromUrlSearchParams(searchParamValue)
        ->Js.Dict.get("type")
        ->Belt.Option.getWithDefault("")
      `/${pageTitle}/${type_}`
    }

  | (list{"onboarding"}, searchParamValue) => {
      let type_ =
        LogicUtils.getDictFromUrlSearchParams(searchParamValue)
        ->Js.Dict.get("type")
        ->Belt.Option.getWithDefault("")
      `/${pageTitle}/${type_}`
    }

  | _ => `/${url.path->Belt.List.toArray->Js.Array2.joinWith("/")}`
  }
}

let delay = ms =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let _timerId = Js.Global.setTimeout(() => resolve(. ()), ms)
  })

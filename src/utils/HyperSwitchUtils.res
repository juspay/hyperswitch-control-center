let fetchRequestIdFromAPI = res => {
  Fetch.Headers.get("x-request-id")(res->Fetch.Response.headers)->Belt.Option.getWithDefault("")
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
        ->Dict.get("type")
        ->Belt.Option.getWithDefault("")
      `/${pageTitle}/${type_}`
    }

  | (list{"onboarding"}, searchParamValue) => {
      let type_ =
        LogicUtils.getDictFromUrlSearchParams(searchParamValue)
        ->Dict.get("type")
        ->Belt.Option.getWithDefault("")
      `/${pageTitle}/${type_}`
    }

  | _ => `/${url.path->Belt.List.toArray->Array.joinWith("/")}`
  }
}

let delay = ms =>
  Js.Promise.make((~resolve, ~reject as _) => {
    let _ = Js.Global.setTimeout(() => resolve(. ()), ms)
  })

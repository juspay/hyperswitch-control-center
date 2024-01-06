let parseUrlIntoDict = queryUrl => {
  let arr = queryUrl->Js.Global.decodeURI->String.split("&")->Array.map(e => e->String.split("="))
  let safeArray = arr->Array.filter(e => e->Array.length == 2)
  let dict: Js.Dict.t<string> = Dict.make()
  safeArray->Array.forEach(e => {
    dict->Dict.set(
      e->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      e->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
    )
  })

  dict
}
type queryInput = String(string, string) | Array(string, array<string>)

let changeSearchValue = (~arr: array<queryInput>, ~queryUrl, ~path) => {
  let dict = parseUrlIntoDict(queryUrl)
  arr->Array.forEach(query => {
    switch query {
    | String(key, val) => dict->Dict.set(key, val)
    | Array(key, val) =>
      dict->Dict.set(
        key,
        `[${val->Array.reduceWithIndex("", (acc, e, i) => `${acc}${i == 0 ? "" : ","}${e}`)}]`,
      )
    }
  })
  let path = path->Belt.List.reduce("", (acc, item) => `${acc}/${item}`)
  let entry = dict->Dict.toArray
  let query =
    entry->Array.reduceWithIndex("", (acc, (key, value), i) =>
      `${acc}${i == 0 ? "" : "&"}${key}=${value}`
    )
  RescriptReactRouter.replace(`${path}?${query}`)
}
let getQueryValue = (~queryUrl, ~key: queryInput) => {
  let dict = parseUrlIntoDict(queryUrl->Js.Global.decodeURI)
  switch key {
  | String(key, initialVal) =>
    String(
      key,
      dict->Dict.get(key)->Belt.Option.mapWithDefault(initialVal, a => a->Js.Global.decodeURI),
    )
  | Array(key, initialval) =>
    Array(
      key,
      dict
      ->Dict.get(key)
      ->Belt.Option.mapWithDefault(initialval, a => {
        a
        ->Js.Global.decodeURI
        ->String.replace("[", "")
        ->String.replace("]", "")
        ->String.split(",")
        ->Array.filter(e => e !== "")
      }),
    )
  }
}

let useSearchQuery = () => {
  let queryUrl = RescriptReactRouter.useUrl().search
  let path = RescriptReactRouter.useUrl().path
  let changeSearchValue = changeSearchValue(~path, ~queryUrl)
  let getQueryValue = getQueryValue(~queryUrl)
  (queryUrl, changeSearchValue, getQueryValue)
}

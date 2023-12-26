let parseUrlIntoDict = queryUrl => {
  let arr =
    queryUrl
    ->Js.Global.decodeURI
    ->Js.String2.split("&")
    ->Js.Array2.map(e => e->Js.String2.split("="))
  let safeArray = arr->Js.Array2.filter(e => e->Js.Array2.length == 2)
  let dict: Js.Dict.t<string> = Js.Dict.empty()
  safeArray->Js.Array2.forEach(e => {
    dict->Js.Dict.set(
      e->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      e->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
    )
  })

  dict
}
type queryInput = String(string, string) | Array(string, array<string>)

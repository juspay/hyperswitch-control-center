let parseUrlIntoDict = queryUrl => {
  let arr = queryUrl->Js.Global.decodeURI->String.split("&")->Array.map(e => e->String.split("="))
  let safeArray = arr->Array.filter(e => e->Array.length == 2)
  let dict: Dict.t<string> = Dict.make()
  safeArray->Array.forEach(e => {
    dict->Dict.set(
      e->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      e->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
    )
  })

  dict
}
type queryInput = String(string, string) | Array(string, array<string>)

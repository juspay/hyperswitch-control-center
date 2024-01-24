let parseUrlIntoDict = queryUrl => {
  let arr = queryUrl->Js.Global.decodeURI->String.split("&")->Array.map(e => e->String.split("="))
  let safeArray = arr->Array.filter(e => e->Array.length == 2)
  let dict: Dict.t<string> = Dict.make()
  safeArray->Array.forEach(e => {
    dict->Dict.set(e->Array.get(0)->Option.getOr(""), e->Array.get(1)->Option.getOr(""))
  })

  dict
}
type queryInput = String(string, string) | Array(string, array<string>)

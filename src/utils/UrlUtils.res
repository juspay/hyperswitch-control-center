let useGetFilterDictFromUrl = prefix => {
  let url = RescriptReactRouter.useUrl()
  let (searchParamsDict, setSearchParamDict) = React.useState(_ => Js.Dict.empty())

  React.useEffect1(() => {
    if url.search !== "" {
      let searcParamsToDict =
        url.search
        ->Js.Global.decodeURI
        ->Js.String2.split("&")
        ->Js.Array2.map(str => {
          let arr = str->Js.String2.split("=")
          let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
          let val = arr->Belt.Array.sliceToEnd(1)->Js.Array2.joinWith("=")

          (key, val->UrlFetchUtils.getFilterValue) // it will return the Json string, Json array
        })
        ->Belt.Array.keepMap(entry => {
          let (key, val) = entry
          if prefix === "" {
            entry->Some
          } else if key->Js.String2.indexOf(`${prefix}.`) === 0 {
            let transformedKey = key->Js.String2.replace(`${prefix}.`, "")
            (transformedKey, val)->Some
          } else {
            None
          }
        })
        ->Js.Dict.fromArray
      setSearchParamDict(_ => searcParamsToDict)
    }

    None
  }, [url.search])

  searchParamsDict
}

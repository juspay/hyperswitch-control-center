let useGetFilterDictFromUrl = prefix => {
  let url = RescriptReactRouter.useUrl()
  let (searchParamsDict, setSearchParamDict) = React.useState(_ => Dict.make())

  React.useEffect1(() => {
    if url.search !== "" {
      let searcParamsToDict =
        url.search
        ->Js.Global.decodeURI
        ->String.split("&")
        ->Array.map(str => {
          let arr = str->String.split("=")
          let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
          let val = arr->Belt.Array.sliceToEnd(1)->Array.joinWith("=")

          (key, val->UrlFetchUtils.getFilterValue) // it will return the Json string, Json array
        })
        ->Belt.Array.keepMap(entry => {
          let (key, val) = entry
          if prefix === "" {
            entry->Some
          } else if key->String.indexOf(`${prefix}.`) === 0 {
            let transformedKey = key->String.replace(`${prefix}.`, "")
            (transformedKey, val)->Some
          } else {
            None
          }
        })
        ->Dict.fromArray
      setSearchParamDict(_ => searcParamsToDict)
    }

    None
  }, [url.search])

  searchParamsDict
}

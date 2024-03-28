let useGetFilterDictFromUrl = prefix => {
  let url = RescriptReactRouter.useUrl()
  let (searchParamsDict, setSearchParamDict) = React.useState(_ => Dict.make())

  React.useEffect1(() => {
    if url.search->LogicUtils.isNonEmptyString {
      let searcParamsToDict =
        url.search
        ->decodeURI
        ->String.split("&")
        ->Array.map(str => {
          let arr = str->String.split("=")
          let key = arr->Array.get(0)->Option.getOr("-")
          let val = arr->Array.sliceToEnd(~start=1)->Array.joinWith("=")

          (key, val->UrlFetchUtils.getFilterValue) // it will return the Json string, Json array
        })
        ->Belt.Array.keepMap(entry => {
          let (key, val) = entry
          if prefix->LogicUtils.isEmptyString {
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

let useGetFilterDictFromUrl = prefix => {
  let url = RescriptReactRouter.useUrl()
  let (searchParamsDict, setSearchParamDict) = React.useState(_ => Dict.make())

  React.useEffect1(() => {
    if url.search !== "" {
      let searcParamsToDict =
        url.search
        ->Js.Global.decodeURI
        ->Js.String2.split("&")
        ->Array.map(str => {
          let arr = str->Js.String2.split("=")
          let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
          let val = arr->Belt.Array.sliceToEnd(1)->Array.joinWith("=")

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
        ->Dict.fromArray
      setSearchParamDict(_ => searcParamsToDict)
    }

    None
  }, [url.search])

  searchParamsDict
}

let useUpdateUrlWith = (~prefix as _: string) => {
  let url = RescriptReactRouter.useUrl()
  let updateUrl = (~dict: Js.Dict.t<string>) => {
    let currentSearchParamsDict =
      url.search
      ->Js.Global.decodeURI
      ->Js.String2.split("&")
      ->Belt.Array.keepMap(str => {
        let arr = str->Js.String2.split("=")
        let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
        let val = arr->Belt.Array.sliceToEnd(1)->Array.joinWith("=")
        key === "" || val === "" ? None : Some((key, val))
      })
      ->Dict.fromArray
    let path = url.path->Belt.List.toArray->Array.joinWith("/")

    let searchParam =
      dict
      ->Dict.toArray
      ->Array.map(item => {
        let (key, value) = item
        `${key}=${value}`
      })
      ->Array.joinWith("&")

    if !DictionaryUtils.equalDicts(currentSearchParamsDict, dict) {
      RescriptReactRouter.push(`/${path}?${searchParam}`)
    }
  }
  updateUrl
}

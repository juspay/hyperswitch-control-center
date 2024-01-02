let defaultValue: Js.Dict.t<string> = Dict.make()
let setDefaultValue: Js.Dict.t<string> => unit = _dict => ()
let nameSpace: string = ""
let setDefaultNameSpace: string => unit = _ => ()

type urlUpdater = {
  filterValue: Js.Dict.t<string>,
  updateExistingKeys: Js.Dict.t<string> => unit,
  removeKeys: array<string> => unit,
  filterValueJson: Js.Dict.t<Js.Json.t>,
  reset: unit => unit,
}

let urlUpdater = {
  filterValue: Dict.make(),
  updateExistingKeys: _dict => (),
  removeKeys: _arr => (),
  filterValueJson: Dict.make(),
  reset: () => (),
}

let urlUpdaterContext = React.createContext(urlUpdater)

module Provider = {
  let make = React.Context.provider(urlUpdaterContext)
}

@react.component
let make = (~children) => {
  let url = RescriptReactRouter.useUrl()
  let searcParamsToDict =
    url.search
    ->Js.Global.decodeURI
    ->Js.String2.split("&")
    ->Belt.Array.keepMap(str => {
      let arr = str->Js.String2.split("=")
      let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
      let val = arr->Belt.Array.sliceToEnd(1)->Array.joinWith("=")
      key === "" || val === "" ? None : Some((key, val))
    })
    ->Js.Dict.fromArray

  let (urlDict, setUrlDict) = React.useState(_ => searcParamsToDict)
  let updateUrl = React.useMemo2(() => {
    let updateUrl = (dict: Js.Dict.t<string>) => {
      setUrlDict(prev => {
        let prevDictArr =
          prev
          ->Dict.toArray
          ->Belt.Array.keepMap(
            item => {
              let (key, value) = item
              switch dict->Js.Dict.get(key) {
              | Some(_) => None
              | None => value !== "" ? Some(item) : None
              }
            },
          )
        let currentDictArr =
          dict
          ->Dict.toArray
          ->Array.filter(
            item => {
              let (_, value) = item
              value !== ""
            },
          )

        let updatedDict = Array.concat(prevDictArr, currentDictArr)->Js.Dict.fromArray
        if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
      })
    }

    let reset = () => {
      setUrlDict(_ => Dict.make())
    }

    let removeKeys = (arr: array<string>) => {
      setUrlDict(prev => {
        let updatedDict =
          prev->Dict.toArray->Array.copy->Js.Dict.fromArray->DictionaryUtils.deleteKeys(arr)
        if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
      })
    }
    {
      filterValue: urlDict,
      updateExistingKeys: updateUrl,
      removeKeys,
      filterValueJson: urlDict
      ->Dict.toArray
      ->Array.map(item => {
        let (key, value) = item
        (key, value->UrlFetchUtils.getFilterValue)
      })
      ->Js.Dict.fromArray,
      reset,
    }
  }, (urlDict, setUrlDict))

  <Provider value={updateUrl}> children </Provider>
}

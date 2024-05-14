type sessionStorage = {
  getItem: (. string) => Nullable.t<string>,
  setItem: (. string, string) => unit,
  removeItem: (. string) => unit,
}

@val external sessionStorage: sessionStorage = "sessionStorage"

type filterUpdater = {
  query: string,
  filterValue: Dict.t<string>,
  updateExistingKeys: Dict.t<string> => unit,
  removeKeys: array<string> => unit,
  filterKeys: array<string>,
  setfilterKeys: (array<string> => array<string>) => unit,
  filterValueJson: Dict.t<JSON.t>,
  reset: unit => unit,
}

let filterUpdater = {
  query: "",
  filterValue: Dict.make(),
  updateExistingKeys: _dict => (),
  removeKeys: _arr => (),
  filterValueJson: Dict.make(),
  filterKeys: [],
  setfilterKeys: _ => (),
  reset: () => (),
}

let filterContext = React.createContext(filterUpdater)

module Provider = {
  let make = React.Context.provider(filterContext)
}

@react.component
let make = (~index: string, ~children) => {
  open FilterUtils
  open LogicUtils
  let query = React.useMemo0(() => {ref("")})
  let (filterKeys, setfilterKeys) = React.useState(_ => [])
  let searcParamsToDict = query.contents->parseFilterString
  let (filterDict, setfilterDict) = React.useState(_ => searcParamsToDict)

  let clearSessionStorage = () => {
    sessionStorage.removeItem(. index)
    sessionStorage.removeItem(. `${index}-list`)
    setfilterKeys(_ => [])
  }

  let updateFilter = React.useMemo3(() => {
    let updateFilter = (dict: Dict.t<string>) => {
      setfilterDict(prev => {
        let prevDictArr =
          prev
          ->Dict.toArray
          ->Belt.Array.keepMap(
            item => {
              let (key, value) = item
              switch dict->Dict.get(key) {
              | Some(_) => None
              | None => !(value->isEmptyString) ? Some(item) : None
              }
            },
          )
        let currentDictArr =
          dict
          ->Dict.toArray
          ->Array.filter(
            item => {
              let (_, value) = item
              !(value->isEmptyString)
            },
          )

        let updatedDict = Array.concat(prevDictArr, currentDictArr)->Dict.fromArray
        let dict = if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
        query := dict->FilterUtils.parseFilterDict
        dict
      })
    }

    let reset = () => {
      let dict = Dict.make()
      setfilterDict(_ => dict)
      query := dict->FilterUtils.parseFilterDict
      clearSessionStorage()
    }

    let removeKeys = (arr: array<string>) => {
      setfilterDict(prev => {
        let updatedDict =
          prev->Dict.toArray->Array.copy->Dict.fromArray->DictionaryUtils.deleteKeys(arr)
        let dict = if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
        query := dict->FilterUtils.parseFilterDict
        dict
      })
      clearSessionStorage()
    }
    {
      query: query.contents,
      filterValue: filterDict,
      updateExistingKeys: updateFilter,
      removeKeys,
      filterKeys,
      setfilterKeys,
      filterValueJson: filterDict
      ->Dict.toArray
      ->Array.map(item => {
        let (key, value) = item
        (key, value->UrlFetchUtils.getFilterValue)
      })
      ->Dict.fromArray,
      reset,
    }
  }, (filterDict, setfilterDict, filterKeys))

  React.useEffect0(() => {
    switch sessionStorage.getItem(. index)->Nullable.toOption {
    | Some(value) => value->FilterUtils.parseFilterString->updateFilter.updateExistingKeys
    | None => ()
    }
    let keys = []
    switch sessionStorage.getItem(. `${index}-list`)->Nullable.toOption {
    | Some(value) =>
      switch value->JSON.parseExn->JSON.Decode.array {
      | Some(arr) =>
        arr->Array.forEach(item => {
          switch item->JSON.Decode.string {
          | Some(str) => keys->Array.push(str)->ignore
          | _ => ()
          }
        })
        setfilterKeys(_ => keys)
      | None => ()
      }
    | None => ()
    }

    Some(() => clearSessionStorage())
  })

  React.useEffect2(() => {
    if !(query.contents->String.length < 1) {
      sessionStorage.setItem(. index, query.contents)
    }

    sessionStorage.setItem(.
      `${index}-list`,
      filterKeys->Array.map(item => item->JSON.Encode.string)->JSON.Encode.array->JSON.stringify,
    )

    None
  }, (query.contents, filterKeys))

  <Provider value={updateFilter}> children </Provider>
}

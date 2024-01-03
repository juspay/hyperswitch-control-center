type sessionStorage = {
  getItem: (. string) => Js.Nullable.t<string>,
  setItem: (. string, string) => unit,
  removeItem: (. string) => unit,
}

@val external sessionStorage: sessionStorage = "sessionStorage"

type filterUpdater = {
  query: string,
  filterValue: Js.Dict.t<string>,
  updateExistingKeys: Js.Dict.t<string> => unit,
  removeKeys: array<string> => unit,
  filterValueJson: Js.Dict.t<Js.Json.t>,
  reset: unit => unit,
}

let filterUpdater = {
  query: "",
  filterValue: Js.Dict.empty(),
  updateExistingKeys: _dict => (),
  removeKeys: _arr => (),
  filterValueJson: Js.Dict.empty(),
  reset: () => (),
}

let filterContext = React.createContext(filterUpdater)

module Provider = {
  let make = React.Context.provider(filterContext)
}

@react.component
let make = (~index: string, ~children, ~disableSessionStorage=false) => {
  open FilterUtils
  open HSwitchUtils
  let query = React.useMemo0(() => {ref("")})
  let searcParamsToDict = query.contents->parseFilterString
  let (filterDict, setfilterDict) = React.useState(_ => searcParamsToDict)

  let updateFilter = React.useMemo2(() => {
    let updateFilter = (dict: Js.Dict.t<string>) => {
      setfilterDict(prev => {
        let prevDictArr =
          prev
          ->Js.Dict.entries
          ->Belt.Array.keepMap(
            item => {
              let (key, value) = item
              switch dict->Js.Dict.get(key) {
              | Some(_) => None
              | None => !(value->isEmptyString) ? Some(item) : None
              }
            },
          )
        let currentDictArr =
          dict
          ->Js.Dict.entries
          ->Js.Array2.filter(
            item => {
              let (_, value) = item
              !(value->isEmptyString)
            },
          )

        let updatedDict = Js.Array2.concat(prevDictArr, currentDictArr)->Js.Dict.fromArray
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
      let dict = Js.Dict.empty()
      setfilterDict(_ => dict)
      query := dict->FilterUtils.parseFilterDict
    }

    let removeKeys = (arr: array<string>) => {
      setfilterDict(prev => {
        let updatedDict =
          prev->Js.Dict.entries->Js.Array2.copy->Js.Dict.fromArray->DictionaryUtils.deleteKeys(arr)
        let dict = if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
        query := dict->FilterUtils.parseFilterDict
        dict
      })
    }
    {
      query: query.contents,
      filterValue: filterDict,
      updateExistingKeys: updateFilter,
      removeKeys,
      filterValueJson: filterDict
      ->Js.Dict.entries
      ->Js.Array2.map(item => {
        let (key, value) = item
        (key, value->UrlFetchUtils.getFilterValue)
      })
      ->Js.Dict.fromArray,
      reset,
    }
  }, (filterDict, setfilterDict))

  React.useEffect0(() => {
    switch sessionStorage.getItem(. index)->Js.Nullable.toOption {
    | Some(value) =>
      !disableSessionStorage
        ? value->FilterUtils.parseFilterString->updateFilter.updateExistingKeys
        : ()
    | None => ()
    }
    None
  })

  React.useEffect1(() => {
    if !(query.contents->Js.String2.length < 1) && !disableSessionStorage {
      sessionStorage.setItem(. index, query.contents)
    }
    None
  }, [query.contents])

  <Provider value={updateFilter}> children </Provider>
}

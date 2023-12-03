type filterUpdater = {
  index: string,
  filterValue: Js.Dict.t<string>,
  updateExistingKeys: Js.Dict.t<string> => unit,
  removeKeys: array<string> => unit,
  filterValueJson: Js.Dict.t<Js.Json.t>,
  reset: unit => unit,
}

let filterUpdater = {
  index: "",
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
let make = (~index, ~children) => {
  open FilterUtils
  let filterString = useFiltersValue(~index)
  let searcParamsToDict = filterString->parseUrl

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
              | None => value !== "" ? Some(item) : None
              }
            },
          )
        let currentDictArr =
          dict
          ->Js.Dict.entries
          ->Js.Array2.filter(
            item => {
              let (_, value) = item
              value !== ""
            },
          )

        let updatedDict = Js.Array2.concat(prevDictArr, currentDictArr)->Js.Dict.fromArray
        if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
      })
    }

    let reset = () => {
      setfilterDict(_ => Js.Dict.empty())
    }

    let removeKeys = (arr: array<string>) => {
      setfilterDict(prev => {
        let updatedDict =
          prev->Js.Dict.entries->Js.Array2.copy->Js.Dict.fromArray->DictionaryUtils.deleteKeys(arr)
        if DictionaryUtils.equalDicts(updatedDict, prev) {
          prev
        } else {
          updatedDict
        }
      })
    }
    {
      index,
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

  <Provider value={updateFilter}> children </Provider>
}

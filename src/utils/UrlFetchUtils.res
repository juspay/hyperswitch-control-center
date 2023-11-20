let getFilterValue = value => {
  if Js.String2.includes(value, "[") {
    let str = Js.String2.slice(~from=1, ~to_=value->Js.String2.length - 1, value)
    let splitArray = Js.String2.split(str, ",")
    let jsonarr = splitArray->Js.Array2.map(val => Js.Json.string(val))
    Js.Json.array(jsonarr)
  } else {
    Js.Json.string(value)
  }
}

let dictToSearchParam = (~dict: Js.Dict.t<string>) => {
  let arrVal = dict->Js.Dict.entries
  let reducedValue = Belt.Array.reduce(arrVal, ("", ""), (acc, value) => {
    let (key, item) = value
    let (keyacc, itemacc) = acc
    (key ++ keyacc, item ++ itemacc)
  })
  let (key, value) = reducedValue
  key ++ value
}

let fetchAndMakeFilter = (arrFilterKeys: array<string>, ~dict) => {
  let arrVal =
    dict
    ->Js.Dict.entries
    ->Belt.Array.keepMap(item => {
      let (key, _) = item
      arrFilterKeys->Js.Array2.includes(key) ? Some(item) : None
    })

  (arrVal->Js.Dict.fromArray, dictToSearchParam(~dict=arrVal->Js.Dict.fromArray))
}
let useFetchFilterFromUrl = () => {
  let url = RescriptReactRouter.useUrl()
  let (state, setState) = React.useState(_ => Js.Dict.empty())
  let searchParams = url.search->Js.Global.decodeURI
  //UPDATE need to handle the dict case directly here i we will be making local state here
  let updateFetchedFilters = (setState, updatedValue: Js.Dict.t<string>) => {
    setState(prev => {
      let changedValues =
        updatedValue
        ->Js.Dict.entries
        ->Belt.Array.keepMap(entries => {
          let (key, updatedValue) = entries
          let previousValue = prev->Js.Dict.get(key)->Belt.Option.getWithDefault("")
          if updatedValue !== previousValue {
            Some("")
          } else {
            None
          }
        })

      let updatedKeys = updatedValue->Js.Dict.keys
      let prevKeys = prev->Js.Dict.keys
      // key can be added which is been handled by above case and key is removed
      // if we have item in updated key then remove it from prev key
      // if any item is still present in the remainingPrevKeys then update is been changed
      // either the keys is removed or either it is updated
      let remainingPrevKeys = prevKeys->Belt.Array.keepMap(item => {
        updatedKeys->Js.Array2.includes(item) ? None : Some(item)
      })
      changedValues->Js.Array2.length > 0 || remainingPrevKeys->Js.Array2.length > 0
        ? updatedValue
        : prev
    })
  }

  let updateValue =
    searchParams
    ->Js.String2.split("&")
    ->Belt.Array.keepMap(item => {
      let arr = Js.String.split("=", item)
      let (key, value) = (
        arr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        arr->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
      )
      Some((key, value))
    })
    ->Js.Dict.fromArray

  React.useEffect1(() => {
    updateFetchedFilters(setState, updateValue)
    None
  }, [searchParams])

  fetchAndMakeFilter(~dict=state)
}

let useFiltersObject = () => {
  open HyperswitchAtom
  filtersAtom
  ->Recoil.useRecoilValueFromAtom
  ->LogicUtils.safeParse
  ->Js.Json.decodeObject
  ->Belt.Option.getWithDefault(Js.Dict.empty())
}

let useFiltersValue = (~index) => {
  open LogicUtils
  open HyperswitchAtom
  filtersAtom
  ->Recoil.useRecoilValueFromAtom
  ->safeParse
  ->Js.Json.decodeObject
  ->Belt.Option.getWithDefault(Js.Dict.empty())
  ->Js.Dict.get(index)
  ->Belt.Option.getWithDefault(""->Js.Json.string)
  ->getStringFromJson("")
}

let useAddFilters = (~index) => {
  open HyperswitchAtom
  let filters = useFiltersObject()
  let setFilters = filtersAtom->Recoil.useSetRecoilState

  value => {
    filters->Js.Dict.set(index, value->Js.Json.string)
    setFilters(._ => filters->Js.Json.object_->Js.Json.stringify)
  }
}

let useUpdateFilterObject = (~index: string) => {
  let filters = useFiltersValue(~index)
  let setFilters = useAddFilters(~index)

  let updateFilter = (~dict: Js.Dict.t<string>) => {
    let currentSearchParamsDict =
      filters
      ->Js.Global.decodeURI
      ->Js.String2.split("&")
      ->Belt.Array.keepMap(str => {
        let arr = str->Js.String2.split("=")
        let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
        let val = arr->Belt.Array.sliceToEnd(1)->Js.Array2.joinWith("=")
        key === "" || val === "" ? None : Some((key, val))
      })
      ->Js.Dict.fromArray

    let searchParam =
      dict
      ->Js.Dict.entries
      ->Js.Array2.map(item => {
        let (key, value) = item
        `${key}=${value}`
      })
      ->Js.Array2.joinWith("&")

    if !DictionaryUtils.equalDicts(currentSearchParamsDict, dict) {
      setFilters(searchParam)
    }
  }
  updateFilter
}

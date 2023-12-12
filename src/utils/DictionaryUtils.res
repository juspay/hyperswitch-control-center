let deleteKey = (dictionary: Js.Dict.t<'a>, key: string) => {
  dictionary
  ->Js.Dict.entries
  ->Belt.Array.keepMap(entry => {
    let (filterKey, _) = entry
    key !== filterKey ? Some(entry) : None
  })
  ->Js.Dict.fromArray
}

let deleteKeys = (dictionary: Js.Dict.t<'a>, keys: array<string>) => {
  let updatedDict =
    dictionary
    ->Js.Dict.entries
    ->Belt.Array.keepMap(entry => {
      let (filterKey, _) = entry
      keys->Js.Array2.includes(filterKey) ? None : Some(entry)
    })
    ->Js.Dict.fromArray

  updatedDict
}

let appnedDataToKey = (dict, key, value) => {
  let updatedValue = switch dict->Js.Dict.get(key) {
  | Some(val) => Belt.Array.concat(val, [value])
  | None => [value]
  }
  dict->Js.Dict.set(key, updatedValue)
}

let mergeDicts = (arrDict: array<Js.Dict.t<'a>>) => {
  arrDict->Js.Array2.reduce((acc, dict) => {
    acc->Js.Array2.concat(dict->Js.Dict.entries)
  }, [])->Js.Dict.fromArray
}

let equalDicts = (dictionary1, dictionary2) => {
  // if it return nothing means both are same
  dictionary1
  ->Js.Dict.entries
  ->Js.Array2.find(item => {
    let (key, value) = item
    dictionary2->Js.Dict.get(key) !== Some(value)
  })
  ->Belt.Option.isNone &&
    dictionary2
    ->Js.Dict.entries
    ->Js.Array2.find(item => {
      let (key, value) = item
      dictionary1->Js.Dict.get(key) !== Some(value)
    })
    ->Belt.Option.isNone
}

let checkEqualJsonDicts = (~checkKeys, ~ignoreKeys, dictionary1, dictionary2) => {
  let dictionary1 = dictionary1->Js.Json.object_->JsonFlattenUtils.flattenObject(false)
  let dictionary2 = dictionary2->Js.Json.object_->JsonFlattenUtils.flattenObject(false)

  dictionary1
  ->Js.Dict.entries
  ->Js.Array2.find(item => {
    let (key, value) = item
    if (
      (checkKeys->Js.Array2.includes(key) || checkKeys->Js.Array2.length === 0) &&
        !(ignoreKeys->Js.Array2.includes(key))
    ) {
      switch value->Js.Json.classify {
      | JSONArray(array) => {
          let arr1 = array->LogicUtils.getStrArrayFromJsonArray
          let arr2 = dictionary2->LogicUtils.getStrArrayFromDict(key, [])
          !LogicUtils.isEqualStringArr(arr1, arr2)
        }

      | JSONString(string) => string !== dictionary2->LogicUtils.getString(key, "")
      | _ => dictionary2->LogicUtils.getJsonObjectFromDict(key) !== value
      }
    } else {
      false
    }
  })
  ->Belt.Option.isNone &&
    dictionary2
    ->Js.Dict.entries
    ->Js.Array2.find(item => {
      let (key, value) = item
      if checkKeys->Js.Array2.includes(key) && !(ignoreKeys->Js.Array2.includes(key)) {
        switch value->Js.Json.classify {
        | JSONArray(array) => {
            let arr1 = array->LogicUtils.getStrArrayFromJsonArray
            let arr2 = dictionary1->LogicUtils.getStrArrayFromDict(key, [])
            !LogicUtils.isEqualStringArr(arr1, arr2)
          }

        | JSONString(string) => string !== dictionary1->LogicUtils.getString(key, "")
        | _ => dictionary1->LogicUtils.getJsonObjectFromDict(key) !== value
        }
      } else {
        false
      }
    })
    ->Belt.Option.isNone
}

let copyOfDict = dict => {
  dict->Js.Dict.entries->Js.Array2.copy->Js.Dict.fromArray
}

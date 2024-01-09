let deleteKey = (dictionary: Js.Dict.t<'a>, key: string) => {
  dictionary
  ->Dict.toArray
  ->Belt.Array.keepMap(entry => {
    let (filterKey, _) = entry
    key !== filterKey ? Some(entry) : None
  })
  ->Dict.fromArray
}

let deleteKeys = (dictionary: Js.Dict.t<'a>, keys: array<string>) => {
  let updatedDict =
    dictionary
    ->Dict.toArray
    ->Belt.Array.keepMap(entry => {
      let (filterKey, _) = entry
      keys->Array.includes(filterKey) ? None : Some(entry)
    })
    ->Dict.fromArray

  updatedDict
}

let mergeDicts = (arrDict: array<Js.Dict.t<'a>>) => {
  arrDict
  ->Array.reduce([], (acc, dict) => {
    acc->Array.concat(dict->Dict.toArray)
  })
  ->Dict.fromArray
}

let equalDicts = (dictionary1, dictionary2) => {
  // if it return nothing means both are same
  dictionary1
  ->Dict.toArray
  ->Array.find(item => {
    let (key, value) = item
    dictionary2->Dict.get(key) !== Some(value)
  })
  ->Belt.Option.isNone &&
    dictionary2
    ->Dict.toArray
    ->Array.find(item => {
      let (key, value) = item
      dictionary1->Dict.get(key) !== Some(value)
    })
    ->Belt.Option.isNone
}

let checkEqualJsonDicts = (~checkKeys, ~ignoreKeys, dictionary1, dictionary2) => {
  let dictionary1 = dictionary1->Js.Json.object_->JsonFlattenUtils.flattenObject(false)
  let dictionary2 = dictionary2->Js.Json.object_->JsonFlattenUtils.flattenObject(false)

  dictionary1
  ->Dict.toArray
  ->Array.find(item => {
    let (key, value) = item
    if (
      (checkKeys->Array.includes(key) || checkKeys->Array.length === 0) &&
        !(ignoreKeys->Array.includes(key))
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
    ->Dict.toArray
    ->Array.find(item => {
      let (key, value) = item
      if checkKeys->Array.includes(key) && !(ignoreKeys->Array.includes(key)) {
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
  dict->Dict.toArray->Array.copy->Dict.fromArray
}

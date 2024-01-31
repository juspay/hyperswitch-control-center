let deleteKey = (dictionary: Dict.t<'a>, key: string) => {
  dictionary
  ->Dict.toArray
  ->Belt.Array.keepMap(entry => {
    let (filterKey, _) = entry
    key !== filterKey ? Some(entry) : None
  })
  ->Dict.fromArray
}

let deleteKeys = (dictionary: Dict.t<'a>, keys: array<string>) => {
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

let mergeDicts = (arrDict: array<Dict.t<'a>>) => {
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
  ->Option.isNone &&
    dictionary2
    ->Dict.toArray
    ->Array.find(item => {
      let (key, value) = item
      dictionary1->Dict.get(key) !== Some(value)
    })
    ->Option.isNone
}

let checkEqualJsonDicts = (~checkKeys, ~ignoreKeys, dictionary1, dictionary2) => {
  let dictionary1 = dictionary1->JSON.Encode.object->JsonFlattenUtils.flattenObject(false)
  let dictionary2 = dictionary2->JSON.Encode.object->JsonFlattenUtils.flattenObject(false)

  dictionary1
  ->Dict.toArray
  ->Array.find(item => {
    let (key, value) = item
    if (
      (checkKeys->Array.includes(key) || checkKeys->Array.length === 0) &&
        !(ignoreKeys->Array.includes(key))
    ) {
      switch value->JSON.Classify.classify {
      | Array(array) => {
          let arr1 = array->LogicUtils.getStrArrayFromJsonArray
          let arr2 = dictionary2->LogicUtils.getStrArrayFromDict(key, [])
          !LogicUtils.isEqualStringArr(arr1, arr2)
        }

      | String(string) => string !== dictionary2->LogicUtils.getString(key, "")
      | _ => dictionary2->LogicUtils.getJsonObjectFromDict(key) !== value
      }
    } else {
      false
    }
  })
  ->Option.isNone &&
    dictionary2
    ->Dict.toArray
    ->Array.find(item => {
      let (key, value) = item
      if checkKeys->Array.includes(key) && !(ignoreKeys->Array.includes(key)) {
        switch value->JSON.Classify.classify {
        | Array(array) => {
            let arr1 = array->LogicUtils.getStrArrayFromJsonArray
            let arr2 = dictionary1->LogicUtils.getStrArrayFromDict(key, [])
            !LogicUtils.isEqualStringArr(arr1, arr2)
          }

        | String(string) => string !== dictionary1->LogicUtils.getString(key, "")
        | _ => dictionary1->LogicUtils.getJsonObjectFromDict(key) !== value
        }
      } else {
        false
      }
    })
    ->Option.isNone
}

let copyOfDict = dict => {
  dict->Dict.toArray->Array.copy->Dict.fromArray
}

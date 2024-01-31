let rec flattenObject = (obj, addIndicatorForObject) => {
  let newDict = Dict.make()
  switch obj->JSON.Decode.object {
  | Some(obj) =>
    obj
    ->Dict.toArray
    ->Array.forEach(entry => {
      let (key, value) = entry

      if value->Identity.jsonToNullableJson->Js.Nullable.isNullable {
        Dict.set(newDict, key, value)
      } else {
        switch value->JSON.Decode.object {
        | Some(_valueObj) => {
            if addIndicatorForObject {
              Dict.set(newDict, key, JSON.Encode.object(Dict.make()))
            }

            let flattenedSubObj = flattenObject(value, addIndicatorForObject)

            flattenedSubObj
            ->Dict.toArray
            ->Array.forEach(subEntry => {
              let (subKey, subValue) = subEntry
              Dict.set(newDict, `${key}.${subKey}`, subValue)
            })
          }

        | None => Dict.set(newDict, key, value)
        }
      }
    })
  | _ => ()
  }
  newDict
}

let rec setNested = (dict, keys, value) => {
  if keys->Array.length === 0 {
    ()
  } else if keys->Array.length === 1 {
    Dict.set(dict, keys[0]->Option.getOr(""), value)
  } else {
    let key = keys[0]->Option.getOr("")
    let subDict = switch Dict.get(dict, key) {
    | Some(json) =>
      switch json->JSON.Decode.object {
      | Some(obj) => obj
      | None => dict
      }
    | None => {
        let subDict = Dict.make()
        Dict.set(dict, key, subDict->JSON.Encode.object)
        subDict
      }
    }
    let remainingKeys = keys->Js.Array2.sliceFrom(1)
    setNested(subDict, remainingKeys, value)
  }
}

let unflattenObject = obj => {
  let newDict = Dict.make()

  switch obj->JSON.Decode.object {
  | Some(dict) =>
    dict
    ->Dict.toArray
    ->Array.forEach(entry => {
      let (key, value) = entry
      setNested(newDict, key->String.split("."), value)
    })
  | None => ()
  }
  newDict
}

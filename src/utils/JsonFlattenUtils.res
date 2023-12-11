let rec flattenObject = (obj, addIndicatorForObject) => {
  let newDict = Js.Dict.empty()
  switch obj->Js.Json.decodeObject {
  | Some(obj) =>
    obj
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry

      if value->Identity.jsonToNullableJson->Js.Nullable.isNullable {
        Js.Dict.set(newDict, key, value)
      } else {
        switch value->Js.Json.decodeObject {
        | Some(_valueObj) => {
            if addIndicatorForObject {
              Js.Dict.set(newDict, key, Js.Json.object_(Js.Dict.empty()))
            }

            let flattenedSubObj = flattenObject(value, addIndicatorForObject)

            flattenedSubObj
            ->Js.Dict.entries
            ->Js.Array2.forEach(subEntry => {
              let (subKey, subValue) = subEntry
              Js.Dict.set(newDict, `${key}.${subKey}`, subValue)
            })
          }

        | None => Js.Dict.set(newDict, key, value)
        }
      }
    })
  | _ => ()
  }
  newDict
}

let rec setNested = (dict, keys, value) => {
  if keys->Js.Array.length === 0 {
    ()
  } else if keys->Js.Array.length === 1 {
    Js.Dict.set(dict, keys[0]->Belt.Option.getWithDefault(""), value)
  } else {
    let key = keys[0]->Belt.Option.getWithDefault("")
    let subDict = switch Js.Dict.get(dict, key) {
    | Some(json) =>
      switch json->Js.Json.decodeObject {
      | Some(obj) => obj
      | None => dict
      }
    | None => {
        let subDict = Js.Dict.empty()
        Js.Dict.set(dict, key, subDict->Js.Json.object_)
        subDict
      }
    }
    let remainingKeys = keys->Js.Array2.sliceFrom(1)
    setNested(subDict, remainingKeys, value)
  }
}

let unflattenObject = obj => {
  let newDict = Js.Dict.empty()

  switch obj->Js.Json.decodeObject {
  | Some(dict) =>
    dict
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry
      setNested(newDict, key->Js.String2.split("."), value)
    })
  | None => ()
  }
  newDict
}

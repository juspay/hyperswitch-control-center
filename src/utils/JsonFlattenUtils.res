open LogicUtils

external toNullable: Js.Json.t => Js.Nullable.t<Js.Json.t> = "%identity"

let rec flattenObject = (obj, addIndicatorForObject) => {
  let newDict = Js.Dict.empty()
  switch obj->Js.Json.decodeObject {
  | Some(obj) =>
    obj
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry

      if value->toNullable->Js.Nullable.isNullable {
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

let rec flattenObjectWithStringifiedJson = (
  obj,
  addIndicatorForObject,
  keepParent,
  includeKeys,
) => {
  let newDict = Js.Dict.empty()
  switch obj->Js.Json.decodeObject {
  | Some(obj) =>
    obj
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry

      if value->toNullable->Js.Nullable.isNullable {
        Js.Dict.set(newDict, key, value)
      } else if includeKeys->Js.Array2.includes(key)->not {
        Js.Dict.set(newDict, key, value)
      } else {
        switch value
        ->Js.Json.decodeString
        ->Belt.Option.getWithDefault("")
        ->LogicUtils.safeParse
        ->Js.Json.decodeObject {
        | Some(_valueObj) => {
            if addIndicatorForObject {
              Js.Dict.set(newDict, key, Js.Json.object_(Js.Dict.empty()))
            }

            let flattenedSubObj = flattenObjectWithStringifiedJson(
              value->Js.Json.decodeString->Belt.Option.getWithDefault("")->LogicUtils.safeParse,
              addIndicatorForObject,
              keepParent,
              includeKeys,
            )

            flattenedSubObj
            ->Js.Dict.entries
            ->Js.Array2.forEach(subEntry => {
              let (subKey, subValue) = subEntry
              let keyN = keepParent ? `${key}.${subKey}` : subKey
              Js.Dict.set(newDict, keyN, subValue)
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
let rec flatten = (obj, addIndicatorForObject) => {
  let newDict = Js.Dict.empty()
  switch obj->Js.Json.classify {
  | JSONObject(obj) =>
    obj
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry

      if value->toNullable->Js.Nullable.isNullable {
        Js.Dict.set(newDict, key, value)
      } else {
        switch value->Js.Json.classify {
        | JSONObject(_valueObjDict) => {
            if addIndicatorForObject {
              Js.Dict.set(newDict, key, Js.Json.object_(Js.Dict.empty()))
            }

            let flattenedSubObj = flatten(value, addIndicatorForObject)

            flattenedSubObj
            ->Js.Dict.entries
            ->Js.Array2.forEach(subEntry => {
              let (subKey, subValue) = subEntry
              Js.Dict.set(newDict, `${key}.${subKey}`, subValue)
            })
          }

        | JSONArray(dictArray) => {
            let stringArray = []
            let arrayArray = []
            dictArray->Js.Array2.forEachi((item, index) => {
              switch item->Js.Json.classify {
              | JSONString(_str) =>
                let _ = stringArray->Js.Array2.push(item)
              | JSONObject(_obj) => {
                  let flattenedSubObj = flatten(item, addIndicatorForObject)
                  flattenedSubObj
                  ->Js.Dict.entries
                  ->Js.Array2.forEach(
                    subEntry => {
                      let (subKey, subValue) = subEntry
                      Js.Dict.set(newDict, `${key}[${index->string_of_int}].${subKey}`, subValue)
                    },
                  )
                }

              | _ =>
                let _ = arrayArray->Js.Array2.push(item)
              }
            })
            if stringArray->Js.Array2.length > 0 {
              Js.Dict.set(newDict, key, stringArray->Js.Json.array)
            }
            if arrayArray->Js.Array2.length > 0 {
              Js.Dict.set(newDict, key, arrayArray->Js.Json.array)
            }
          }

        | _ => Js.Dict.set(newDict, key, value)
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

let rec setNestedArr = (dict, keys, value) => {
  if keys->Js.Array.length === 0 {
    ()
  } else if keys->Js.Array.length === 1 {
    if keys[0]->Belt.Option.getWithDefault("")->Js.String2.includes("[") {
      let key =
        (
          keys[0]->Belt.Option.getWithDefault("")->Js.String2.split("[")
        )[0]->Belt.Option.getWithDefault("")
      let indx =
        Js.String2.substring(
          keys[0]->Belt.Option.getWithDefault(""),
          ~from=keys[0]->Belt.Option.getWithDefault("")->Js.String2.indexOf("[") + 1,
          ~to_=keys[0]->Belt.Option.getWithDefault("")->Js.String2.indexOf("]"),
        )->getIntFromString(0)
      let valArr = switch Js.Dict.get(dict->getDictFromJsonObject, key) {
      | Some(jsonArray) =>
        switch jsonArray->Js.Json.decodeArray {
        | Some(arr) => {
            while arr->Js.Array2.length < indx {
              arr->Js.Array2.push(Js.Json.null)->ignore
            }
            arr
          }

        | None => []
        }
      | None => {
          let arr = []
          while arr->Js.Array2.length < indx {
            arr->Js.Array2.push(Js.Json.null)->ignore
          }

          arr
        }
      }

      Js.Dict.set(
        dict->getDictFromJsonObject,
        key,
        valArr->Js.Array2.concat([value])->Js.Json.array,
      )
    } else {
      Js.Dict.set(dict->getDictFromJsonObject, keys[0]->Belt.Option.getWithDefault(""), value)
    }
  } else if keys[0]->Belt.Option.getWithDefault("")->Js.String2.includes("[") {
    let key =
      (
        keys[0]->Belt.Option.getWithDefault("")->Js.String2.split("[")
      )[0]->Belt.Option.getWithDefault("")
    let indx =
      Js.String2.substring(
        keys[0]->Belt.Option.getWithDefault(""),
        ~from=keys[0]->Belt.Option.getWithDefault("")->Js.String2.indexOf("[") + 1,
        ~to_=keys[0]->Belt.Option.getWithDefault("")->Js.String2.indexOf("]"),
      )->getIntFromString(0)
    let subDict = switch Js.Dict.get(dict->getDictFromJsonObject, key) {
    | Some(jsonArray) =>
      switch jsonArray->Js.Json.decodeArray {
      | Some(arr) => {
          while arr->Js.Array2.length < indx + 1 {
            arr->Js.Array2.push(Js.Json.null)->ignore
          }
          arr[indx]->Belt.Option.getWithDefault(Js.Json.null)
        }

      | None => dict
      }
    | None => {
        let arr = []
        while arr->Js.Array2.length < indx + 1 {
          arr->Js.Array2.push(Js.Json.null)->ignore
        }
        Js.Dict.set(dict->getDictFromJsonObject, key, arr->Js.Json.array)
        arr[indx]->Belt.Option.getWithDefault(Js.Json.null)
      }
    }
    let remainingKeys = keys->Js.Array2.sliceFrom(1)
    setNestedArr(subDict, remainingKeys, value)
  } else {
    let key = keys[0]->Belt.Option.getWithDefault("")
    let subDict = switch Js.Dict.get(dict->getDictFromJsonObject, key) {
    | Some(json) =>
      switch json->Js.Json.decodeObject {
      | Some(obj) => obj->Js.Json.object_
      | None => dict
      }
    | None => {
        let subDict = Js.Dict.empty()
        Js.Dict.set(dict->getDictFromJsonObject, key, subDict->Js.Json.object_)
        subDict->Js.Json.object_
      }
    }
    let remainingKeys = keys->Js.Array2.sliceFrom(1)
    setNestedArr(subDict, remainingKeys, value)
  }
}

let unflatten = obj => {
  let newDict = Js.Dict.empty()

  switch obj->Js.Json.decodeObject {
  | Some(dict) =>
    dict
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry
      setNestedArr(newDict->Js.Json.object_, key->Js.String2.split("."), value)
    })
  | None => ()
  }
  newDict
}

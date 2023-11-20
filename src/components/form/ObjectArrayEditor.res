let isMatchingDict = (subJson, objectSelector) => {
  switch subJson->Js.Json.decodeObject {
  | Some(dict) =>
    objectSelector
    ->Js.Dict.entries
    ->Js.Array2.every(entry => {
      let (expectedKey, expectedValue) = entry
      let currentValue =
        dict->Js.Dict.get(expectedKey)->Belt.Option.getWithDefault(""->Js.Json.string)
      expectedValue->Js.Json.stringify === currentValue->Js.Json.stringify
    })
  | None => false
  }
}

let getOptionalMatchingDict = (jsonArray, objectSelector) => {
  Js.Array2.find(jsonArray, subJson => isMatchingDict(subJson, objectSelector))
}

external eventToJson: ReactEvent.Form.t => Js.Json.t = "%identity"

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~objectSelector: Js.Dict.t<Js.Json.t>,
  ~modifierKey,
  ~placeholder,
  ~customInput,
  ~otherKeyValsToAdd: Js.Dict.t<Js.Json.t>=Js.Dict.empty(),
  ~inputParse: option<(. ~value: Js.Json.t, ~name: 'a) => Js.Json.t>=?,
  ~defaultItemValue=Js.Json.null,
) => {
  let jsonInput: ReactFinalForm.fieldRenderPropsCustomInput<Js.Json.t> =
    input->ReactFinalForm.toTypedField

  let subInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "",
    onChange: ev => {
      let parsedNewValue = try {
        let newValue = ReactEvent.Form.target(ev)["value"]
        switch inputParse {
        | Some(parseFn) => parseFn(. ~value=newValue, ~name="")
        | None => newValue
        }
      } catch {
      | _ => {
          let newValue = ev->eventToJson
          switch inputParse {
          | Some(parseFn) => parseFn(. ~value=newValue, ~name="")
          | None => newValue
          }
        }
      }

      let isEmptyValue = switch parsedNewValue->Js.Json.classify {
      | JSONString(str) => str === ""
      | JSONNull => true
      | JSONFalse => true
      | JSONArray(arr) => Js.Array2.length(arr) === 0
      | _ => false
      }

      switch input.value->Js.Json.decodeArray {
      | Some(jsonArray) =>
        switch getOptionalMatchingDict(jsonArray, objectSelector) {
        | Some(_matchingObject) => {
            let newArrayVal = if isEmptyValue {
              Js.Array2.filter(jsonArray, subJson => {
                if isMatchingDict(subJson, objectSelector) {
                  subJson->Js.Json.decodeObject->Js.Option.isNone
                } else {
                  true
                }
              })
            } else {
              Js.Array2.map(jsonArray, subJson => {
                if isMatchingDict(subJson, objectSelector) {
                  switch subJson->Js.Json.decodeObject {
                  | Some(matchingSubDict) => {
                      Js.Dict.set(matchingSubDict, modifierKey, parsedNewValue)
                      matchingSubDict->Js.Json.object_
                    }

                  | None => subJson
                  }
                } else {
                  subJson
                }
              })
            }

            jsonInput.onChange(newArrayVal->Js.Json.array)
          }

        | None =>
          if !isEmptyValue {
            let newDict = {
              Js.Array2.concat([(modifierKey, parsedNewValue)], otherKeyValsToAdd->Js.Dict.entries)
              ->Js.Dict.fromArray
              ->Js.Json.object_
            }
            let newArrayVal = Js.Array2.concat([newDict], jsonArray)

            jsonInput.onChange(newArrayVal->Js.Json.array)
          }
        }
      | None => ()
      }
    },
    onBlur: _ev => (),
    onFocus: _ev => (),
    checked: false,
    value: {
      input.value
      ->Js.Json.decodeArray
      ->Belt.Option.flatMap(val => getOptionalMatchingDict(val, objectSelector))
      ->Belt.Option.flatMap(Js.Json.decodeObject)
      ->Belt.Option.flatMap(dict => Js.Dict.get(dict, modifierKey))
      ->Belt.Option.getWithDefault(defaultItemValue)
    },
  }
  customInput(~input=subInput, ~placeholder)
}

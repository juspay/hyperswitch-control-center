module CustomViewSection = {
  external formEventToInt: ReactEvent.Form.t => int = "%identity"
  external formEventToStrArr: ReactEvent.Form.t => array<string> = "%identity"
  external arrToFormEvent: array<'a> => ReactEvent.Form.t = "%identity"
  external jsonArrToa: array<Js.Json.t> => array<'a> = "%identity"

  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~getDefaultObj,
    ~itemToObjMap,
    ~renderCard,
    ~options,
    ~keyExtractor,
    ~allowMultiSelect,
    ~label,
  ) => {
    let value = input.value
    let onChange = input.onChange
    let valueArr = React.useMemo1(() => {
      switch value->Js.Json.decodeArray {
      | Some(arr) => arr->itemToObjMap
      | None => []
      }
    }, [value])

    let selectBoxInput = React.useMemo3(() => {
      let input: ReactFinalForm.fieldRenderPropsInput = {
        name: "string",
        onBlur: _ => (),
        onFocus: _ => (),
        value: !allowMultiSelect
          ? valueArr->Js.Array2.length->Js.Int.toString->Js.Json.string
          : valueArr
            ->Js.Array2.map(jsonObj => {
              keyExtractor(jsonObj)->Js.Json.string
            })
            ->Js.Json.array,
        checked: true,
        onChange: ev => {
          let valueArrReversed = switch value->Js.Json.decodeArray {
          | Some(arr) => arr->itemToObjMap->Js.Array2.reverseInPlace
          | None => []
          }
          let finalArr = []

          if !allowMultiSelect {
            for _ in 1 to ev->formEventToInt {
              Js.Array2.pop(valueArrReversed)
              ->Belt.Option.getWithDefault(getDefaultObj(ev->Identity.formReactEventToString))
              ->Js.Array.push(finalArr)
              ->ignore
            }
          } else {
            let evArr = ev->formEventToStrArr
            for i in 0 to evArr->Js.Array2.length - 1 {
              valueArrReversed
              ->Js.Array2.find(x => keyExtractor(x) == evArr[i]->Belt.Option.getWithDefault(""))
              ->Belt.Option.getWithDefault(getDefaultObj(evArr[i]->Belt.Option.getWithDefault("")))
              ->Js.Array.push(finalArr)
              ->ignore
            }
          }
          onChange(finalArr->arrToFormEvent)
        },
      }
      input
    }, (valueArr, value, onChange))

    <div>
      <FormRenderer.FieldWrapper label isRequired=false>
        <SelectBox input=selectBoxInput options buttonText=label allowMultiSelect />
      </FormRenderer.FieldWrapper>
      {valueArr
      ->Js.Array2.mapi((_, i) => {
        let indexStr = i->Js.Int.toString
        <div key=indexStr> {renderCard(indexStr, selectBoxInput.value)} </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (
  ~name,
  ~getDefaultObj,
  ~renderCard,
  ~itemToObjMap,
  ~options,
  ~keyExtractor,
  ~allowMultiSelect,
  ~label,
) => {
  <ReactFinalForm.Field
    name
    render={({input}) => {
      <CustomViewSection
        input={input}
        getDefaultObj
        itemToObjMap
        renderCard
        options
        keyExtractor
        allowMultiSelect
        label
      />
    }}
  />
}

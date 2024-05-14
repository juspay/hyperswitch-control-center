@send
external focus: (Dom.element, unit) => unit = "focus"
module InputFieldForOtp = {
  @react.component
  let make = (~inputRef, ~value, ~index, ~handleChange, ~handleFocus) => {
    let inputClass = `text-center h-full w-full border border-jp-2-light-gray-600 rounded-lg outline-none focus:border-blue-500 focus:shadow-focusBoxShadow text-2xl overflow-hidden`

    let onChange = ev => {
      let currValue = {ev->ReactEvent.Form.target}["value"]
      if %re("/^[0-9]+$/")->Js.Re.test_(currValue) || currValue === "" {
        let newValue =
          value->String.slice(~start=0, ~end=index) ++
          currValue ++
          value->String.sliceToEnd(~start=index + 1)
        handleChange(newValue)
      }
    }
    let subVal = value->String.slice(~start=index, ~end=index + 1)

    let handleKeyDown = ev => {
      let key = ev->ReactEvent.Keyboard.keyCode
      if key === 8 || key === 46 {
        if value->String.length === index {
          handleChange(value->String.slice(~start=0, ~end=index - 1))
        }
      }
    }

    <input
      ref={inputRef->ReactDOM.Ref.domRef}
      value={subVal}
      className=inputClass
      onChange
      onFocus={handleFocus}
      onKeyDown={handleKeyDown}
      autoComplete="off"
    />
  }
}
@react.component
let make = (~value, ~setValue) => {
  let input1Ref = React.useRef(Nullable.null)
  let input2Ref = React.useRef(Nullable.null)
  let input3Ref = React.useRef(Nullable.null)
  let input4Ref = React.useRef(Nullable.null)
  let input5Ref = React.useRef(Nullable.null)
  let input6Ref = React.useRef(Nullable.null)

  let inputRefArray = [input1Ref, input2Ref, input3Ref, input4Ref, input5Ref, input6Ref]

  let handleChange = str => {
    setValue(_ => str->String.slice(~start=0, ~end=6))
  }

  let handleFocus = _val => {
    let indexToFocus = Math.Int.min(5, value->String.length)

    let elementToFocus = (inputRefArray[indexToFocus]->Option.getOr(input1Ref)).current

    switch elementToFocus->Nullable.toOption {
    | Some(elem) => elem->focus()
    | None => ()
    }
  }

  React.useEffect1(() => {
    let indexToFocus = Math.Int.min(5, value->String.length)

    let elementToFocus = (inputRefArray[indexToFocus]->Option.getOr(input1Ref)).current

    switch elementToFocus->Nullable.toOption {
    | Some(elem) => elem->focus()
    | None => ()
    }
    None
  }, [value->String.length])

  <div className="flex justify-center relative ">
    {inputRefArray
    ->Array.mapWithIndex((ref, index) =>
      <div className="w-16 h-16">
        <InputFieldForOtp inputRef={ref} value handleChange index handleFocus />
      </div>
    )
    ->React.array}
  </div>
}

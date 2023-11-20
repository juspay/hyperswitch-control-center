module SingleInput = {
  @react.component
  let make = (
    ~value,
    ~index,
    ~onChange,
    ~onFocus,
    ~inputRef,
    ~inputClass="flex flex-col w-full h-full text-center text-xl bg-white dark:bg-jp-gray-950",
  ) => {
    let subVal = value->Js.String2.slice(~from=index, ~to_=index + 1)
    let handleChange = ev => {
      let currValue = {ev->ReactEvent.Form.target}["value"]

      if %re("/^[0-9]+$/")->Js.Re.test_(currValue) || currValue === "" {
        let newVal =
          value->Js.String2.slice(~from=0, ~to_=index) ++
          {ev->ReactEvent.Form.target}["value"] ++
          value->Js.String2.sliceToEnd(~from=index + 1)
        onChange(newVal)
      }
    }

    let handleFocus = _ev => {
      onFocus(index)
    }

    let handleKeyDown = ev => {
      let key = ev->ReactEvent.Keyboard.keyCode
      if key === 8 || key === 46 {
        if value->Js.String2.length === index {
          onChange(value->Js.String2.slice(~from=0, ~to_=index - 1))
        }
      }
    }

    <input
      className=inputClass
      ref={inputRef->ReactDOM.Ref.domRef}
      value={subVal}
      onChange={handleChange}
      onFocus={handleFocus}
      onKeyDown={handleKeyDown}
      autoComplete="off"
    />
  }
}

@send
external focus: (Dom.element, unit) => unit = "focus"

@react.component
let make = (
  ~value: string,
  ~setValue,
  ~inputSize=20,
  ~widthSize=?,
  ~borderClass="border border-grey",
  ~inputClass="flex justify-center items-center w-full text-sm text-black dark:text-white",
  ~singleInputCustomClass="flex flex-col w-full h-full text-center text-xl bg-white dark:bg-jp-gray-950",
) => {
  let inputSize = inputSize->Belt.Int.toString
  let handleChange = str => {
    setValue(_ => Js.String2.slice(str, ~from=0, ~to_=6))
  }

  let widthSize = switch widthSize {
  | Some(width) => width->Belt.Float.toString
  | None => inputSize
  }

  let input1Ref = React.useRef(Js.Nullable.null)
  let input2Ref = React.useRef(Js.Nullable.null)
  let input3Ref = React.useRef(Js.Nullable.null)
  let input4Ref = React.useRef(Js.Nullable.null)
  let input5Ref = React.useRef(Js.Nullable.null)
  let input6Ref = React.useRef(Js.Nullable.null)

  let inputRefs = React.useRef([input1Ref, input2Ref, input3Ref, input4Ref, input5Ref, input6Ref])

  React.useEffect1(() => {
    let indexToFocus = Js.Math.min_int(5, value->Js.String2.length)
    let refs = inputRefs.current
    let elemToFocus = (refs[indexToFocus]->Belt.Option.getWithDefault(input1Ref)).current
    switch elemToFocus->Js.Nullable.toOption {
    | Some(elem) => elem->focus()
    | None => ()
    }
    None
  }, [value])

  let handleFocus = _index => {
    let indexToFocus = Js.Math.min_int(5, value->Js.String2.length)

    let refs = inputRefs.current

    let elemToFocus = (refs[indexToFocus]->Belt.Option.getWithDefault(input1Ref)).current

    switch elemToFocus->Js.Nullable.toOption {
    | Some(elem) => elem->focus()
    | None => ()
    }
  }

  let inputClass = inputClass
  let paddingClass = "px-10"
  <div className={`flex justify-center ${paddingClass}`}>
    <div className=inputClass>
      {[input1Ref, input2Ref, input3Ref, input4Ref, input5Ref, input6Ref]
      ->Js.Array2.mapi((ref, index) => {
        let className = `flex items-center h-${inputSize} w-${widthSize} ${borderClass}`
        <div key={Belt.Int.toString(index)} className>
          <SingleInput
            value={value}
            inputRef={ref}
            index
            onChange={handleChange}
            onFocus={handleFocus}
            inputClass=singleInputCustomClass
          />
        </div>
      })
      ->React.array}
    </div>
  </div>
}

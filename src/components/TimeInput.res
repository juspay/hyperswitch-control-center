let padNum = num => {
  let str = num->Belt.Int.toString
  if str->Js.String2.length === 1 {
    `0${str}`
  } else {
    str
  }
}
module OptionVals = {
  @react.component
  let make = (~upto=60, ~value, ~onChange, ~isDisabled) => {
    let cursorClass = isDisabled ? "cursor-not-allowed" : ""
    <select
      value={value->Belt.Int.toString}
      onChange
      disabled=isDisabled
      className={`dark:bg-jp-gray-lightgray_background font-medium border border-gray-400 rounded-md self-start ${cursorClass} outline-none`}>
      {Belt.Array.make(upto, 0)
      ->Js.Array2.mapi((_, i) => {
        <option key={Belt.Int.toString(i)} value={Belt.Int.toString(i)}>
          {i->padNum->React.string}
        </option>
      })
      ->React.array}
    </select>
  }
}

external asFormEvent: 'a => ReactEvent.Form.t = "%identity"

@react.component
let make = (
  ~label=?,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~isDisabled=false,
  ~icon="clock",
  ~position="1",
  ~showSeconds=true,
) => {
  let _ = position
  let _ = icon
  let {isFirst, isLast} = React.useContext(ButtonGroupContext.buttonGroupContext)
  let cursorClass = if isDisabled {
    "cursor-not-allowed"
  } else {
    ""
  }
  let roundingClass = if isFirst && isLast {
    "rounded-md"
  } else if isFirst {
    "rounded-l-md"
  } else if isLast {
    "rounded-r-md"
  } else {
    ""
  }
  let value = switch input.value->Js.Json.decodeString {
  | Some(str) => str
  | None => ""
  }
  open Belt.Option
  let arr = value->Js.String2.split(":")
  let hourVal = arr->Belt.Array.get(0)->flatMap(Belt.Int.fromString)->getWithDefault(0)
  let minuteVal = arr->Belt.Array.get(1)->flatMap(Belt.Int.fromString)->getWithDefault(0)
  let secondsVal = arr->Belt.Array.get(2)->flatMap(Belt.Int.fromString)->getWithDefault(0)

  let changeVal = React.useCallback4((index, ev: ReactEvent.Form.t) => {
    let newVal = {ev->ReactEvent.Form.target}["value"]->Belt.Int.fromString->getWithDefault(0)

    let arr = [hourVal, minuteVal, secondsVal]
    Belt.Array.set(arr, index, newVal)->ignore

    arr->Js.Array2.map(padNum)->Js.Array2.joinWith(":")->asFormEvent->input.onChange
  }, (hourVal, minuteVal, secondsVal, input.onChange))
  let onHourChange = React.useCallback1(changeVal(0), [changeVal])
  let onMinuteChange = React.useCallback1(changeVal(1), [changeVal])
  let onSecondsChange = React.useCallback1(changeVal(2), [changeVal])

  let _className = `${roundingClass} ${cursorClass} border border-jp-gray-lightmode_steelgray border-opacity-75 h-8 w-48 font-semibold pl-3 pt-3 pb-3 text-jp-gray-900 text-lg text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-lightgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 `

  <div className="h-8 max-w-min flex flex-row gap-1 text-sm">
    {switch label {
    | Some(str) => <div className="font-semibold mr-1"> {React.string(str)} </div>
    | None => React.null
    }}
    <OptionVals value=hourVal onChange=onHourChange upto=24 isDisabled />
    <div> {React.string(":")} </div>
    <OptionVals value=minuteVal onChange=onMinuteChange isDisabled />
    {if showSeconds {
      <>
        <div> {React.string(":")} </div>
        <OptionVals value=secondsVal onChange=onSecondsChange isDisabled />
      </>
    } else {
      React.null
    }}
  </div>
}

let padNum = num => {
  let str = num->Belt.Int.toString
  if str->String.length === 1 {
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
      ->Array.mapWithIndex((_, i) => {
        <option key={Belt.Int.toString(i)} value={Belt.Int.toString(i)}>
          {i->padNum->React.string}
        </option>
      })
      ->React.array}
    </select>
  }
}

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
  let value = switch input.value->Js.Json.decodeString {
  | Some(str) => str
  | None => ""
  }
  open Belt.Option
  let arr = value->String.split(":")
  let hourVal = arr->Belt.Array.get(0)->flatMap(Belt.Int.fromString)->getWithDefault(0)
  let minuteVal = arr->Belt.Array.get(1)->flatMap(Belt.Int.fromString)->getWithDefault(0)
  let secondsVal = arr->Belt.Array.get(2)->flatMap(Belt.Int.fromString)->getWithDefault(0)

  let changeVal = React.useCallback4((index, ev: ReactEvent.Form.t) => {
    let newVal = {ev->ReactEvent.Form.target}["value"]->Belt.Int.fromString->getWithDefault(0)

    let arr = [hourVal, minuteVal, secondsVal]
    Belt.Array.set(arr, index, newVal)->ignore

    arr->Array.map(padNum)->Array.joinWith(":")->Identity.anyTypeToReactEvent->input.onChange
  }, (hourVal, minuteVal, secondsVal, input.onChange))
  let onHourChange = React.useCallback1(changeVal(0), [changeVal])
  let onMinuteChange = React.useCallback1(changeVal(1), [changeVal])
  let onSecondsChange = React.useCallback1(changeVal(2), [changeVal])

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

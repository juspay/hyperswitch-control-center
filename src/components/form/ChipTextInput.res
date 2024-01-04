@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~type_="text",
  ~inputMode="text",
  ~pattern=?,
  ~autoComplete=?,
  ~min=?,
  ~max=?,
  ~autoFocus=false,
  ~showButton=false,
  ~converterFn=?,
) => {
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
  let className = `w-full border border-jp-gray-lightmode_steelgray border-opacity-75 font-semibold ${type_ !== "range"
      ? "pl-4"
      : ""} h-12 text-jp-gray-900 text-body text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 ${roundingClass} ${cursorClass}`
  let value = switch input.value->Js.Json.classify {
  | JSONString(str) => str
  | JSONNumber(num) => num->Belt.Float.toString
  | _ => ""
  }
  let inputValue = input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  let splitFunction = input => {
    input->Js.String2.split(",")->Array.filter(e => e !== "")->Array.map(e => e->Js.String2.trim)
  }
  let chipArray = splitFunction(inputValue)

  let onChipCloseClick = value => {
    input.onChange(
      inputValue
      ->Js.String2.split(",")
      ->Array.map(Js.String2.trim)
      ->Array.filter(x => x !== value)
      ->Array.joinWith(", ")
      ->Identity.stringToFormReactEvent,
    )
  }
  <div className="flex flex-col items-end justify-center">
    <input
      className
      name={input.name}
      onBlur={input.onBlur}
      onChange={input.onChange}
      onFocus={input.onFocus}
      value
      disabled={isDisabled}
      placeholder={placeholder}
      type_
      inputMode
      ?pattern
      ?autoComplete
      ?min
      ?max
      autoFocus
    />
    {if chipArray->Array.length !== 0 && inputValue !== "" {
      <div className="w-full">
        <Chip values=chipArray showButton onButtonClick=onChipCloseClick ?converterFn />
      </div>
    } else {
      React.null
    }}
  </div>
}

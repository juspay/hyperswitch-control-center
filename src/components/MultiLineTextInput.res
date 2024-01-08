@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled,
  ~rows=?,
  ~cols=?,
  ~customClass="",
  ~leftIcon=?,
  ~readOnly=?,
  ~maxLength=?,
  ~autoFocus=?,
) => {
  let showPopUp = PopUpState.useShowPopUp()
  let cursorClass = if isDisabled {
    "cursor-not-allowed"
  } else {
    ""
  }

  React.useEffect1(() => {
    let val = input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
    if val->String.includes("<script>") || val->String.includes("</script>") {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Script Tags are not allowed`,
        description: React.string(`Input cannot contain <script>, </script> tags`),
        handleConfirm: {text: "OK"},
      })
      input.onChange(
        val
        ->String.replace("<script>", "")
        ->String.replace("</script>", "")
        ->Identity.stringToFormReactEvent,
      )
    }
    None
  }, [input.value])

  let className = `rounded-md border border-jp-gray-lightmode_steelgray border-opacity-75 font-semibold pl-4 pt-3 pb-3 text-jp-gray-900  text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 ${cursorClass} ${customClass}`
  let value = switch input.value->Js.Json.classify {
  | JSONString(str) => str
  | JSONNumber(num) => num->Belt.Float.toString
  | _ => ""
  }

  let textAreaComponent =
    <textarea
      className
      name={input.name}
      onBlur={input.onBlur}
      onChange={input.onChange}
      onFocus={input.onFocus}
      value
      disabled={isDisabled}
      placeholder={placeholder}
      ?autoFocus
      ?maxLength
      ?rows
      ?cols
      ?readOnly
    />

  switch leftIcon {
  | Some(icon) =>
    <div className="flex flex-row md:relative">
      <div className="absolute self-start p-3"> icon </div>
      {textAreaComponent}
    </div>
  | None => textAreaComponent
  }
}

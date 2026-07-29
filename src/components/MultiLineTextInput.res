open Typography

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

  React.useEffect(() => {
    let val = input.value->JSON.Decode.string->Option.getOr("")
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

  let className = `rounded-md border border-nd_br_gray-200 pl-4 pt-3 pb-3 ${body.md.regular} text-nd_gray-700 placeholder-nd_gray-400 hover:border-nd_gray-300 focus:outline-none focus:border-nd_primary_blue-500 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-nd_primary_blue-500 ${cursorClass} ${customClass}`
  let value = switch input.value->JSON.Classify.classify {
  | String(str) => str
  | Number(num) => num->Float.toString
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

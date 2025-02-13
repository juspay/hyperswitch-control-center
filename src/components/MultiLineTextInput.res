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

  let className = `rounded-md border border-jp-gray-steel/75 font-normal pl-4 pt-3 pb-3 text-sm text-gray-800/75 placeholder-gray-800/25 hover:bg-jp-gray-steel/20 hover:border-gray-800/20 focus:text-gray-800/100 focus:outline-hidden focus:border-primary/100 dark:text-gray-50/75 dark:border-gray-800 dark:hover:border-gray-800 dark:hover:bg-gray-950 dark:bg-jp-gray-darkgray_background dark:placeholder-gray-50/25 dark:focus:text-gray-50/100 dark:focus:border-primary ${cursorClass} ${customClass}`
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

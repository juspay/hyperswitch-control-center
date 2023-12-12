module SearchInput = {
  @react.component
  let make = (
    ~input,
    ~isDisabled=false,
    ~type_="text",
    ~inputMode="text",
    ~autoComplete=?,
    ~inputStyle="",
    ~placeholder,
    ~redirectUrl: string,
    ~customStyle="",
    ~widthMatchwithPlaceholderLength=None,
  ) => {
    let urlParam = RescriptReactRouter.useUrl().search
    let handleKeyUp = React.useCallback1(ev => {
      let key = ev->ReactEvent.Keyboard.key
      let keyCode = ev->ReactEvent.Keyboard.keyCode
      if key === "Enter" || keyCode === 13 {
        let value =
          {ev->ReactEvent.Keyboard.target}["value"]
          ->Identity.formReactEventToString
          ->Js.String2.trim
        if value !== "" {
          RescriptReactRouter.push(`${redirectUrl}${value}`)
        }
      }
    }, [urlParam])

    let search_class = "text-gray-400 dark:text-gray-600"
    let iconName = "search"
    let iconClass = search_class

    <TextInput
      input
      placeholder
      isDisabled
      type_
      inputMode
      ?autoComplete
      leftIcon={<Icon size=16 className=iconClass name=iconName />}
      autoFocus=true
      inputStyle
      onKeyUp=handleKeyUp
      customStyle={`!h-10 ${customStyle}`}
      widthMatchwithPlaceholderLength
    />
  }
}

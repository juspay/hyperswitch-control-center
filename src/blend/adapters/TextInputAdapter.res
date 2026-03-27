external ffInputToStringInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  string,
> = "%identity"

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder: string,
  ~description: string="",
  ~isDisabled: bool=false,
  ~type_: string="text",
  ~inputMode: string="text",
  ~pattern: option<string>=?,
  ~autoComplete: option<string>=?,
  ~shouldSubmitForm: bool=true,
  ~min: option<string>=?,
  ~max: option<string>=?,
  ~maxLength: option<int>=?,
  ~autoFocus: bool=false,
  ~leftIcon: option<React.element>=?,
  ~rightIcon: option<React.element>=?,
  ~rightIconOnClick: option<ReactEvent.Mouse.t => unit>=?,
  ~inputStyle: string="",
  ~onKeyUp: option<ReactEvent.Keyboard.t => unit>=?,
  ~customStyle: string="",
  ~customWidth: string="w-full",
  ~readOnly: option<bool>=?,
  ~iconOpacity: string="opacity-30",
  ~customPaddingClass: string="",
  ~widthMatchwithPlaceholderLength=None,
  ~rightIconCustomStyle: string="",
  ~leftIconCustomStyle: string="",
  ~onHoverCss: string="",
  ~onDisabledStyle: string="",
  ~onActiveStyle: string="",
  ~customDarkBackground: string="dark:bg-jp-gray-darkgray_background",
  ~phoneInput: bool=false,
  ~removeValidationCheck: bool=false,
  ~focusOnKeyPress: option<ReactEvent.Keyboard.t => bool>=?,
  ~customDashboardClass: option<string>=?,
) => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let showPopUp = PopUpState.useShowPopUp()
  let (showPassword, setShowPassword) = React.useState(_ => false)
  let inputRef = React.useRef(Nullable.null)
  let {meta} = ReactFinalForm.useField(input.name)

  let isPasswordType = type_ == "password" || type_ == "password_without_icon"
  let effectiveType = if isPasswordType {
    showPassword ? "text" : "password"
  } else {
    type_
  }

  React.useEffect(() => {
    switch widthMatchwithPlaceholderLength {
    | Some(length) =>
      switch inputRef.current->Nullable.toOption {
      | Some(elem) =>
        let size =
          elem
          ->Webapi.Dom.Element.getAttribute("placeholder")
          ->Option.mapOr(length, str => Math.Int.max(length, str->String.length))
          ->Int.toString
        elem->Webapi.Dom.Element.setAttribute("size", size)
      | None => ()
      }
    | None => ()
    }
    None
  }, (inputRef.current, input.name))

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

  React.useEffect(() => {
    switch focusOnKeyPress {
    | Some(func) => {
        let keyDownFn = ev => {
          if func(ev) {
            ev->ReactEvent.Keyboard.preventDefault
            switch inputRef.current->Nullable.toOption {
            | Some(elem) => elem->TextInput.focus
            | None => ()
            }
          }
        }
        Window.addEventListener("keydown", keyDownFn)
        Some(() => Window.removeEventListener("keydown", keyDownFn))
      }
    | None => None
    }
  }, [focusOnKeyPress])

  let value = switch input.value->JSON.Classify.classify {
  | String(str) => str
  | Number(num) => num->Float.toString
  | _ => ""
  }

  let isInValid =
    if !removeValidationCheck {
      if !meta.valid && meta.touched {
        (!(meta.submitError->Js.Nullable.isNullable) && !meta.dirtySinceLastSubmit) ||
          !(meta.error->Js.Nullable.isNullable)
      } else {
        false
      }
    } else {
      false
    }

  let togglePasswordVisibility = _ => {
    setShowPassword(prev => !prev)
  }

  let blendSize = switch customWidth {
  | "w-full" => TextInputBinding.Lg
  | "w-96" => TextInputBinding.Lg
  | "w-80" => TextInputBinding.Md
  | "w-64" => TextInputBinding.Md
  | "w-48" => TextInputBinding.Sm
  | "w-32" => TextInputBinding.Sm
  | _ => TextInputBinding.Lg
  }

  let handleChange = (event: ReactEvent.Form.t) => {
    let newValue = ReactEvent.Form.target(event)["value"]
    switch maxLength {
    | Some(maxLen) =>
      let strValue = newValue->JSON.Decode.string->Option.getOr("")
      if strValue->String.length <= maxLen {
        input.onChange(event)
      }
    | None => input.onChange(event)
    }
  }

  let handleKeyDown = switch onKeyUp {
  | Some(customHandler) =>
    Some(
      (event: ReactEvent.Keyboard.t) => {
        if !shouldSubmitForm {
          let key = ReactEvent.Keyboard.key(event)
          if key === "Enter" {
            ReactEvent.Keyboard.preventDefault(event)
          }
        }
        customHandler(event)
      },
    )
  | None =>
    if !shouldSubmitForm {
      Some(
        (event: ReactEvent.Keyboard.t) => {
          let key = ReactEvent.Keyboard.key(event)
          if key === "Enter" {
            ReactEvent.Keyboard.preventDefault(event)
          }
        },
      )
    } else {
      None
    }
  }

  let rightSlot = switch (rightIcon, isPasswordType, rightIconOnClick) {
  | (Some(icon), false, Some(onClick)) =>
    Some(<div onClick={ev => onClick(ev)} className="cursor-pointer"> icon </div>)
  | (Some(icon), false, None) => Some(icon)
  | (None, true, _) =>
    let eyeIcon = showPassword ? "eye" : "eye-slash"
    Some(
      <div onClick={togglePasswordVisibility} className="cursor-pointer">
        <Icon name=eyeIcon size=15 className="fill-jp-gray-700" />
      </div>,
    )
  | (Some(icon), true, _) => Some(icon)
  | (None, false, _) => None
  }

  let leftSlot = switch leftIcon {
  | Some(icon) => Some(icon)
  | None =>
    if phoneInput {
      Some(<span className="text-jp-gray-700"> {React.string("+91 ")} </span>)
    } else {
      None
    }
  }

  let blendRightSlot = if isPasswordType {
    None
  } else {
    switch (rightIcon, rightIconOnClick) {
    | (Some(icon), Some(onClick)) =>
      Some(<div onClick={ev => onClick(ev)} className="cursor-pointer"> icon </div>)
    | (Some(icon), None) => Some(icon)
    | (None, _) => None
    }
  }

  let blendLeftSlot = if isPasswordType {
    None
  } else {
    leftSlot
  }

  let hintText = if description->LogicUtils.isNonEmptyString {
    Some(description)
  } else {
    None
  }

  if isBlendEnabled {
    <TextInputBinding
      value
      onChange=handleChange
      onBlur=input.onBlur
      onFocus=input.onFocus
      name=input.name
      placeholder
      size=blendSize
      disabled=isDisabled
      ?hintText
      error=isInValid
      leftSlot=?blendLeftSlot
      rightSlot=?blendRightSlot
      type_=effectiveType
      ?pattern
      ?autoComplete
      ?maxLength
      ?min
      ?max
      inputMode
      ?readOnly
      autoFocus
      passwordToggle=isPasswordType
      ?onKeyUp
      onKeyDown=?handleKeyDown
    />
  } else {
    <TextInput
      input
      placeholder
      description
      isDisabled
      type_
      inputMode
      ?pattern
      ?autoComplete
      shouldSubmitForm
      ?min
      ?max
      ?maxLength
      autoFocus
      ?leftIcon
      ?rightIcon
      ?rightIconOnClick
      inputStyle
      ?onKeyUp
      customStyle
      customWidth
      ?readOnly
      iconOpacity
      customPaddingClass
      widthMatchwithPlaceholderLength
      rightIconCustomStyle
      leftIconCustomStyle
      onHoverCss
      onDisabledStyle
      onActiveStyle
      customDarkBackground
      phoneInput
      removeValidationCheck
      ?focusOnKeyPress
      ?customDashboardClass
    />
  }
}

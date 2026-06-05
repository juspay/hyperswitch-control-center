open ReactFinalForm
open LogicUtils

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder: string,
  ~description: string="",
  ~isDisabled: bool=false,
  ~inputType: string="text",
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
  ~customDarkBackground: string="dark:bg-nd_gray-800",
  ~phoneInput: bool=false,
  ~removeValidationCheck: bool=false,
  ~focusOnKeyPress: option<ReactEvent.Keyboard.t => bool>=?,
  ~customDashboardClass: option<string>=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()
  let showPopUp = PopUpState.useShowPopUp()

  let isPasswordType = inputType == "password" || inputType == "password_without_icon"

  React.useEffect(() => {
    let val = input.value->getStringFromJson("")
    if val->String.includes("<script>") || val->String.includes("</script>") {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Script Tags are not allowed`,
        description: React.string(`Input cannot contain <script>, </script> tags`),
        handleConfirm: {text: "OK"},
      })
      input.onChange(
        val
        ->stringReplaceAll("<script>", "")
        ->stringReplaceAll("</script>", "")
        ->Identity.stringToFormReactEvent,
      )
    }
    None
  }, [input.value])

  React.useEffect(() => {
    focusOnKeyPress->Option.map(func => {
      let keyDownFn = ev => {
        if func(ev) {
          ev->ReactEvent.Keyboard.preventDefault
        }
      }
      Window.addEventListener("keydown", keyDownFn)
      () => Window.removeEventListener("keydown", keyDownFn)
    })
  }, [focusOnKeyPress])

  let value = switch input.value->JSON.Classify.classify {
  | String(str) => str
  | Number(num) => num->Float.toString
  | _ => ""
  }

  let isInValid = try {
    let {meta} = useField(input.name)
    let hasSubmitError =
      meta.submitError->getOptionalFromNullable->Option.isSome && !meta.dirtySinceLastSubmit
    let hasFieldError = meta.error->getOptionalFromNullable->Option.isSome
    !removeValidationCheck && !meta.valid && meta.touched && (hasSubmitError || hasFieldError)
  } catch {
  | _ => false
  }

  let blendSize = switch customWidth {
  | "w-full" | "w-96" => TextInputBinding.Lg
  | "w-80" | "w-64" => TextInputBinding.Md
  | "w-48" | "w-32" => TextInputBinding.Sm
  | _ => TextInputBinding.Lg
  }

  let handleChange = (event: ReactEvent.Form.t) => {
    let newValue = ReactEvent.Form.target(event)["value"]
    switch maxLength {
    | Some(maxLen) =>
      let strValue = newValue->getStringFromJson("")
      if strValue->String.length <= maxLen {
        input.onChange(event)
      }
    | None => input.onChange(event)
    }
  }

  let preventEnterDefault = (event: ReactEvent.Keyboard.t) => {
    if ReactEvent.Keyboard.key(event) === "Enter" {
      ReactEvent.Keyboard.preventDefault(event)
    }
  }

  let handleKeyDown = if shouldSubmitForm && onKeyUp->Option.isNone {
    None
  } else {
    Some(
      (event: ReactEvent.Keyboard.t) => {
        if !shouldSubmitForm {
          preventEnterDefault(event)
        }
        onKeyUp->Option.forEach(fn => fn(event))
      },
    )
  }

  let leftSlot = switch leftIcon {
  | Some(icon) => Some(icon)
  | None =>
    phoneInput ? Some(<span className="text-nd_gray-500"> {React.string("+91 ")} </span>) : None
  }

  let blendRightSlot = isPasswordType
    ? None
    : switch (rightIcon, rightIconOnClick) {
      | (Some(icon), Some(onClick)) => Some(<div onClick className="cursor-pointer"> icon </div>)
      | (Some(icon), None) => Some(icon)
      | (None, _) => None
      }

  let blendLeftSlot = isPasswordType ? None : leftSlot

  <>
    <RenderIf condition={isBlendEnabled}>
      <div className=customWidth>
        <TextInputBinding
          value
          onChange=handleChange
          onBlur=input.onBlur
          onFocus=input.onFocus
          name=input.name
          placeholder
          size=blendSize
          disabled=isDisabled
          hintText=?{description->getNonEmptyString}
          error=isInValid
          leftSlot=?blendLeftSlot
          rightSlot=?blendRightSlot
          type_=inputType
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
      </div>
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <TextInput
        input
        placeholder
        description
        isDisabled
        type_=inputType
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
    </RenderIf>
  </>
}

@send external focus: Dom.element => unit = "focus"
@send @return(nullable) external closest: (Dom.element, string) => option<Dom.element> = "closest"

@react.component
let make = (
  ~focusOnKeyPress=?,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~description="",
  ~isDisabled=false,
  ~type_="text",
  ~inputMode="text",
  ~pattern=?,
  ~autoComplete=?,
  ~shouldSubmitForm=true,
  ~min=?,
  ~max=?,
  ~maxLength=?,
  ~autoFocus=false,
  ~leftIcon=?,
  ~rightIcon=?,
  ~rightIconOnClick=?,
  ~customDashboardClass=?,
  ~inputStyle="",
  ~onKeyUp=?,
  ~customStyle="",
  ~customWidth="w-full",
  ~readOnly=?,
  ~iconOpacity="opacity-30",
  ~customPaddingClass="",
  ~widthMatchwithPlaceholderLength=None,
  ~rightIconCustomStyle="",
  ~leftIconCustomStyle="",
  ~onHoverCss="",
  ~onDisabledStyle="",
  ~onActiveStyle="",
  ~customDarkBackground="dark:bg-jp-gray-darkgray_background",
  ~phoneInput=false,
  ~removeValidationCheck=false,
) => {
  let showPopUp = PopUpState.useShowPopUp()
  let isInValid = try {
    let {meta} = ReactFinalForm.useField(input.name)
    if !removeValidationCheck {
      let bool = if !meta.valid && meta.touched {
        // if there is a submission error and field value hasn't been updated after last submit, field is invalid
        // or if there is any field error, field is invalid
        (!(meta.submitError->Js.Nullable.isNullable) && !meta.dirtySinceLastSubmit) ||
          !(meta.error->Js.Nullable.isNullable)
      } else {
        false
      }
      bool
    } else {
      false
    }
  } catch {
  | _ => false
  }

  let {isFirst, isLast} = React.useContext(ButtonGroupContext.buttonGroupContext)
  let (showPassword, setShowPassword) = React.useState(_ => false)
  let inputRef = React.useRef(Js.Nullable.null)

  React.useEffect2(() => {
    switch widthMatchwithPlaceholderLength {
    | Some(length) =>
      switch inputRef.current->Js.Nullable.toOption {
      | Some(elem) =>
        let size =
          elem
          ->Webapi.Dom.Element.getAttribute("placeholder")
          ->Belt.Option.mapWithDefault(length, str => Js.Math.max_int(length, str->String.length))
          ->Belt.Int.toString

        elem->Webapi.Dom.Element.setAttribute("size", size)
      | None => ()
      }

    | None => ()
    }
    None
  }, (inputRef.current, input.name))

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

  React.useEffect1(() => {
    switch focusOnKeyPress {
    | Some(func) => {
        let keyDownFn = ev => {
          if func(ev) {
            ev->ReactEvent.Keyboard.preventDefault
            switch inputRef.current->Js.Nullable.toOption {
            | Some(elem) => elem->focus
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

  let cursorClass = isDisabled ? "cursor-not-allowed" : ""
  let roundingClass = if isFirst && isLast {
    "rounded"
  } else if isFirst {
    "rounded-l"
  } else if isLast {
    "rounded-r"
  } else {
    ""
  }

  let borderClass = isInValid
    ? "border-red-500 focus:border-red-500  dark:border-red-500 dark:hover:border-red-500 dark:focus:border-red-500 focus:shadow-text_input_shadow focus:shadow-red-500"
    : "border-jp-gray-lightmode_steelgray focus:border-blue-800 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:focus:border-blue-800 focus:shadow-text_input_shadow focus:shadow-blue-800"

  let dashboardClass =
    customDashboardClass->Belt.Option.getWithDefault("h-10 text-sm font-semibold")
  let rightPaddingClass = if description !== "" || isInValid {
    "pr-10"
  } else {
    switch rightIcon {
    | Some(_) => "pr-10"
    | None => "pr-2"
    }
  }
  let leftPaddingClass = switch leftIcon {
  | Some(_) => "pl-10"
  | None => "pl-2"
  }
  let verticalPadding = ""
  let placeholderClass = ""
  let textAndBgClass = `${customDarkBackground} text-jp-gray-900 text-opacity-75 focus:text-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100`

  let width = widthMatchwithPlaceholderLength->Belt.Option.isSome ? "" : customWidth
  let textPaddingClass =
    type_ !== "range" && customPaddingClass == ""
      ? `${rightPaddingClass} ${leftPaddingClass} ${verticalPadding}`
      : customPaddingClass
  let hoverCss = if onHoverCss == "" {
    "hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-opacity-20 dark:hover:bg-jp-gray-970"
  } else {
    onHoverCss
  }
  let className = `${width} border border-opacity-75 ${textPaddingClass} ${textAndBgClass} placeholder-jp-gray-900 placeholder-opacity-25 focus:outline-none
      focus:border-opacity-100 ${hoverCss} ${roundingClass} ${cursorClass} ${dashboardClass} ${inputStyle} ${borderClass} ${customStyle} ${placeholderClass} ${isDisabled
      ? onDisabledStyle
      : onActiveStyle}`
  let value = switch input.value->Js.Json.classify {
  | JSONString(str) => str
  | JSONNumber(num) => num->Belt.Float.toString
  | _ => ""
  }

  let passwordVisiblity = _ => {
    setShowPassword(prev => !prev)
  }

  let leftIconClass = `absolute self-center p-3 ${iconOpacity} ${leftIconCustomStyle}`

  let leftIconElement = switch leftIcon {
  | Some(icon) => <div id="leftIcon" className=leftIconClass> icon </div>
  | None => React.null
  }
  let rightIconCursorClass = switch rightIconOnClick {
  | Some(_) => "cursor-pointer"
  | None => ""
  }
  let rightIconStyle =
    rightIconCustomStyle == "" ? `-ml-10 ${rightIconCursorClass}` : rightIconCustomStyle
  let rightIconClick = ev => {
    switch rightIconOnClick {
    | Some(fn) => fn(ev)
    | None => ()
    }
  }

  let rightIconElement = switch rightIcon {
  | Some(icon) =>
    <div id="rightIcon" className={`${rightIconStyle}`} onClick=rightIconClick> icon </div>
  | None => React.null
  }

  let inputName = if autoComplete === Some("off") {
    None
  } else {
    Some(input.name)
  }

  let form = switch shouldSubmitForm {
  | true => None
  | false => Some("fakeForm")
  }
  let className = if rightIconElement != React.null {
    `${className} pr-10`
  } else if leftIconElement != React.null {
    let padding = phoneInput ? "pl-20" : "pl-10"
    `${className} ${padding}`
  } else {
    className
  }

  let eyeIcon = if showPassword {
    "eye"
  } else {
    "eye-slash"
  }
  let eyeIconSize = 15
  let eyeClassName = "fill-jp-gray-700"

  if type_ == "password" || type_ == "password_without_icon" {
    <AddDataAttributes
      attributes=[("data-id-password", placeholder), ("data-input-name", input.name)]>
      <div className="flex flex-row items-center relative">
        leftIconElement
        <input
          ref={inputRef->ReactDOM.Ref.domRef}
          className={`${className} pr-10`}
          name=?inputName
          onBlur={input.onBlur}
          onChange={input.onChange}
          onFocus={input.onFocus}
          value
          disabled={isDisabled}
          placeholder={placeholder}
          type_={showPassword ? "text" : "password"}
          inputMode
          ?pattern
          ?autoComplete
          ?min
          ?max
          ?maxLength
          ?onKeyUp
          ?readOnly
          ?form
        />
        {if type_ !== "password_without_icon" {
          <div className="cursor-pointer select-none -ml-8" onClick={passwordVisiblity}>
            <Icon name=eyeIcon size=eyeIconSize className=eyeClassName />
          </div>
        } else {
          React.null
        }}
      </div>
    </AddDataAttributes>
  } else {
    <AddDataAttributes attributes=[("data-id", placeholder), ("data-input-name", input.name)]>
      <div className="flex flex-row relative items-center grow">
        leftIconElement
        <input
          ref={inputRef->ReactDOM.Ref.domRef}
          className
          name=?inputName
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
          ?maxLength
          ?onKeyUp
          ?readOnly
          autoFocus
          ?form
        />
        {description !== ""
          ? <ToolTip
              description
              toolTipPosition=Right
              height="h-min"
              toolTipFor={<div className="cursor-pointer select-none -ml-8">
                <Icon name="new-question-circle" size=16 className="stroke-jp-2-light-gray-1000" />
              </div>}
            />
          : rightIconElement}
      </div>
    </AddDataAttributes>
  }
}

module HoverInline = {
  @react.component
  let make = (
    ~customStyle="",
    ~leftIcon,
    ~value,
    ~subText,
    ~showEditIconOnHover,
    ~leftActionButtons,
    ~labelTextCustomStyle,
  ) => {
    <div
      className={`group relative font-medium inline-flex gap-4 items-center justify-between px-4 py-2 w-full bg-white rounded-md  ${customStyle}`}>
      <div className="flex gap-2">
        <RenderIf condition={leftIcon->Option.isSome}>
          {leftIcon->Option.getOr(React.null)}
        </RenderIf>
        <div className="flex flex-col gap-1 ml-1">
          <p className={`text-sm ${labelTextCustomStyle} `}> {React.string(value)} </p>
          <RenderIf condition={subText->LogicUtils.isNonEmptyString}>
            <span className="text-xs text-gray-500"> {subText->React.string} </span>
          </RenderIf>
        </div>
      </div>
      {if showEditIconOnHover {
        <div className="invisible group-hover:visible"> {leftActionButtons} </div>
      } else {
        leftActionButtons
      }}
    </div>
  }
}

@react.component
let make = (
  ~index=0,
  ~labelText="",
  ~subText="",
  ~customStyle="",
  ~showEditIconOnHover=true,
  ~leftIcon=?,
  ~onSubmit=?,
  ~customIconComponent=?,
  ~customInputStyle="",
  ~customIconStyle="",
  ~showEditIcon=true,
  ~handleEdit: option<int> => unit=?,
  ~isUnderEdit=false,
  ~displayHoverOnEdit=true,
  ~validateInput: string => Dict.t<string>=?,
  ~labelTextCustomStyle="",
) => {
  let (value, setValue) = React.useState(_ => labelText)
  let (inputErrors, setInputErrors) = React.useState(_ => Dict.make())
  let enterKeyCode = 13
  let escapeKeyCode = 27
  let handleSave = () => {
    Js.log("going save")
    setValue(_ => value)
    switch (onSubmit, handleEdit) {
    | (Some(func), Some(func1)) => {
        func(value)->ignore
        func1(None)
      }
    | (_, _) => ()
    }
  }

  React.useEffect(() => {
    if labelText->LogicUtils.isNonEmptyString {
      setValue(_ => labelText)
    }
    None
  }, [labelText])

  let handleCancel = () => {
    Js.log("inside cancel")
    setValue(_ => labelText)
    setInputErrors(_ => Dict.make())
    switch handleEdit {
    | Some(func) => func(None)
    | None => ()
    }
    // handleEdit(None)
  }

  let handleKeyDown = e => {
    let key = e->ReactEvent.Keyboard.key
    let keyCode = e->ReactEvent.Keyboard.keyCode
    if key === "Enter" || keyCode === enterKeyCode {
      if inputErrors->LogicUtils.isEmptyDict {
        handleSave()
      } else {
        handleCancel()
      }
    }
    if key === "Escape" || keyCode === escapeKeyCode {
      handleCancel()
    }
  }

  let dropdownRef = React.useRef(Nullable.null)
  OutsideClick.useOutsideClick(
    ~refs={ArrayOfRef([dropdownRef])},
    ~isActive=isUnderEdit,
    ~callback=() => {
      switch handleEdit {
      | Some(func) => func(None)
      | None => ()
      }
    },
  )
  let submitButtons =
    <div className="flex items-center gap-2 pr-4">
      <button onClick={_ => handleCancel()} className={`cursor-pointer  ${customIconStyle}`}>
        <Icon name="nd-cross" size=16 />
      </button>
      <button
        onClick={_ => handleSave()} className={`cursor-pointer text-primary ${customIconStyle}`}>
        <Icon name="nd-check" size=16 />
      </button>
    </div>

  let leftActionButtons =
    <div className="gap-2 flex">
      <RenderIf condition={showEditIcon}>
        <button
          onClick={_ => {
            Js.log("onclick")
            switch handleEdit {
            | Some(func) => func(Some(index))
            | None => ()
            }
          }}
          className={`cursor-pointer  ${customIconStyle}`}
          ariaLabel="Edit">
          <Icon name="nd-pencil" size=14 />
        </button>
      </RenderIf>
      <RenderIf condition={customIconComponent->Option.isSome}>
        <div className="flex items-center justify-center w-4 h-4">
          {customIconComponent->Option.getOr(React.null)}
        </div>
      </RenderIf>
    </div>

  let handleInputChange = e => {
    let value = ReactEvent.Form.target(e)["value"]
    setValue(_ => value)

    let errors = switch validateInput {
    | Some(func) => func(value)
    | _ => Dict.make()
    }
    setInputErrors(_ => errors)
  }

  <div
    className="relative inline-block w-full"
    onClick={e => {
      e->ReactEvent.Mouse.stopPropagation
    }}>
    {if isUnderEdit {
      //TODO: validation error message has to be displayed
      <div
        className={`group relative flex items-center bg-white ${inputErrors->LogicUtils.isEmptyDict
            ? "focus-within:ring-1 focus-within:ring-primary"
            : "ring-1 ring-red-300"}  rounded-md text-md ${customStyle}`}>
        <div className={`flex-1 `}>
          <input
            type_="text"
            value
            onChange=handleInputChange
            onKeyDown=handleKeyDown
            autoFocus=true
            className={`w-full px-4 py-2 bg-transparent focus:outline-none text-md ${customInputStyle}`}
          />
        </div>
        {submitButtons}
      </div>
    } else {
      <RenderIf condition={displayHoverOnEdit}>
        <HoverInline
          customStyle
          leftIcon
          value
          subText
          showEditIconOnHover
          leftActionButtons
          labelTextCustomStyle
        />
      </RenderIf>
    }}
  </div>
}

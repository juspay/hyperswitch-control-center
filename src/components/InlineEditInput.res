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
    ~customWidth,
  ) => {
    <div
      className={`group relative font-medium flex flex-row items-start gap-2 px-2 py-2 w-full bg-white rounded-md ${customWidth} ${customStyle}`}>
      <RenderIf condition={leftIcon->Option.isSome}>
        <div className="flex items-center justify-center ">
          <div className="rounded-md w-12 h-8 "> {leftIcon->Option.getOr(React.null)} </div>
        </div>
      </RenderIf>
      <div className="flex flex-col w-full gap-1">
        <div className="flex justify-between items-center w-full">
          <div className={`text-sm ${labelTextCustomStyle}`}> {React.string(value)} </div>
          <div className={`${showEditIconOnHover ? "invisible group-hover:visible" : ""}`}>
            leftActionButtons
          </div>
        </div>
        <RenderIf condition={subText->LogicUtils.isNonEmptyString}>
          <div className="text-xs text-gray-500"> {React.string(subText)} </div>
        </RenderIf>
      </div>
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
  ~handleEdit: option<int> => unit,
  ~isUnderEdit=false,
  ~displayHoverOnEdit=true,
  ~validateInput,
  ~labelTextCustomStyle="",
  ~customWidth="",
) => {
  let (value, setValue) = React.useState(_ => labelText)
  let (inputErrors, setInputErrors) = React.useState(_ => Dict.make())
  let enterKeyCode = 13
  let escapeKeyCode = 27
  let handleSave = () => {
    setValue(_ => value)
    switch onSubmit {
    | Some(func) => {
        func(value)->ignore
        handleEdit(None)
      }
    | None => ()
    }
    handleEdit(None)
  }

  React.useEffect(() => {
    if labelText->LogicUtils.isNonEmptyString {
      setValue(_ => labelText)
    }
    None
  }, [labelText])

  let handleCancel = () => {
    setValue(_ => labelText)
    setInputErrors(_ => Dict.make())
    handleEdit(None)
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
      handleEdit(None)
    },
  )
  let submitButtons =
    <div className="flex items-center gap-2 pr-4">
      <button onClick={_ => handleCancel()} className={`cursor-pointer  ${customIconStyle}`}>
        <Icon name="nd-cross" size=16 />
      </button>
      <button
        onClick={_ => handleSave()} className={`cursor-pointer !text-primary ${customIconStyle}`}>
        <Icon name="nd-check" size=16 />
      </button>
    </div>

  let leftActionButtons =
    <div className="gap-2 flex">
      <RenderIf condition={showEditIcon}>
        <button
          onClick={_ => {
            handleEdit(Some(index))
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
    let errors = validateInput(value)
    setInputErrors(_ => errors)
  }

  <div
    className="relative inline-block"
    onClick={e => {
      e->ReactEvent.Mouse.stopPropagation
    }}>
    {if isUnderEdit {
      //TODO: validation error message has to be displayed
      <div className={`flex items-center gap-2 p-1 ${customWidth}`}>
        <RenderIf condition={leftIcon->Option.isSome}>
          <div className="rounded-md overflow-hidden w-12 h-8 ">
            {leftIcon->Option.getOr(React.null)}
          </div>
        </RenderIf>
        <div
          className={`group relative flex items-center bg-white ${inputErrors->LogicUtils.isEmptyDict
              ? "focus-within:ring-1 focus-within:ring-primary"
              : "ring-1 ring-red-300"}  rounded-md text-md !py-2 ${customStyle} `}>
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
          customWidth
        />
      </RenderIf>
    }}
  </div>
}

module HoverInline = {
  @react.component
  let make = (
    ~customStyle="",
    ~leftIcon,
    ~value,
    ~subText,
    ~showEditIconOnHover,
    ~leftActionButtons,
  ) => {
    <div
      className={`group relative font-medium inline-flex gap-4 items-center justify-between px-4 py-2 w-full bg-white rounded-md  ${customStyle}`}>
      <div className="flex gap-2">
        <RenderIf condition={leftIcon->Option.isSome}>
          {leftIcon->Option.getOr(React.null)}
        </RenderIf>
        <div className="flex flex-col gap-1 ml-1">
          <p className="text-sm"> {React.string(value)} </p>
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
  ~handleEdit: option<int> => unit,
  ~isUnderEdit=false,
  ~displayHoverOnEdit=true,
) => {
  let (value, setValue) = React.useState(_ => labelText)
  let enterKeyCode = 13
  let escapeKeyCode = 27
  let handleSave = () => {
    setValue(_ => value)
    switch onSubmit {
    | Some(func) => func(value)
    | None => ()
    }
    handleEdit(None)
  }

  React.useEffect(() => {
    if labelText->String.length > 0 {
      setValue(_ => labelText)
    }
    None
  }, [labelText])

  let handleCancel = () => {
    setValue(_ => labelText)
    handleEdit(None)
  }

  let handleKeyDown = e => {
    let key = e->ReactEvent.Keyboard.key
    let keyCode = e->ReactEvent.Keyboard.keyCode
    if key === "Enter" || keyCode === enterKeyCode {
      handleSave()
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
        onClick={_ => handleSave()} className={`cursor-pointer text-primary ${customIconStyle}`}>
        <Icon name="nd-check" size=16 />
      </button>
    </div>

  let leftActionButtons =
    <div>
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
    // validations needs to be performed over here
    setValue(_ => value)
  }

  <div
    className="relative inline-block"
    onClick={e => {
      e->ReactEvent.Mouse.stopPropagation
    }}>
    {if isUnderEdit {
      <div
        className={`group relative flex items-center bg-white focus-within:ring-1 focus-within:ring-primary rounded-md text-md ${customStyle}`}>
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
        <HoverInline customStyle leftIcon value subText showEditIconOnHover leftActionButtons />
      </RenderIf>
    }}
  </div>
}

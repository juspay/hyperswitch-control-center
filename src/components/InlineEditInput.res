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
    ~showTooltipOnHover=false,
  ) => {
    open Typography

    <div
      className={`group/inlineHover relative font-medium flex flex-row items-center p-2 justify-center gap-x-2 w-full bg-white rounded-md ${customWidth} ${customStyle}`}>
      <RenderIf condition={leftIcon->Option.isSome}>
        {leftIcon->Option.getOr(React.null)}
      </RenderIf>
      <div className="flex flex-col w-full gap-1">
        <div className="flex justify-between items-center w-full">
          <RenderIf condition={showTooltipOnHover}>
            <ToolTip
              description={value}
              toolTipFor={<div className={`${body.md.medium} ${labelTextCustomStyle}`}>
                {React.string(value)}
              </div>}
              toolTipPosition=Bottom
              enableTooltipDelay=true
              tooltipDelay=800
              customStyle="!whitespace-nowrap"
            />
          </RenderIf>
          <RenderIf condition={!showTooltipOnHover}>
            <div className={`${body.md.medium} ${labelTextCustomStyle}`}>
              {React.string(value)}
            </div>
          </RenderIf>
          <div
            className={`${showEditIconOnHover ? "invisible group-hover/inlineHover:visible" : ""}`}
            onClick={ReactEvent.Mouse.stopPropagation}>
            leftActionButtons
          </div>
        </div>
        <RenderIf condition={subText->LogicUtils.isNonEmptyString}>
          <div className="text-xs text-nd_gray-400"> {React.string(subText)} </div>
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
  ~handleClick=?,
  ~showTooltipOnHover=false,
) => {
  let (value, setValue) = React.useState(_ => labelText)
  let (inputErrors, setInputErrors) = React.useState(_ => Dict.make())
  let enterKeyCode = 13
  let escapeKeyCode = 27

  let handleCancel = () => {
    setValue(_ => labelText)
    setInputErrors(_ => Dict.make())
    handleEdit(None)
  }
  let handleSave = () => {
    setValue(_ => value)
    if !{inputErrors->LogicUtils.isEmptyDict} || value == labelText {
      handleCancel()
    } else {
      switch onSubmit {
      | Some(func) => {
          func(value)->ignore
          handleEdit(None)
        }
      | None => ()
      }
      handleEdit(None)
    }
  }

  React.useEffect(() => {
    if labelText->LogicUtils.isNonEmptyString {
      setValue(_ => labelText)
    }
    None
  }, [labelText])

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
  let isDisabled = !{inputErrors->LogicUtils.isEmptyDict}
  let isDisabledCss = {isDisabled ? "!cursor-not-allowed" : "cursor-pointer"}
  let dropdownRef = React.useRef(Nullable.null)
  OutsideClick.useOutsideClick(
    ~refs={ArrayOfRef([dropdownRef])},
    ~isActive=isUnderEdit,
    ~callback=() => {
      handleEdit(None)
      handleCancel()
    },
  )
  let submitButtons =
    <div
      className="flex items-center gap-2 pr-4 cursor-pointer"
      onClick={ReactEvent.Mouse.stopPropagation}>
      <button onClick={_ => handleCancel()} className={`cursor-pointer  ${customIconStyle}`}>
        <Icon name="nd-cross" size=16 />
      </button>
      <button
        onClick={_ => handleSave()}
        className={`cursor-pointer !text-blue-500 ${customIconStyle} ${isDisabledCss}`}
        disabled={isDisabled}>
        <Icon name="nd-check" size=16 />
      </button>
    </div>

  let leftActionButtons =
    <div className="gap-2 flex cursor-pointer">
      <RenderIf condition={showEditIcon}>
        <button
          onClick={_ => {
            handleEdit(Some(index))
          }}
          className={`${customIconStyle}`}
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
    className="relative inline-block w-full"
    onClick={e => {
      switch handleClick {
      | Some(fn) => fn()
      | None =>
        ()
        e->ReactEvent.Mouse.stopPropagation
      }
    }}>
    {if isUnderEdit {
      //TODO: validation error message has to be displayed
      <div
        className={`flex items-center  p-1 ${customWidth}`}
        onClick={ReactEvent.Mouse.stopPropagation}>
        <RenderIf condition={leftIcon->Option.isSome}>
          {leftIcon->Option.getOr(React.null)}
        </RenderIf>
        <div
          className={`group relative flex items-center bg-white ${inputErrors->LogicUtils.isEmptyDict
              ? "focus-within:ring-1 focus-within:ring-blue-400"
              : "ring-1 ring-red-300"}  rounded-md text-md !py-2 ${customStyle} `}>
          <div className={`flex-1 `}>
            <input
              type_="text"
              value
              onChange=handleInputChange
              onKeyDown=handleKeyDown
              autoFocus=true
              className={`w-full p-2 bg-transparent focus:outline-none text-md ${customInputStyle}`}
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
          showTooltipOnHover
        />
      </RenderIf>
    }}
  </div>
}

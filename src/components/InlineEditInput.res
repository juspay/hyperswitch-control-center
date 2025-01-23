@react.component
let make = (
  ~labelText="",
  ~showSubText=false,
  ~subText="",
  ~customStyle="",
  ~onHoverEdit=true,
  ~leftIcon=?,
  ~onSubmit=?,
  ~customIconComponent=?,
  ~customInputStyle="",
  ~customIconStyle="",
  ~showEdit=true,
  ~isEditing=false,
  ~setIsEditing=?,
) => {
  // let (isEditing, setIsEditing) = React.useState(_ => false)
  let (value, setValue) = React.useState(_ => labelText)
  let enterKeyCode = 13
  let escapeKeyCode = 27

  let handleSave = () => {
    setValue(_ => value)
    switch onSubmit {
    | Some(func) => func(value)
    | None => ()
    }
    setIsEditing(_ => false)
  }

  let handleCancel = () => {
    setValue(_ => labelText)
    // setIsEditing(_ => false)
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
    <div className="flex gap-2">
      <RenderIf condition={showEdit}>
        <button
          onClick={e => {
            setIsEditing(_ => isEditing)
          }}
          className={`cursor-pointer  ${customIconStyle}`}
          ariaLabel="Edit">
          <Icon name="nd-pencil" size=14 />
        </button>
      </RenderIf>
      <RenderIf condition={customIconComponent->Option.isSome}>
        {customIconComponent->Option.getOr(React.null)}
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
    {if isEditing {
      <div
        className={`group relative flex items-center bg-white  focus-within:ring-1 focus-within:ring-primary rounded-md text-md ${customStyle}`}>
        <div className="flex-1">
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
      <div
        className={`group relative font-medium inline-flex gap-4 items-center justify-between px-4 py-2 w-full bg-white rounded-md  ${customStyle}`}>
        <div className="flex gap-2">
          <RenderIf condition={leftIcon->Option.isSome}>
            {leftIcon->Option.getOr(React.null)}
          </RenderIf>
          <div className="flex flex-col gap-1 ml-1">
            <p className="text-sm"> {React.string(value)} </p>
            <RenderIf condition={showSubText}>
              <span className="text-xs text-gray-500"> {subText->React.string} </span>
            </RenderIf>
          </div>
        </div>
        {if onHoverEdit {
          <div className="invisible group-hover:visible"> {leftActionButtons} </div>
        } else {
          leftActionButtons
        }}
      </div>
    }}
  </div>
}

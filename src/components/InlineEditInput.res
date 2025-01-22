@react.component
let make = (
  ~labelText="",
  ~showSubText=false,
  ~subText="",
  ~customStyle="",
  ~onHoverEdit=false,
  ~leftIcon=?,
  ~onSubmit=?,
  ~customIconComponent=?,
  ~customInputStyle="",
  ~customIconStyle="",
) => {
  let (isEditing, setIsEditing) = React.useState(_ => false)
  let (value, setValue) = React.useState(_ => labelText)
  let (newValue, setNewValue) = React.useState(_ => labelText)

  let handleSave = () => {
    setValue(_ => newValue)
    switch onSubmit {
    | Some(func) => func(newValue)
    | None => ()
    }
    setIsEditing(_ => false)
  }

  let handleCancel = () => {
    setNewValue(_ => value)
    setIsEditing(_ => false)
  }

  let handleKeyDown = event => {
    switch ReactEvent.Keyboard.key(event) {
    | "Enter" => handleSave()
    | "Escape" => handleCancel()
    | _ => ()
    }
  }

  let editButtons =
    <div className="flex items-center gap-2 pr-4">
      <button onClick={_ => handleCancel()} className={`cursor-pointer  ${customIconStyle}`}>
        <Icon name="new-cross" size=16 />
      </button>
      <button
        onClick={_ => handleSave()} className={`cursor-pointer !stroke-primary ${customIconStyle}`}>
        <Icon name="new-check" size=16 />
      </button>
    </div>

  let leftActionButtons =
    <div className="flex gap-2">
      <button
        onClick={_ => setIsEditing(_ => true)}
        className={`cursor-pointer ${customIconStyle}`}
        ariaLabel="Edit">
        <Icon name="new-pencil" size=14 />
      </button>
      <RenderIf condition={customIconComponent->Option.isSome}>
        {customIconComponent->Option.getOr(React.null)}
      </RenderIf>
    </div>

  <div className="relative inline-block">
    {if isEditing {
      <div
        className={`group flex items-center bg-white focus-within:ring-1 focus-within:ring-primary rounded-md text-md ${customStyle}`}>
        <div className="flex-1">
          <input
            type_="text"
            value=newValue
            onChange={event => setNewValue(ReactEvent.Form.target(event)["value"])}
            onKeyDown=handleKeyDown
            autoFocus=true
            className={`w-full px-4 py-2 bg-transparent focus:outline-none text-md ${customInputStyle}`}
          />
        </div>
        {editButtons}
      </div>
    } else {
      <div
        className={`group relative font-medium inline-flex items-center justify-between px-4 py-2 w-full bg-white rounded-md hover:bg-gray-100 ${customStyle}`}>
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

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~labelText=?,
  ~fullWidth=true,
  ~customInputClassName="",
  ~customWrapperClassName="",
  ~pickerPositionClassName="justify-between",
  ~defaultValue=?,
) => {
  open LogicUtils
  let getHexColor = value =>
    switch JSON.Decode.string(value) {
    | Some(str) => str->isEmptyString ? "#FFFFFF" : str
    | None => "#FFFFFF"
    }

  let initialColor = switch defaultValue {
  | Some(val) => val
  | None => getHexColor(input.value)
  }

  let (color, setColor) = React.useState(() => initialColor->String.toUpperCase)
  let (toggle, setToggle) = React.useState(() => false)
  let colorPickerRef = React.useRef(Js.Nullable.null)

  let onChangeComplete = color =>
    switch getDictFromJsonObject(color)->getString("hex", "") {
    | hex => {
        let upperHex = hex->String.toUpperCase
        setColor(_ => upperHex)
        input.onChange(upperHex->Identity.anyTypeToReactEvent)
      }
    }

  OutsideClick.useOutsideClick(~refs=ArrayOfRef([colorPickerRef]), ~isActive=toggle, ~callback=() =>
    setToggle(_ => false)
  )

  <div
    className={`flex flex-col ${fullWidth ? "w-full" : ""} ${customWrapperClassName}`}
    ref={colorPickerRef->ReactDOM.Ref.domRef}>
    <RenderIf condition={labelText->Option.isSome}>
      <label className="text-sm font-medium mb-1">
        {React.string(labelText->Option.getOr(""))}
      </label>
    </RenderIf>
    <div
      className={`flex flex-row items-center border rounded-md px-3 py-2 bg-white dark:bg-jp-gray-950 dark:border-jp-gray-960 cursor-pointer ${customInputClassName}`}
      onClick={_ => setToggle(prev => !prev)}>
      <input
        readOnly=true
        value=color
        className="flex-1 bg-transparent outline-none text-sm text-jp-gray-800 dark:text-jp-gray-text_darktheme"
      />
      <div
        {...DOMUtils.domProps({"data-color": color})}
        className="h-5 w-5 border ml-2 rounded-sm border-jp-gray-500 dark:border-jp-gray-960"
        style={ReactDOMStyle.make(~backgroundColor=color, ())}
      />
    </div>
    <RenderIf condition={toggle}>
      <div className="mt-10 shadow-md border border-jp-gray-300 rounded-md z-50 absolute bg-white">
        <SketchPicker color onChangeComplete />
      </div>
    </RenderIf>
  </div>
}

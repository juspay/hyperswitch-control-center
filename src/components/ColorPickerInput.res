@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~labelText=?,
  ~fullWidth=true,
  ~customInputClassName="",
  ~customWrapperClassName="",
  ~defaultValue=?,
  ~showErrorWhenEmpty=true,
) => {
  open LogicUtils

  let isValidHexCode = value => {
    Re.test(Js.Re.fromString("^#([0-9A-Fa-f]{6})$"), value)
  }

  let getHexColor = value =>
    switch JSON.Decode.string(value) {
    | Some(str) if str->isNonEmptyString && isValidHexCode(str) => str
    | _ => "#006DF9"
    }

  let initialColor = switch defaultValue {
  | Some(val) => val
  | None => getHexColor(input.value)
  }

  let (color, setColor) = React.useState(() => initialColor->String.toUpperCase)
  let (isValid, setIsValid) = React.useState(() => isValidHexCode(initialColor))
  let (toggle, setToggle) = React.useState(() => false)
  let colorPickerRef = React.useRef(Js.Nullable.null)

  let onChangeComplete = color =>
    switch getDictFromJsonObject(color)->getString("hex", "") {
    | hex => {
        let upperHex = hex->String.toUpperCase
        setColor(_ => upperHex)
        setIsValid(_ => true)
        input.onChange(upperHex->Identity.anyTypeToReactEvent)
      }
    }

  // Handle input blur to ensure final value is valid
  let handleBlur = _ => {
    if !isValidHexCode(color) {
      // Reset to last valid color or default
      let validColor = initialColor->String.toUpperCase
      setColor(_ => validColor)
      setIsValid(_ => true)
      input.onChange(validColor->Identity.anyTypeToReactEvent)
    }
  }

  OutsideClick.useOutsideClick(~refs=ArrayOfRef([colorPickerRef]), ~isActive=toggle, ~callback=() =>
    setToggle(_ => false)
  )

  let showError = switch (color->isEmptyString, showErrorWhenEmpty) {
  | (true, true) => !isValid
  | (true, false) => false
  | (false, _) => !isValid
  }

  <div
    className={`relative flex flex-col ${fullWidth ? "w-full" : ""} ${customWrapperClassName}`}
    ref={colorPickerRef->ReactDOM.Ref.domRef}>
    <RenderIf condition={labelText->Option.isSome}>
      <label className="text-sm font-medium mb-1">
        {React.string(labelText->Option.getOr(""))}
      </label>
    </RenderIf>
    <div
      className={`flex flex-row items-center border rounded-md px-3 py-2 bg-white dark:bg-jp-gray-950 dark:border-jp-gray-960 cursor-pointer ${showError
          ? "border-red-500"
          : ""} ${customInputClassName}`}
      onClick={_ => setToggle(prev => !prev)}>
      <input
        value={color}
        onBlur={handleBlur}
        onChange={e => {
          let newColor = ReactEvent.Form.target(e)["value"]
          setColor(_ => newColor)

          // Only update form value if it's a valid hex code
          let isValidHex = isValidHexCode(newColor)
          setIsValid(_ => isValidHex)

          if isValidHex {
            input.onChange(newColor->Identity.anyTypeToReactEvent)
          }
        }}
        className="flex-1 bg-transparent outline-none text-sm text-jp-gray-800 dark:text-jp-gray-text_darktheme"
        placeholder="#FFFFFF"
      />
      <div
        className="h-5 w-5 border ml-2 rounded-sm border-jp-gray-500 dark:border-jp-gray-960"
        style={ReactDOMStyle.make(~backgroundColor=isValid ? color : initialColor, ())}
      />
    </div>
    <RenderIf condition={showError}>
      <div className="text-red-500 text-xs mt-1">
        {React.string("Please enter a valid hex color code (e.g., #FF5733)")}
      </div>
    </RenderIf>
    <RenderIf condition={toggle}>
      <div
        className="mt-10 shadow-md border border-jp-gray-300 rounded-md z-50 absolute bg-white right-0">
        <SketchPicker color={isValid ? color : initialColor} onChangeComplete />
      </div>
    </RenderIf>
  </div>
}

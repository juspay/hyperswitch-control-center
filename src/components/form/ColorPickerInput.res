external toReactEvent: 'a => ReactEvent.Form.t = "%identity"
@react.component
let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
  let (color, setColor) = React.useState(_ =>
    input.value->Js.Json.decodeString->Belt.Option.getWithDefault("") === ""
      ? "#ffffff"
      : input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  )
  let (toggle, setToggle) = React.useState(_ => false)
  let colorPickerRef = React.useRef(Js.Nullable.null)
  let onChangeComplete = color => {
    let hex = color->LogicUtils.getDictFromJsonObject->LogicUtils.getString("hex", "")
    setColor(_ => hex)
    input.onChange(hex->toReactEvent)
  }

  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([colorPickerRef]),
    ~isActive=toggle,
    ~callback=() => {
      setToggle(_ => false)
    },
    (),
  )

  <div ref={colorPickerRef->ReactDOM.Ref.domRef}>
    <div className="flex flex-row " onClick={_ev => setToggle(toggle => !toggle)}>
      <div
        className="overflow-hidden justify-center h-10 flex flex-row items-center border border-jp-gray-500 dark:border-jp-gray-960 text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 cursor-pointer rounded-md border-jp-gray-500 dark:border-jp-gray-960 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-1 my-3">
        <div className="ml-1"> {React.string(color)} </div>
        <AddDataAttributes attributes=[("data-color", color)]>
          <div
            className={`h-5 w-5 border-jp-gray-500 dark:border-jp-gray-960 rounded-sm ml-3 mr-1`}
            style={ReactDOMStyle.make(~backgroundColor=color, ())}
          />
        </AddDataAttributes>
      </div>
    </div>
    {if toggle {
      <SketchPicker color onChangeComplete />
    } else {
      React.null
    }}
  </div>
}

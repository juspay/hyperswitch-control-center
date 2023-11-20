@react.component
let make = (
  ~defaultLanguage: string,
  ~defaultValue=?,
  ~value=?,
  ~height=?,
  ~theme=?,
  ~readOnly=false,
  ~width=?,
  ~onChange=?,
  ~onValidate=?,
  ~showCopy=true,
  ~fontSize=?,
  ~fontFamily=?,
  ~fontWeight=?,
  ~minimap=true,
  ~outerWidth="w-full",
  ~onMount: option<Monaco.Editor.IStandaloneCodeEditor.t => unit>=?,
  ~headerComponent=?,
) => {
  let copyValue = value->Belt.Option.isNone ? defaultValue : value

  <AddDataAttributes
    attributes=[("data-editor", "Monaco Editor"), ("text", value->Belt.Option.getWithDefault(""))]>
    <div className={`flex flex-col ${outerWidth}`}>
      {headerComponent->Belt.Option.getWithDefault(React.null)}
      {showCopy ? <Clipboard.Copy data=copyValue /> : React.null}
      <MonacoEditor
        defaultLanguage
        ?defaultValue
        ?value
        ?height
        ?theme
        ?width
        options={{readOnly, fontSize, fontFamily, fontWeight, minimap: {enabled: minimap}}}
        ?onChange
        ?onValidate
        ?onMount
      />
    </div>
  </AddDataAttributes>
}

open LazyUtils

type miniTypes = {enabled: bool}

type setOptions = {
  readOnly: bool,
  fontSize?: option<int>,
  fontFamily?: option<string>,
  fontWeight?: option<string>,
  minimap?: miniTypes,
}

type props = {
  defaultLanguage: string,
  defaultValue?: string,
  value?: string,
  height?: string,
  theme?: string,
  width?: string,
  options?: setOptions,
  onChange?: string => unit,
  onValidate?: Js.Array2.t<array<Js.Json.t>> => unit,
  onMount?: Monaco.Editor.IStandaloneCodeEditor.t => unit,
}

let make: props => React.element = reactLazy(.() => {
  import_("@monaco-editor/react")
})

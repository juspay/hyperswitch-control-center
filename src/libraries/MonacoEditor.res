open LazyUtils

type miniTypes = {enabled: bool}

type setOptions = {
  readOnly: bool,
  fontSize?: option<int>,
  fontFamily?: option<string>,
  fontWeight?: option<string>,
  minimap?: miniTypes,
  glyphMargin?: bool,
  scrollBeyondLastLine?: bool,
  automaticLayout?: bool,
  renderLineHighlight?: string,
  lineNumbersMinChars?: int,
  folding?: bool,
  contextmenu?: bool,
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
  onValidate?: array<array<JSON.t>> => unit,
  onMount?: Monaco.Editor.IStandaloneCodeEditor.t => unit,
  beforeMount?: Monaco.Setup.t => unit,
}

let make: props => React.element = reactLazy(() => {
  import_("@monaco-editor/react")
})

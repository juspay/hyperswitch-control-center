module MdPreview = {
  @react.component @module("@uiw/react-markdown-preview")
  external make: (~source: string, ~style: ReactDOM.Style.t=?) => React.element = "default"
}

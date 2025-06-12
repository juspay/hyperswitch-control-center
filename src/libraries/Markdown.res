module MDEditor = {
  @react.component @module("@uiw/react-md-editor")
  external make: (~value: string, ~hideToolbar: bool, ~preview: string) => React.element = "default"
}

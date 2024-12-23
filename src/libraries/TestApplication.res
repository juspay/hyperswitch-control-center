module TestApplicationApp = {
  @module("test-application/dist/my-react-library.js") @react.component
  external make: unit => React.element = "default"
}

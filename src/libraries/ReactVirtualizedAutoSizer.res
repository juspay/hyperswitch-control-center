type renderPropArgs = {
  width: int,
  height: int,
}

@module("react-virtualized-auto-sizer") @react.component
external make: (~children: renderPropArgs => React.element) => React.element = "default"

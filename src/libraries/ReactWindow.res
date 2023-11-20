module ListComponent = {
  type t

  @send
  external resetAfterIndex: (t, int, bool) => unit = "resetAfterIndex"
  @send
  external scrollToItem: (t, int, string) => unit = "scrollToItem"
}

module VariableSizeList = {
  @module("react-window") @react.component
  external make: (
    ~ref: ListComponent.t => unit=?,
    ~children: 'a => React.element=?,
    ~height: int=?,
    ~overscanCount: int=?,
    ~itemCount: int=?,
    ~itemSize: _ => int=?,
    ~width: int=?,
    ~layout: string=?,
  ) => React.element = "VariableSizeList"
}

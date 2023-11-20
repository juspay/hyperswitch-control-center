@react.component
let make: (
  ~name: string,
  ~size: int=?,
  ~className: string=?,
  ~themeBased: bool=?,
  ~onClick: ReactEvent.Mouse.t => unit=?,
  ~parentClass: string=?,
  ~customIconColor: string=?,
  ~customWidth: string=?,
  ~customHeight: string=?,
) => React.element

@react.component
let make: (
  ~labelText: string=?,
  ~showSubText: bool=?,
  ~subText: string=?,
  ~customStyle: string=?,
  ~onHoverEdit: bool=?,
  ~leftIcon: React.element=?,
  ~onSubmit: string => unit=?,
  ~customIconComponent: React.element=?,
  ~customInputStyle: string=?,
  ~customIconStyle: string=?,
  ~showEdit: bool=?,
) => React.element

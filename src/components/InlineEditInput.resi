module HoverInline: {
  @react.component
  let make: (
    ~customStyle: string=?,
    ~leftIcon: option<React.element>,
    ~value: string,
    ~subText: string,
    ~showEditIconOnHover: bool,
    ~leftActionButtons: React.element,
    ~labelTextCustomStyle: string,
    ~customWidth: string,
    ~showTooltipOnHover: bool=?,
  ) => React.element
}
@react.component
let make: (
  ~index: int=?,
  ~labelText: string=?,
  ~subText: string=?,
  ~customStyle: string=?,
  ~showEditIconOnHover: bool=?,
  ~leftIcon: React.element=?,
  ~onSubmit: string => 'a=?,
  ~customIconComponent: React.element=?,
  ~customInputStyle: string=?,
  ~customIconStyle: string=?,
  ~showEditIcon: bool=?,
  ~handleEdit: option<int> => unit,
  ~isUnderEdit: bool=?,
  ~displayHoverOnEdit: bool=?,
  ~validateInput: 'b => RescriptCore.Dict.t<'c>,
  ~labelTextCustomStyle: string=?,
  ~customWidth: string=?,
  ~handleClick: unit => unit=?,
  ~showTooltipOnHover: bool=?,
) => React.element

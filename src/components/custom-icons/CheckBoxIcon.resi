type size = Small | Large

@react.component
let make: (
  ~isSelected: bool,
  ~isDisabled: bool=?,
  ~setIsSelected: bool => unit=?,
  ~size: size=?,
  ~isSelectedStateMinus: bool=?,
  ~checkboxDimension: string=?,
  ~isCheckboxSelectedClass: bool=?,
  ~stopPropagationNeeded: bool=?,
) => React.element

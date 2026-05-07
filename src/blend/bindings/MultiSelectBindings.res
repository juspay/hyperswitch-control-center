type selectMenuItemAlignment =
  | @as("start") Start
  | @as("center") Center
  | @as("end") End

type selectMenuItemVariant =
  | @as("container") Container
  | @as("no-container") NoContainer

type selectMenuItemSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type selectMenuItemSide =
  | @as("top") Top
  | @as("left") Left
  | @as("right") Right
  | @as("bottom") Bottom

type selectionTagType =
  | @as("count") Count
  | @as("text") Text

type rec selectMenuItemType = {
  label: string,
  value: string,
  checked?: bool,
  subLabel?: string,
  slot1?: React.element,
  slot2?: React.element,
  slot3?: React.element,
  slot4?: React.element,
  disabled?: bool,
  alwaysSelected?: bool,
  onClick?: unit => unit,
  subMenu?: array<selectMenuItemType>,
  tooltip?: string,
  disableTruncation?: bool,
}

type selectMenuGroupType = {
  groupLabel?: string,
  items: array<selectMenuItemType>,
  showSeparator?: bool,
}

type actionButtonType = {
  text: string,
  onClick: array<string> => unit,
  disabled?: bool,
  loading?: bool,
}

type secondaryActionButtonType = {
  text: string,
  onClick: unit => unit,
  disabled?: bool,
  loading?: bool,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~height: int=?,
  ~selectedValues: array<string>,
  ~onChange: string => unit,
  ~items: array<selectMenuGroupType>,
  ~label: string=?,
  ~sublabel: string=?,
  ~disabled: bool=?,
  ~helpIconHintText: string=?,
  ~name: string=?,
  ~required: bool=?,
  ~variant: selectMenuItemVariant=?,
  ~selectionTagType: selectionTagType=?,
  ~slot: React.element=?,
  ~hintText: string=?,
  ~placeholder: string,
  ~size: selectMenuItemSize=?,
  ~enableSearch: bool=?,
  ~searchPlaceholder: string=?,
  ~enableSelectAll: bool=?,
  ~selectAllText: string=?,
  ~onSelectAll: bool => unit=?,
  ~maxSelections: int=?,
  ~customTrigger: React.element=?,
  ~useDrawerOnMobile: bool=?,
  ~minMenuWidth: int=?,
  ~maxMenuWidth: int=?,
  ~maxMenuHeight: int=?,
  ~alignment: selectMenuItemAlignment=?,
  ~side: selectMenuItemSide=?,
  ~sideOffset: int=?,
  ~alignOffset: int=?,
  ~inline: bool=?,
  ~onBlur: unit => unit=?,
  ~onFocus: unit => unit=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~showActionButtons: bool=?,
  ~primaryAction: actionButtonType=?,
  ~secondaryAction: secondaryActionButtonType=?,
  ~showItemDividers: bool=?,
  ~showHeaderBorder: bool=?,
  ~fullWidth: bool=?,
  ~allowCustomValue: bool=?,
  ~showClearButton: bool=?,
  ~onClearAllClick: unit => unit=?,
  ~enableVirtualization: bool=?,
  ~virtualListItemHeight: int=?,
) => React.element = "MultiSelect"

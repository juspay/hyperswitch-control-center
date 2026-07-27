type selectMenuSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

// Reuse variant type from MultiSelectBindings (same JS values)
type selectMenuVariant = MultiSelectBindings.selectMenuItemVariant

type skeletonProps = {
  count?: int,
  show?: bool,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~selected: string,
  ~onSelect: string => unit,
  ~items: array<MultiSelectBindings.selectMenuGroupType>,
  ~label: string=?,
  ~sublabel: string=?,
  ~disabled: bool=?,
  ~helpIconHintText: string=?,
  ~name: string=?,
  ~required: bool=?,
  ~variant: selectMenuVariant=?,
  ~slot: React.element=?,
  ~hintText: string=?,
  ~placeholder: string,
  ~size: selectMenuSize=?,
  ~enableSearch: bool=?,
  ~searchPlaceholder: string=?,
  ~allowDeselect: bool=?,
  ~customTrigger: React.element=?,
  ~useDrawerOnMobile: bool=?,
  ~minMenuWidth: int=?,
  ~maxMenuWidth: int=?,
  ~maxMenuHeight: int=?,
  ~alignment: MultiSelectBindings.selectMenuItemAlignment=?,
  ~side: MultiSelectBindings.selectMenuItemSide=?,
  ~sideOffset: int=?,
  ~alignOffset: int=?,
  ~inline: bool=?,
  ~onBlur: unit => unit=?,
  ~onFocus: unit => unit=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~showItemDividers: bool=?,
  ~showHeaderBorder: bool=?,
  ~fullWidth: bool=?,
  ~allowCustomValue: bool=?,
  ~skeleton: skeletonProps=?,
  ~maxTriggerWidth: float=?,
  ~minTriggerWidth: float=?,
) => React.element = "SingleSelect"

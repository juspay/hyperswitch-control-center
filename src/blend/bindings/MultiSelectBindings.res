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

type rec multiSelectV2ItemType = {
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
  subMenu?: array<multiSelectV2ItemType>,
  tooltip?: string,
  disableTruncation?: bool,
}

type multiSelectV2GroupType = {
  groupLabel?: string,
  items: array<multiSelectV2ItemType>,
  showSeparator?: bool,
}

// Retained for SingleSelect on main; V2 records above are independent.
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

type searchConfig = {show?: bool, placeholder?: string}
type menuDimensions = {minWidth?: int, maxWidth?: int, maxHeight?: int}
type triggerDimensions = {width?: string, minWidth?: string, maxWidth?: string}
type menuPosition = {
  alignment?: selectMenuItemAlignment,
  side?: selectMenuItemSide,
  sideOffset?: int,
  alignOffset?: int,
}
type errorState = {show?: bool, message?: string}

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
  ~selectedValues: array<string>,
  ~onSelectionChange: array<string> => unit,
  ~items: array<multiSelectV2GroupType>,
  ~label: string=?,
  ~subLabel: string=?,
  ~disabled: bool=?,
  ~helpIconText: string=?,
  ~name: string=?,
  ~required: bool=?,
  ~variant: selectMenuItemVariant=?,
  ~selectionTagType: selectionTagType=?,
  ~slot: React.element=?,
  ~hintText: string=?,
  ~placeholder: string,
  ~size: selectMenuItemSize=?,
  ~search: searchConfig=?,
  ~enableSelectAll: bool=?,
  ~selectAllText: string=?,
  ~maxSelections: int=?,
  ~customTrigger: React.element=?,
  ~usePanelOnMobile: bool=?,
  ~menuDimensions: menuDimensions=?,
  ~triggerDimensions: triggerDimensions=?,
  ~menuPosition: menuPosition=?,
  ~inline: bool=?,
  ~onBlur: unit => unit=?,
  ~onFocus: unit => unit=?,
  ~error: errorState=?,
  ~showActionButtons: bool=?,
  ~primaryAction: actionButtonType=?,
  ~secondaryAction: secondaryActionButtonType=?,
  ~showItemDividers: bool=?,
  ~showHeaderBorder: bool=?,
  ~allowCustomValue: bool=?,
  ~showClearButton: bool=?,
  ~onClearAllClick: unit => unit=?,
  ~enableVirtualization: bool=?,
  ~virtualListItemHeight: int=?,
  ~menuFooter: React.element=?,
) => React.element = "MultiSelectV2"

// React 18 needs a native trigger so Radix receives its anchor ref.
module Trigger = {
  let make = (
    ~items: array<multiSelectV2GroupType>,
    ~selectedValues: array<string>,
    ~placeholder: string,
    ~disabled: bool=false,
    ~id: option<string>=?,
    ~label: option<string>=?,
    ~error=false,
    ~errorMessage: option<string>=?,
    ~onFocus: option<unit => unit>=?,
    ~onBlur: option<unit => unit>=?,
    ~slot: option<React.element>=?,
    ~fullWidth: bool=false,
    ~height: option<int>=?,
    ~size: selectMenuItemSize=Md,
    ~selectionTagType: selectionTagType=Count,
    (),
  ) => {
    let labels =
      items
      ->Array.flatMap(group => group.items)
      ->Array.filter(item => selectedValues->Array.includes(item.value))
      ->Array.map(item => item.label)
    let text =
      labels->Array.length === 0
        ? placeholder
        : selectionTagType === Text
        ? labels->Array.joinWith(", ")
        : `${placeholder} (${selectedValues->Array.length->Int.toString})`
    let padding = switch size {
    | Sm => "px-2 py-1.5"
    | Md => "px-3 py-2"
    | Lg => "px-4 py-3"
    }
    // Keep the selector independent of the selected count or text summary.
    let trigger =
      <button
        type_="button"
        ?id
        ariaLabel=text
        ariaLabelledby=?{label
        ->Option.flatMap(LogicUtils.getNonEmptyString)
        ->Option.flatMap(_ => id->Option.map(id => `${id}-label`))}
        ariaInvalid={error ? #"true" : #"false"}
        ariaDescribedby=?{error
          ? errorMessage
            ->Option.flatMap(LogicUtils.getNonEmptyString)
            ->Option.flatMap(_ => id->Option.map(id => `${id}-error`))
          : None}
        onFocus={_ => onFocus->Option.forEach(callback => callback())}
        onBlur={_ => onBlur->Option.forEach(callback => callback())}
        style={ReactDOM.Style.make(~height=?height->Option.map(v => `${v->Int.toString}px`), ())}
        disabled
        className={`flex items-center justify-between gap-2 border border-nd_br_gray-200 rounded-lg bg-nd_gray-0 dark:bg-nd_gray-800 text-nd_gray-800 dark:text-nd_gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-nd_primary_blue-500 ${padding} ${Typography.body.md.regular} text-left min-w-0 ${fullWidth
            ? "w-full"
            : ""}`}>
        {slot->Option.getOr(React.null)}
        <span className="truncate flex-1"> {React.string(text)} </span>
        <Icon name="chevron-down" size=12 />
      </button>
    // Clone the native element directly: a component wrapper would swallow Radix props/ref.
    React.cloneElement(trigger, Dict.fromArray([("data-id", placeholder)]))
  }
}

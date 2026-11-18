type selectMenuSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

// Reuse variant type from MultiSelectBindings (same JS values)
type selectMenuVariant = MultiSelectBindings.selectMenuItemVariant

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
type menuPosition = {
  alignment?: MultiSelectBindings.selectMenuItemAlignment,
  side?: MultiSelectBindings.selectMenuItemSide,
  sideOffset?: int,
  alignOffset?: int,
}
type menuDimensions = {minWidth?: int, maxWidth?: int, maxHeight?: int}
type triggerDimensions = {minWidth?: float, maxWidth?: float, width?: string}
type errorState = {show?: bool, message?: string}

type skeletonProps = {
  count?: int,
  show?: bool,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~selected: string,
  ~onSelect: string => unit,
  ~items: array<selectMenuGroupType>,
  ~label: string=?,
  ~subLabel: string=?,
  ~disabled: bool=?,
  ~helpIconText: string=?,
  ~name: string=?,
  ~required: bool=?,
  ~variant: selectMenuVariant=?,
  ~slot: React.element=?,
  ~hintText: string=?,
  ~placeholder: string,
  ~size: selectMenuSize=?,
  ~search: searchConfig=?,
  ~customTrigger: React.element=?,
  ~usePanelOnMobile: bool=?,
  ~menuDimensions: menuDimensions=?,
  ~menuPosition: menuPosition=?,
  ~inline: bool=?,
  ~onBlur: unit => unit=?,
  ~onFocus: unit => unit=?,
  ~error: errorState=?,
  ~allowCustomValue: bool=?,
  ~skeleton: skeletonProps=?,
  ~triggerDimensions: triggerDimensions=?,
  ~menuFooter: React.element=?,
) => React.element = "SingleSelectV2"

// Blend 0.0.38's default V2 trigger does not forward its ref on React 18.
// A native custom trigger gives Radix a working anchor without retaining V1.
module Trigger = {
  let make = (
    ~items: array<selectMenuGroupType>,
    ~selected: string,
    ~placeholder: string,
    ~disabled=false,
    ~id: option<string>=?,
    ~label: option<string>=?,
    ~onFocus: option<unit => unit>=?,
    ~onBlur: option<unit => unit>=?,
    ~slot: option<React.element>=?,
    ~fullWidth=false,
    ~minWidth: option<float>=?,
    ~maxWidth: option<float>=?,
    ~size: selectMenuSize=Md,
    (),
  ) => {
    let selectedItem =
      items->Array.flatMap(group => group.items)->Array.find(item => item.value === selected)
    let text =
      selectedItem
      ->Option.map(item => item.label)
      ->Option.getOr(selected === "" ? placeholder : selected)
    <button
      type_="button"
      disabled
      ?id
      ariaLabel=text
      ariaLabelledby=?{label
      ->Option.flatMap(LogicUtils.getNonEmptyString)
      ->Option.flatMap(_ => id->Option.map(id => `${id}-label`))}
      onFocus={_ => onFocus->Option.forEach(callback => callback())}
      onBlur={_ => onBlur->Option.forEach(callback => callback())}
      className={`flex items-center justify-between gap-2 rounded-lg border border-nd_br_gray-200 bg-nd_gray-0 dark:bg-nd_gray-800 px-3 ${Typography.body.md.regular} text-nd_gray-800 dark:text-nd_gray-100 disabled:opacity-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-nd_primary_blue-500 ${fullWidth
          ? "w-full"
          : ""} ${size === Sm ? "h-8" : size === Lg ? "h-11" : "h-9"}`}
      style={ReactDOM.Style.make(
        ~minWidth=?minWidth->Option.map(v => `${v->Float.toString}px`),
        ~maxWidth=?maxWidth->Option.map(v => `${v->Float.toString}px`),
        (),
      )}>
      // Blend 0.0.38 does not put its generated label ID on InputLabels.
      {label
      ->Option.flatMap(LogicUtils.getNonEmptyString)
      ->Option.map(text =>
        <span id=?{id->Option.map(id => `${id}-label`)} className="sr-only">
          {text->React.string}
        </span>
      )
      ->Option.getOr(React.null)}
      {slot->Option.getOr(React.null)}
      <span className="truncate text-left"> {text->React.string} </span>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" ariaHidden=true>
        <path d="m6 9 6 6 6-6" stroke="currentColor" strokeWidth="1.5" />
      </svg>
    </button>
    // Keep the selector on the native node so Radix still receives its anchor ref.
    ->React.cloneElement(Dict.fromArray([("data-element", "single-select-button")]))
  }
}

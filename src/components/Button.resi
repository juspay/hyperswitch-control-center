type buttonState = Normal | Loading | Disabled | NoHover | Focused
type buttonVariant = Fit | Long | Full | Rounded
type buttonType =
  | Primary
  | Secondary
  | PrimaryOutline
  | SecondaryFilled
  | NonFilled
  | Pagination
  | Pill
  | FilterAdd
  | Delete
  | Transparent
  | SelectTransparent
  | DarkBluePrimary
  | BrownButton
  | GreyButton
  | DarkBlueSecondary
  | ArdraPagination
  | UpiPaginator
  | DarkPurple
  | Dropdown
  | LightBlue
  | ArdraDefaultBlue
type buttonSize = Large | Medium | Small | XSmall
type iconType =
  | FontAwesome(string)
  | CustomIcon(React.element)
  | CustomRightIcon(React.element)
  | Euler(string)
  | NoIcon
type badgeColor =
  | BadgeGreen
  | BadgeRed
  | BadgeBlue
  | BadgeGray
  | BadgeOrange
  | BadgeYellow
  | BadgeDarkGreen
  | BadgeDarkRed
  | BadgeBrown
  | NoBadge
type badge = {value: string, color: badgeColor}
let getBGColor: (
  ~buttonType: buttonType,
  ~buttonState: buttonState,
  ~showBorder: bool,
  ~isDropdownOpen: bool=?,
  ~isPhoneDropdown: bool=?,
  unit,
) => string
let useGetBgColor: (
  ~buttonType: buttonType,
  ~buttonState: buttonState,
  ~showBorder: bool,
  ~isDropdownOpen: bool=?,
  ~isPhoneDropdown: bool=?,
  unit,
) => string
let getTextColor: (
  ~buttonType: buttonType,
  ~buttonState: buttonState,
  ~showBorder: bool,
  ~isDropdownOpen: bool=?,
  ~isPhoneDropdown: bool=?,
  unit,
) => string
let useGetTextColor: (
  ~buttonType: buttonType,
  ~buttonState: buttonState,
  ~showBorder: bool,
  ~isDropdownOpen: bool=?,
  ~isPhoneDropdown: bool=?,
  unit,
) => string
@react.component
let make: (
  ~buttonFor: string=?,
  ~loadingText: string=?,
  ~buttonState: buttonState=?,
  ~text: string=?,
  ~isSelectBoxButton: bool=?,
  ~buttonType: buttonType=?,
  ~isDropdownOpen: bool=?,
  ~buttonVariant: buttonVariant=?,
  ~buttonSize: buttonSize=?,
  ~leftIcon: iconType=?,
  ~rightIcon: iconType=?,
  ~showBorder: bool=?,
  ~type_: string=?,
  ~flattenBottom: bool=?,
  ~flattenTop: bool=?,
  ~onEnterPress: bool=?,
  ~onClick: JsxEvent.Mouse.t => unit=?,
  ~textStyle: string=?,
  ~iconColor: string=?,
  ~iconBorderColor: string=?,
  ~customIconMargin: string=?,
  ~customTextSize: string=?,
  ~customIconSize: int=?,
  ~textWeight: string=?,
  ~fullLength: bool=?,
  ~disableRipple: bool=?,
  ~customButtonStyle: string=?,
  ~textStyleClass: string=?,
  ~customTextPaddingClass: string=?,
  ~allowButtonTextMinWidth: bool=?,
  ~badge: badge=?,
  ~buttonRightText: string=?,
  ~ellipsisOnly: bool=?,
  ~isRelative: bool=?,
  ~customPaddingClass: string=?,
  ~customRoundedClass: string=?,
  ~customHeightClass: string=?,
  ~customBackColor: string=?,
  ~isPhoneDropdown: bool=?,
  ~showBtnTextToolTip: bool=?,
  ~showTooltip: bool=?,
  ~tooltipText: Js.String2.t=?,
  ~toolTipPosition: ToolTip.toolTipPosition=?,
) => React.element

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
type badge = {
  value: string,
  color: badgeColor,
}

let getBGColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
  (),
) =>
  switch buttonType {
  | Primary =>
    switch buttonState {
    | Focused
    | Normal => "bg-blue-900 hover:bg-blue-primary_hover focus:outline-none"
    | Loading => "bg-blue-900"
    | Disabled => "bg-blue-700 opacity-60 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "bg-blue-900 hover:bg-blue-primary_hover focus:outline-none dark:text-opacity-50 text-opacity-50"
    }
  | PrimaryOutline => "mix-blend-normal"

  | SecondaryFilled =>
    switch buttonState {
    | Focused
    | Normal => "bg-gradient-to-b from-jp-gray-450 to-jp-gray-350 dark:from-jp-gray-950 dark:to-jp-gray-950 hover:shadow dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
    | Loading => "bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"
    | Disabled => "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "bg-gradient-to-b overflow-x-scroll from-jp-gray-200 to-jp-gray-300 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:gray-text_darktheme focus:outline-none dark:text-opacity-50 text-opacity-50"
    }

  | NonFilled =>
    switch buttonState {
    | Focused
    | Normal => "hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
    | Loading => "bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"
    | Disabled => "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "hover:bg-jp-gray-600 hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 dark:text-jp-gray-text_darktheme focus:outline-none dark:text-opacity-50 text-opacity-50"
    }
  | FilterAdd =>
    switch buttonState {
    | Focused
    | Normal => "hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 text-blue-800 dark:text-blue-800 dark:text-opacity-100 focus:outline-none"
    | Loading => "bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"
    | Disabled => "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "hover:bg-jp-gray-600 hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 dark:text-blue-800  focus:outline-none dark:text-opacity-100 text-opacity-50"
    }
  | Pagination =>
    switch buttonState {
    | Focused
    | Normal => "border-left-1 opacity-80 border-right-1 font-normal border-left-1 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 focus:outline-none"

    | Loading => "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"

    | Disabled => "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"

    | NoHover => "bg-white border-left-1 border-right-1 font-normal text-jp-gray-900 text-opacity-75 hover:text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    }
  | ArdraPagination =>
    switch buttonState {
    | Focused
    | Normal => "!border-[0.5px] !h-7 !w-7 font-semibold text-ardra-primary-100 hover:text-jp-gray-900 hover:border-[#8C8E9D] bg-white dark:text-jp-gray-text_darktheme focus:outline-none mr-2.5 rounded"
    | Loading => "!border-[0.5px] !h-7 !w-7 font-semibold bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10 mr-2.5"
    | Disabled => "!border-[0.5px] !h-7 !w-7 font-semibold text-jp-gray-600 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50 mr-2.5"
    | NoHover => "!border-[0.5px] !h-7  !w-7 font-semibold text-jp-gray-100 hover:text-jp-gray-100 bg-ardra-primary-100 dark:text-jp-gray-text_darktheme focus:outline-none mr-2.5 rounded"
    }
  | Dropdown => {
      let hoverCss = isPhoneDropdown ? "" : "hover:bg-jp-2-light-gray-100"
      let color = if isDropdownOpen {
        showBorder
          ? "bg-jp-2-light-gray-100 shadow-jp-2-sm-gray-focus"
          : isPhoneDropdown
          ? "bg-transparent"
          : "bg-jp-2-light-gray-100"
      } else if isPhoneDropdown {
        ""
      } else {
        "bg-white"
      }

      switch buttonState {
      | Disabled => "bg-gray-200 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
      | _ => `${color} ${hoverCss} focus:outline-none dark:active:shadow-none`
      }
    }

  | Secondary =>
    switch buttonState {
    | Focused
    | Normal =>
      showBorder
        ? "bg-jp-gray-button_gray text-jp-gray-900 text-opacity-75 hover:bg-jp-gray-secondary_hover hover:text-jp-gray-890  dark:bg-jp-gray-darkgray_background  dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
        : "text-jp-gray-900 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-40 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 dark:hover:bg-jp-gray-950 focus:outline-none"
    | Loading =>
      showBorder
        ? "bg-jp-gray-button_gray  dark:bg-jp-gray-darkgray_background"
        : "bg-jp-gray-lightmode_steelgray bg-opacity-40 dark:bg-jp-gray-950 dark:bg-opacity-100"
    | Disabled => showBorder ? "bg-jp-gray-300 dark:bg-gray-800 dark:bg-opacity-10" : "px-4"
    | NoHover => "bg-jp-gray-button_gray text-jp-gray-900 text-opacity-50  hover:bg-jp-gray-secondary_hover hover:text-jp-gray-890  dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme focus:outline-none dark:text-opacity-50 "
    }
  | Pill =>
    switch buttonState {
    | Focused
    | Normal => "bg-white text-jp-gray-900 text-opacity-50 hover:shadow hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
    | Loading =>
      showBorder
        ? "bg-white dark:bg-jp-gray-darkgray_background"
        : "bg-jp-gray-600 bg-opacity-40 dark:bg-jp-gray-950 dark:bg-opacity-100"
    | Disabled =>
      showBorder
        ? "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
        : "px-4"
    | NoHover => "bg-white text-jp-gray-900 text-opacity-50 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
    }

  | UpiPaginator => "bg-blue-100 text-jp-gray-900 text-opacity-50 hover:shadow hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
  | Delete =>
    switch buttonState {
    | Focused
    | Normal => "bg-red-960   hover:from-red-960 hover:to-red-950 focus:outline-none"
    | Loading => "bg-red-960"
    | Disabled => "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "bg-gradient-to-t from-red-960 to-red-800  hover:from-red-960 hover:to-red-960 focus:outline-none dark:text-opacity-50 text-opacity-50"
    }

  | Transparent =>
    switch buttonState {
    | Focused
    | Normal => "bg-gray-50   hover:bg-gray-200 dark:bg-jp-gray-darkgray_background focus:outline-none"
    | Loading => "bg-gray-50   hover:bg-gray-200 focus:outline-none"
    | Disabled => "bg-gray-50   hover:bg-gray-200 dark:bg-jp-gray-darkgray_background focus:outline-none"
    | NoHover => "bg-gray-50   hover:bg-gray-200 focus:outline-none"
    }

  | SelectTransparent =>
    switch buttonState {
    | Focused
    | Normal => "bg-blue-100   hover:bg-blue-200  dark:bg-black focus:outline-none"
    | Loading => "bg-gray-100   hover:bg-blue-200 focus:outline-none"
    | Disabled => "bg-gray-100   hover:bg-blue-200 focus:outline-none"
    | NoHover => "bg-gray-100   hover:bg-blue-200 focus:outline-none"
    }
  | DarkBluePrimary =>
    switch buttonState {
    | Focused
    | Normal => "bg-ardra-primary-100  hover:bg-ardra-primary-200  dark:bg-black focus:outline-none"
    | Loading => "bg-ardra-primary-100  hover:bg-ardra-primary-200 focus:outline-none"
    | Disabled => "bg-ardra-secondary-200  hover:bg-ardra-secondary-200 focus:outline-none"
    | NoHover => "bg-ardra-primary-100  hover:bg-ardra-primary-200 focus:outline-none"
    }
  | BrownButton => "bg-ardra-brown"
  | GreyButton => "bg-ardra-secondary-400"
  | DarkBlueSecondary =>
    switch buttonState {
    | Focused
    | Normal => "bg-jp-gray-200  hover:bg-jp-gray-300  dark:bg-black focus:outline-none"
    | Loading => "bg-jp-gray-200  hover:bg-jp-gray-300  dark:bg-black focus:outline-none"
    | Disabled => "bg-ardra-secondary-200  hover:bg-ardra-secondary-200 focus:outline-none"
    | NoHover => "bg-ardra-primary-100  hover:bg-ardra-primary-200 focus:outline-none"
    }
  | DarkPurple =>
    switch buttonState {
    | Focused
    | Normal => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | Loading => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | Disabled => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | NoHover => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    }
  | LightBlue =>
    switch buttonState {
    | Focused
    | Normal => "bg-ardra-light-blue border-ardra-approve-text dark:bg-black focus:outline-none"
    | Loading => "bg-ardra-light-blue border-ardra-approve-text focus:outline-none"
    | Disabled => "bg-ardra-light-blue border-ardra-approve-text dark:bg-black focus:outline-none"
    | NoHover => "bg-ardra-light-blue border-ardra-approve-text focus:outline-none"
    }
  | ArdraDefaultBlue =>
    switch buttonState {
    | Focused
    | Normal => "primary-gradient dark:bg-black focus:outline-none"
    | Loading => "primary-gradient dark:bg-black focus:outline-none"
    | Disabled => "bg-jp-2-light-gray-600  dark:bg-black focus:outline-none"
    | NoHover => "primary-gradient focus:outline-none"
    }
  }

let useGetBgColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
  (),
) => {
  getBGColor(~buttonType, ~buttonState, ~showBorder, ~isDropdownOpen, ~isPhoneDropdown, ())
}

let getTextColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
  (),
) =>
  switch buttonType {
  | Primary =>
    switch buttonState {
    | Disabled => "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
    | _ => "text-white"
    }
  | PrimaryOutline => "text-blue-800"

  | FilterAdd => "text-blue-800"
  | Delete => "text-white"
  | Transparent => "text-gray-400"
  | SelectTransparent => "text-blue-800"
  | Dropdown =>
    switch buttonState {
    | Disabled => "text-jp-2-light-gray-600"
    | Loading => "text-jp-2-light-gray-600"
    | _ =>
      if isDropdownOpen {
        showBorder || isPhoneDropdown ? "text-jp-2-light-gray-2000" : "text-jp-2-light-gray-1700"
      } else {
        "text-jp-2-light-gray-1200 hover:text-jp-2-light-gray-2000"
      }
    }
  | Secondary =>
    switch buttonState {
    | Disabled => "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
    | Loading => "text-jp-gray-950 hover:text-black dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    | _ => "text-jp-gray-950 hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75"
    }
  | SecondaryFilled =>
    switch buttonState {
    | Disabled => "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
    | Loading => "text-jp-gray-800 hover:text-black dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    | _ => "text-jp-gray-800 hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75"
    }
  | DarkBluePrimary => "text-white"
  | BrownButton => "text-white"
  | GreyButton => "text-black"
  | DarkBlueSecondary => "text-ardra-primary-100"
  | DarkPurple => "text-white"
  | ArdraPagination => "text-ardra-primary-100 !p-0"
  | LightBlue => "text-ardra-approve-text"
  | ArdraDefaultBlue => "text-white"

  | _ =>
    switch buttonState {
    | Disabled => "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
    | Loading =>
      showBorder
        ? "text-jp-gray-900 text-opacity-50 hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75"
        : "text-jp-gray-900 text-opacity-50 hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    | _ => "text-jp-gray-900 text-opacity-50 hover:text-opacity-100 dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75"
    }
  }

let useGetTextColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
  (),
) => {
  getTextColor(~buttonType, ~buttonState, ~showBorder, ~isDropdownOpen, ~isPhoneDropdown, ())
}

@react.component
let make = (
  ~buttonFor="",
  ~loadingText="Loading..",
  ~buttonState: buttonState=Normal,
  ~text=?,
  ~isSelectBoxButton=false,
  ~buttonType: buttonType=SecondaryFilled,
  ~isDropdownOpen=false,
  ~buttonVariant: buttonVariant=Fit,
  ~buttonSize: option<buttonSize>=?,
  ~leftIcon: iconType=NoIcon,
  ~rightIcon: iconType=NoIcon,
  ~showBorder=true,
  ~type_="button",
  ~flattenBottom=false,
  ~flattenTop=false,
  ~onEnterPress=true,
  ~onClick=?,
  ~textStyle="",
  ~iconColor="",
  ~iconBorderColor="",
  ~customIconMargin=?,
  ~customTextSize=?,
  ~customIconSize=?,
  ~textWeight=?,
  ~fullLength=false,
  ~disableRipple=false,
  ~customButtonStyle="",
  ~textStyleClass=?,
  ~customTextPaddingClass=?,
  ~allowButtonTextMinWidth=true,
  ~badge: badge={
    value: 1->Belt.Int.toString,
    color: NoBadge,
  },
  ~buttonRightText=?,
  ~ellipsisOnly=false,
  ~isRelative=true,
  ~customPaddingClass=?,
  ~customRoundedClass=?,
  ~customHeightClass=?,
  ~customBackColor=?,
  ~isPhoneDropdown=false,
  ~showBtnTextToolTip=false,
) => {
  let parentRef = React.useRef(Js.Nullable.null)
  let dummyRef = React.useRef(Js.Nullable.null)
  let buttonRef = disableRipple ? dummyRef : parentRef
  let rippleEffect = RippleEffectBackground.useHorizontalRippleHook(buttonRef)
  if !isPhoneDropdown {
    rippleEffect
  }

  let customTextOverFlowClass = switch textStyleClass {
  | Some(val) => val
  | None => "overflow-hidden"
  }

  // Hyperswitch doesn't have use case of some btn type variant
  // overridding the variant with a used type
  let buttonType = switch buttonType {
  | SecondaryFilled => Secondary
  | _ => buttonType
  }

  let buttonSize: buttonSize =
    buttonSize->Belt.Option.getWithDefault(
      MatchMedia.useMatchMedia("(max-width: 800px)") ? Small : Medium,
    )

  let lengthStyle = if fullLength {
    "w-full justify-between"
  } else {
    ""
  }

  let badgeColor = switch buttonState {
  | Disabled => "bg-slate-300"
  | _ =>
    switch badge.color {
    | BadgeGreen => "bg-green-950 dark:bg-opacity-50"
    | BadgeRed => "bg-red-960 dark:bg-opacity-50"
    | BadgeBlue => "bg-blue-800 dark:bg-opacity-50"
    | BadgeGray => "bg-blue-table_gray"
    | BadgeOrange => "bg-orange-950 dark:bg-opacity-50"
    | BadgeYellow => "bg-blue-table_yellow"
    | BadgeDarkGreen => "bg-green-800"
    | BadgeDarkRed => "bg-red-400"
    | BadgeBrown => "bg-ardra-brown"
    | NoBadge => "hidden"
    }
  }

  let badgeTextColor = switch buttonState {
  | Disabled => "text-white"
  | _ =>
    switch badge.color {
    | BadgeGray => "text-jp-gray-900"
    | BadgeYellow => "text-jp-gray-900"
    | _ => "text-white"
    }
  }

  let heightClass = customHeightClass->Belt.Option.getWithDefault({
    switch buttonSize {
    | XSmall => "h-fit"
    | Small => "h-fit"
    | Medium | Large => "h-fit"
    }
  })

  let cursorType = switch buttonState {
  | Loading => "cursor-wait"
  | Disabled => "cursor-not-allowed"
  | _ => "cursor-pointer"
  }

  let paddingClass = customPaddingClass->Belt.Option.getWithDefault(
    switch buttonSize {
    | XSmall => "py-3 px-4"
    | Small =>
      switch buttonType {
      | Pagination => "py-3 px-4 mr-1"
      | Dropdown => "py-3 px-4"
      | _ => "py-3 px-4"
      }
    | Medium => buttonType == Pagination ? "py-3 px-4 mr-1" : "py-3 px-4"
    | Large => "py-3 px-4"
    },
  )

  let textPaddingClass = customTextPaddingClass->Belt.Option.getWithDefault(
    switch buttonSize {
    | XSmall => "px-1"
    | Small => "px-1"
    | Medium => "px-1"
    | Large => "px-1"
    },
  )

  let textSize = customTextSize->Belt.Option.getWithDefault(
    switch buttonSize {
    | XSmall => "text-fs-11"
    | Small => "text-fs-13"
    | Medium => "text-body"
    | Large => "text-fs-16"
    },
  )

  let ellipsisClass = ellipsisOnly ? "truncate" : ""
  let ellipsisParentClass = ellipsisOnly ? "max-w-[250px] md:max-w-xs" : ""

  let iconSize = customIconSize->Belt.Option.getWithDefault(
    switch buttonSize {
    | XSmall => 12
    | Small => 14
    | Medium => 16
    | Large => 18
    },
  )

  let strokeColor = ""

  let iconPadding = switch buttonSize {
  | XSmall
  | Small => "pl-1"
  | Medium
  | Large => ""
  }

  let eulerIconPadding = switch buttonSize {
  | XSmall
  | Small => "gap-1"
  | Medium
  | Large => ""
  }

  let iconMargin = customIconMargin->Belt.Option.getWithDefault(
    switch buttonSize {
    | XSmall
    | Small => "ml-1"
    | Medium
    | Large => "mx-1"
    },
  )

  let rightIconSpacing = switch buttonSize {
  | XSmall
  | Small => "mt-0.5 px-1"
  | Medium
  | Large => "mx-1 mt-0.5"
  }

  let badgeSpacing = switch buttonSize {
  | XSmall
  | Small => "px-2 mb-0.5 mr-0.5"
  | Medium
  | Large => "px-2 mb-1 mr-0.5"
  }
  let badgeTextSize = switch buttonSize {
  | XSmall
  | Small => "text-sm"
  | Medium
  | Large => "text-base"
  }

  let backColor = useGetBgColor(
    ~buttonType,
    ~buttonState,
    ~showBorder,
    ~isDropdownOpen,
    ~isPhoneDropdown,
    (),
  )

  let textColor = useGetTextColor(
    ~buttonType,
    ~buttonState,
    ~showBorder,
    ~isDropdownOpen,
    ~isPhoneDropdown,
    (),
  )

  let defaultRoundedClass = "rounded"

  let {isFirst, isLast} = React.useContext(ButtonGroupContext.buttonGroupContext)
  let roundedClass = {
    let roundedBottom = flattenBottom ? "rounded-b-none" : ""
    let roundedTop = flattenTop ? "rounded-t-none" : ""
    let roundedDirection = if isFirst && isLast {
      defaultRoundedClass
    } else if isFirst {
      "rounded-l-md"
    } else if isLast {
      "rounded-r-md"
    } else if buttonType == Pagination {
      "rounded-md"
    } else {
      ""
    }
    `${roundedDirection} ${roundedBottom} ${roundedTop}`
  }

  let borderStyle = {
    let borderWidth = if showBorder || (buttonType === Dropdown && !(isFirst && isLast)) {
      if isFirst && isLast {
        "border"
      } else if isFirst {
        "border focus:border-r"
      } else if isLast {
        "border  focus:border-l"
      } else {
        "border border-x-1 focus:border-x"
      }
    } else {
      "border-0"
    }
    switch buttonType {
    | Primary =>
      switch buttonState {
      | Disabled => ""
      | _ =>
        if showBorder {
          `${borderWidth} border-blue-850`
        } else {
          ""
        }
      }
    | PrimaryOutline => "border-2 border-blue-800"
    | Dropdown
    | Secondary =>
      showBorder
        ? switch buttonState {
          | Disabled => ""
          | Loading => `${borderWidth} border-border_gray`
          | _ =>
            `${borderWidth} border-border_gray border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100`
          }
        : switch buttonState {
          | Disabled => ""
          | Loading => borderWidth
          | _ => borderWidth
          }

    | SecondaryFilled =>
      switch buttonState {
      | Disabled => ""
      | Loading =>
        `${borderWidth} border-jp-gray-600 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-100 `
      | _ => `${borderWidth} border-jp-gray-500 dark:border-jp-gray-960`
      }

    | Pill =>
      showBorder
        ? {
            switch buttonState {
            | Disabled => ""
            | Loading =>
              `${borderWidth} border-jp-gray-600 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-100`
            | _ => `${borderWidth} border-jp-gray-500 dark:border-jp-gray-960`
            }
          }
        : {
            switch buttonState {
            | Disabled => ""
            | Loading => borderWidth
            | _ => borderWidth
            }
          }

    | FilterAdd => "border-0"
    | SelectTransparent => "border border-1 border-blue-900"
    | Transparent => "border border-jp-2-light-gray-400"
    | Delete =>
      switch buttonState {
      | Disabled => ""
      | Loading =>
        `${borderWidth} border-jp-gray-600 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-100 `
      | _ => `${borderWidth} border-jp-gray-500 dark:border-jp-gray-960`
      }
    | _ =>
      switch buttonState {
      | Disabled => ""
      | Loading =>
        `${borderWidth} border-jp-gray-600 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-100 `
      | _ => `${borderWidth} border-jp-gray-500 dark:border-jp-gray-960`
      }
    }
  }

  let dis = switch buttonState {
  | Focused
  | Normal => false
  | NoHover => false
  | _ => true
  }

  let loaderIconColor = switch buttonType {
  | Primary => Some("text-white")
  | _ => None
  }
  let handleClick = ev => {
    switch onClick {
    | Some(fn) => fn(ev)
    | None => ()
    }
  }

  let textWeight = switch textWeight {
  | Some(weight) => weight
  | _ => "text-sm font-medium leading-5"
  }

  let textId = text->Belt.Option.getWithDefault("")
  let iconId = switch leftIcon {
  | FontAwesome(iconName)
  | Euler(iconName) => iconName
  | CustomIcon(_) => "CustomIcon"
  | CustomRightIcon(_) => "CustomRightIcon"
  | NoIcon =>
    switch rightIcon {
    | FontAwesome(iconName)
    | Euler(iconName) => iconName
    | CustomIcon(_) => "CustomIcon"
    | NoIcon => ""
    | CustomRightIcon(_) => "CustomRightIcon"
    }
  }

  let dataAttrKey = isSelectBoxButton ? "data-value" : "data-button-for"
  let dataAttrStr =
    textId === "" ? iconId : textId->String.concat(buttonFor)->LogicUtils.toCamelCase
  let relativeClass = isRelative ? "relative" : ""
  let conditionalButtonStyles = `${allowButtonTextMinWidth
      ? "min-w-min"
      : ""} ${customBackColor->Belt.Option.getWithDefault(
      backColor,
    )} ${customRoundedClass->Belt.Option.getWithDefault(roundedClass)}`

  let newThemeGap = ""

  <AddDataAttributes attributes=[(dataAttrKey, dataAttrStr)]>
    <button
      type_
      disabled=dis
      ref={parentRef->ReactDOM.Ref.domRef}
      onKeyUp={e => e->ReactEvent.Keyboard.preventDefault}
      onKeyPress={e => {
        if !onEnterPress {
          e->ReactEvent.Keyboard.preventDefault
        }
      }}
      className={`flex group ${customButtonStyle->String.includes("justify")
          ? ""
          : "justify-center"} ${relativeClass} ${heightClass} ${newThemeGap} ${conditionalButtonStyles} items-center ${borderStyle}  ${textColor} ${cursorType} ${paddingClass} ${lengthStyle} ${customButtonStyle}  ${customTextOverFlowClass}`}
      onClick=handleClick>
      {if buttonState == Loading {
        <span className={iconPadding}>
          <span className={`flex items-center mx-2 animate-spin`}>
            <Loadericon size=iconSize iconColor=?loaderIconColor />
          </span>
        </span>
      } else {
        switch leftIcon {
        | FontAwesome(iconName) =>
          <span className={`flex items-center ${iconColor} ${iconMargin} ${iconPadding}`}>
            <Icon
              className={`align-middle ${strokeColor} ${iconBorderColor}`}
              size=iconSize
              name=iconName
            />
          </span>
        | Euler(iconName) =>
          <span className={`flex items-center ${iconColor} ${iconMargin} ${eulerIconPadding}`}>
            <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
          </span>
        | CustomIcon(element) =>
          <span className={`flex items-center ${iconMargin}`}> {element} </span>
        | _ => React.null
        }
      }}
      {switch text {
      | Some(textStr) =>
        if textStr !== "" {
          let btnContent =
            <AddDataAttributes attributes=[("data-button-text", textStr)]>
              <div
                className={`${textPaddingClass} ${textSize} ${textWeight} ${ellipsisClass} whitespace-pre ${textStyle}`}>
                {buttonState == Loading ? React.string(loadingText) : React.string(textStr)}
              </div>
            </AddDataAttributes>

          if showBtnTextToolTip {
            <div className=ellipsisParentClass>
              <ToolTip
                description=textStr
                toolTipFor=btnContent
                contentAlign=Default
                justifyClass="justify-start"
              />
            </div>
          } else {
            <div className=ellipsisParentClass> btnContent </div>
          }
        } else {
          React.null
        }

      | None => React.null
      }}
      {switch badge.color {
      | NoBadge => React.null
      | _ =>
        <AddDataAttributes attributes=[("data-badge-value", badge.value)]>
          <span
            className={`flex items-center ${rightIconSpacing} ${badgeColor} ${badgeTextColor} ${badgeSpacing} ${badgeTextSize}  rounded-full`}>
            {React.string(badge.value)}
          </span>
        </AddDataAttributes>
      }}
      {switch buttonRightText {
      | Some(text) =>
        <UIUtils.RenderIf condition={text !== ""}>
          <span className="text-jp-2-light-primary-600 font-semibold text-fs-14">
            {React.string(text)}
          </span>
        </UIUtils.RenderIf>
      | None => React.null
      }}
      {switch rightIcon {
      | FontAwesome(iconName) =>
        <span className={`flex items-center ${rightIconSpacing}`}>
          <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
        </span>
      | Euler(iconName) =>
        <span className={`flex items-center ${iconMargin} ${eulerIconPadding}`}>
          <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
        </span>
      | CustomIcon(element) =>
        <span className={`flex items-center ${iconPadding} `}> {element} </span>
      | _ => React.null
      }}
    </button>
  </AddDataAttributes>
}

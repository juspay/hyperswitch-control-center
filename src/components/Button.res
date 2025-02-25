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

  | DarkPurple
  | Dropdown

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

  | NoBadge
type badge = {
  value: string,
  color: badgeColor,
}

let useGetBgColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
) => {
  let config = React.useContext(ThemeProvider.themeContext)
  let buttonConfig = config.globalUIConfig.button.backgroundColor
  switch buttonType {
  | Primary =>
    switch buttonState {
    | Focused
    | Normal =>
      buttonConfig.primaryNormal
    | Loading => buttonConfig.primaryLoading
    | Disabled => buttonConfig.primaryDisabled
    | NoHover => buttonConfig.primaryNoHover
    }
  | PrimaryOutline => buttonConfig.primaryOutline

  | SecondaryFilled =>
    switch buttonState {
    | Focused
    | Normal => "bg-gradient-to-b from-gray-25 to-gray-100 dark:from-gray-900 dark:to-gray-900 hover:shadow-sm dark:text-gray-50/50 focus:outline-hidden"
    | Loading => "bg-gray-100 dark:bg-gray-500/10"
    | Disabled => "bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50"
    | NoHover => "bg-gradient-to-b overflow-x-scroll from-gray-100 to-gray-150 dark:from-gray-900 dark:to-gray-900 dark:text-gray-50/50 focus:outline-hidden"
    }

  | NonFilled =>
    switch buttonState {
    | Focused
    | Normal => "hover:bg-jp-gray-steel/40 dark:hover:bg-gray-900/100 dark:text-gray-50/50 focus:outline-hidden"
    | Loading => "bg-gray-100 dark:bg-gray-500/10"
    | Disabled => "bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50"
    | NoHover => "hover:bg-gray-300/40 dark:hover:bg-gray-900/100 dark:text-gray-50/50 focus:outline-hidden"
    }
  | FilterAdd =>
    switch buttonState {
    | Focused
    | Normal => "hover:bg-jp-gray-steel/40 dark:hover:bg-gray-900/100 text-primary dark:text-primary/100 focus:outline-hidden"
    | Loading => "bg-gray-100 dark:bg-gray-500/10"
    | Disabled => "bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50"
    | NoHover => "hover:bg-gray-300/40 dark:hover:bg-gray-900/100 dark:text-primary/100 text-primary/50  focus:outline-hidden"
    }
  | Pagination =>
    switch buttonState {
    | Focused
    | Normal => "font-medium border-transparent text-gray-500  focus:outline-hidden"

    | Loading => "border-left-1 border-right-1 font-normal border-left-1 bg-gray-100 dark:bg-gray-500/10"

    | Disabled => "border-left-1 border-right-1 font-normal border-left-1 dark:bg-gray-900/50 border dark:border-gray-950/50"

    | NoHover => "bg-primary/10 border-transparent font-medium  dark:text-gray-50/75"
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
      | Disabled => "bg-gray-200 dark:bg-gray-900/50 border dark:border-gray-950/50"
      | _ => `${color} ${hoverCss} focus:outline-hidden dark:active:shadow-none`
      }
    }

  | Secondary =>
    switch buttonState {
    | Focused
    | Normal =>
      showBorder ? buttonConfig.secondaryNormal : buttonConfig.secondaryNoBorder
    | Loading => showBorder ? buttonConfig.secondaryLoading : buttonConfig.secondaryNoBorder
    | Disabled => showBorder ? buttonConfig.secondaryDisabled : buttonConfig.secondaryNoBorder
    | NoHover => buttonConfig.secondaryNoHover
    }
  | Pill =>
    switch buttonState {
    | Focused
    | Normal => "bg-white text-gray-800/50 hover:shadow-sm hover:text-gray-800/75 dark:bg-jp-gray-darkgray_background dark:text-gray-50/50 focus:outline-hidden"
    | Loading =>
      showBorder
        ? "bg-white dark:bg-jp-gray-darkgray_background"
        : "bg-gray-300/40 dark:bg-gray-900/100"
    | Disabled =>
      showBorder ? "bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50" : "px-4"
    | NoHover => "bg-white text-gray-800/50 dark:bg-jp-gray-darkgray_background dark:text-gray-50/50 focus:outline-hidden"
    }

  | Delete =>
    switch buttonState {
    | Focused
    | Normal => "bg-red-300   hover:from-red-300 hover:to-red-400 focus:outline-hidden"
    | Loading => "bg-red-300"
    | Disabled => "bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50"
    | NoHover => "bg-gradient-to-t from-red-300 to-red-800-dull  hover:from-red-300 hover:to-red-300 focus:outline-hidden"
    }

  | Transparent =>
    switch buttonState {
    | Focused
    | Normal => "bg-gray-50   hover:bg-gray-200 dark:bg-jp-gray-darkgray_background focus:outline-hidden"
    | Loading => "bg-gray-50   hover:bg-gray-200 focus:outline-hidden"
    | Disabled => "bg-gray-50   hover:bg-gray-200 dark:bg-jp-gray-darkgray_background focus:outline-hidden"
    | NoHover => "bg-gray-50   hover:bg-gray-200 focus:outline-hidden"
    }

  | SelectTransparent =>
    switch buttonState {
    | Focused
    | Normal => "bg-primary-blue-50   hover:bg-primary-blue-50  dark:bg-black focus:outline-hidden"
    | Loading => "bg-gray-100   hover:bg-primary-blue-50 focus:outline-hidden"
    | Disabled => "bg-gray-100   hover:bg-primary-blue-50 focus:outline-hidden"
    | NoHover => "bg-gray-100   hover:bg-primary-blue-50 focus:outline-hidden"
    }

  | DarkPurple =>
    switch buttonState {
    | Focused
    | Normal => "bg-[#4F54EF] dark:bg-black focus:outline-hidden"
    | Loading => "bg-[#4F54EF] dark:bg-black focus:outline-hidden"
    | Disabled => "bg-[#4F54EF] dark:bg-black focus:outline-hidden"
    | NoHover => "bg-[#4F54EF] dark:bg-black focus:outline-hidden"
    }
  }
}

let useGetTextColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
) => {
  let config = React.useContext(ThemeProvider.themeContext)
  let textConfig = config.globalUIConfig.button.textColor
  switch buttonType {
  | Primary =>
    switch buttonState {
    | Disabled => textConfig.primaryDisabled
    | _ => textConfig.primaryNormal
    }
  | PrimaryOutline => textConfig.primaryOutline

  | FilterAdd => "text-primary"
  | Delete => "text-white"
  | Transparent => "text-gray-400"
  | SelectTransparent => "text-primary"
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
    | Disabled => textConfig.secondaryDisabled
    | Loading => textConfig.secondaryLoading
    | _ => textConfig.secondaryNormal
    }
  | SecondaryFilled =>
    switch buttonState {
    | Disabled => "text-gray-300 dark:text-gray-50/25"
    | Loading => "text-gray-500 hover:text-black dark:text-gray-50/75"
    | _ => "text-gray-500 hover:text-black dark:text-gray-50 dark:hover:text-gray-50/75"
    }

  | DarkPurple => "text-white"
  | Pagination =>
    switch buttonState {
    | Disabled => "font-medium text-gray-300"
    | NoHover => "font-medium text-primary/1 hover:text-primary/70"
    | _ => "text-gray-500 hover:bg-gray-150"
    }

  | _ =>
    switch buttonState {
    | Disabled => "text-gray-300 dark:text-gray-50/25"
    | Loading =>
      showBorder
        ? "text-gray-800/50 hover:text-gray-800/100 dark:text-gray-50/75"
        : "text-gray-800/50 hover:text-gray-800/100 dark:text-gray-50/75"
    | _ => "text-gray-800/50 hover:text-gray-800/100 dark:text-gray-50 dark:hover:text-gray-50/75"
    }
  }
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
    value: 1->Int.toString,
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
  ~showTooltip=false,
  ~tooltipText=?,
  ~toolTipPosition=ToolTip.Top,
  ~dataTestId="",
) => {
  let parentRef = React.useRef(Nullable.null)
  let dummyRef = React.useRef(Nullable.null)
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
    buttonSize->Option.getOr(MatchMedia.useMatchMedia("(max-width: 800px)") ? Small : Medium)

  let lengthStyle = if fullLength {
    "w-full justify-between"
  } else {
    ""
  }

  let badgeColor = switch buttonState {
  | Disabled => "bg-slate-300"
  | _ =>
    switch badge.color {
    | BadgeGreen => "bg-green-200 dark:bg-green-200/50"
    | BadgeRed => "bg-red-300 dark:bg-green-200/50"
    | BadgeBlue => "bg-primary dark:bg-green-200/50"
    | BadgeGray => "bg-blue-table_gray"
    | BadgeOrange => "bg-orange-400 dark:bg-green-200/50"
    | BadgeYellow => "bg-blue-table_yellow"
    | BadgeDarkGreen => "bg-green-300"
    | BadgeDarkRed => "bg-red-400"
    | NoBadge => "hidden"
    }
  }

  let badgeTextColor = switch buttonState {
  | Disabled => "text-white"
  | _ =>
    switch badge.color {
    | BadgeGray => "text-gray-800"
    | BadgeYellow => "text-gray-800"
    | _ => "text-white"
    }
  }

  let heightClass = customHeightClass->Option.getOr("")

  let cursorType = switch buttonState {
  | Loading => "cursor-wait"
  | Disabled => "cursor-not-allowed"
  | _ => "cursor-pointer"
  }

  let paddingClass = customPaddingClass->Option.getOr("")

  let customWidthClass = switch buttonSize {
  | Large => "w-147-px"
  | Medium => "w-145-px"
  | Small => "w-137-px"
  | _ => ""
  }

  let customHeightClass = switch buttonSize {
  | Large => "h-40-px"
  | Medium => "h-36-px"
  | Small => "h-32-px"
  | _ => ""
  }

  let textPaddingClass = customTextPaddingClass->Option.getOr(
    switch buttonSize {
    | XSmall => "px-1"
    | Small => "px-1"
    | Medium => "px-1"
    | Large => "py-3"
    },
  )

  let textSize = customTextSize->Option.getOr(
    switch buttonSize {
    | XSmall => "text-fs-11"
    | Small => "text-fs-13"
    | Medium => "text-body"
    | Large => "text-fs-16"
    },
  )

  let ellipsisClass = ellipsisOnly ? "truncate" : ""
  let ellipsisParentClass = ellipsisOnly ? "max-w-[250px] md:max-w-xs" : ""

  let iconSize = customIconSize->Option.getOr(
    switch buttonSize {
    | XSmall => 12
    | Small => 14
    | Medium => 16
    | Large => 18
    },
  )

  let strokeColor = ""

  let iconPadding = switch buttonSize {
  | XSmall => "px-1"
  | Small => "px-2"
  | Medium => "pr-3"
  | Large => "px-3"
  }

  let iconMargin = customIconMargin->Option.getOr(
    switch buttonSize {
    | XSmall
    | Small => "ml-1"
    | Medium
    | Large => "ml-3"
    },
  )

  let rightIconSpacing = switch buttonSize {
  | XSmall
  | Small => "mt-0.5 px-1"
  | Medium
  | Large => "mx-3 mt-0.5"
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
  )

  let textColor = useGetTextColor(
    ~buttonType,
    ~buttonState,
    ~showBorder,
    ~isDropdownOpen,
    ~isPhoneDropdown,
  )

  let defaultRoundedClass = switch buttonSize {
  | Large => "rounded-xl"
  | Small => "rounded-lg"
  | Medium => "rounded-10-px"
  | XSmall => "rounded-md"
  }

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
      "rounded-lg"
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
          `${borderWidth} border-1.5 `
        } else {
          ""
        }
      }
    | PrimaryOutline => `border-2`
    | Dropdown
    | Secondary =>
      showBorder
        ? switch buttonState {
          | Disabled => ""
          | Loading => `${borderWidth} border-border_gray`
          | _ => `${borderWidth} border-border_gray dark:border-gray-800/100`
          }
        : switch buttonState {
          | Disabled => ""
          | Loading => borderWidth
          | _ => borderWidth
          }

    | SecondaryFilled =>
      switch buttonState {
      | Disabled => ""
      | Loading => `${borderWidth} border-gray-300/75 dark:border-gray-800/100 `
      | _ => `${borderWidth} border-gray-250 dark:border-gray-800`
      }

    | Pill =>
      showBorder
        ? {
            switch buttonState {
            | Disabled => ""
            | Loading => `${borderWidth} border-gray-300/75 dark:border-gray-800/100`
            | _ => `${borderWidth} border-gray-250 dark:border-gray-800`
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
    | SelectTransparent => "border border-1 border-primary"
    | Transparent => "border border-jp-2-light-gray-400"
    | Delete =>
      switch buttonState {
      | Disabled => ""
      | Loading => `${borderWidth} border-gray-300/75 dark:border-gray-800/100 `
      | _ => `${borderWidth} border-gray-250 dark:border-gray-800`
      }
    | _ =>
      switch buttonState {
      | Disabled => ""
      | Loading => `${borderWidth} border-gray-300/75 dark:border-gray-800/100 `
      | _ => `${borderWidth} border-gray-250 dark:border-gray-800`
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

  let textId = text->Option.getOr("")
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
    textId->LogicUtils.isEmptyString
      ? iconId
      : textId->String.concat(buttonFor)->LogicUtils.toCamelCase
  let relativeClass = isRelative ? "relative" : ""
  let conditionalButtonStyles = `${allowButtonTextMinWidth
      ? "min-w-min"
      : ""} ${customBackColor->Option.getOr(backColor)} ${customRoundedClass->Option.getOr(
      roundedClass,
    )}`
  let customJustifyStyle = customButtonStyle->String.includes("justify") ? "" : "justify-center"

  <AddDataAttributes attributes=[(dataAttrKey, dataAttrStr), ("data-testid", dataTestId)]>
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
      className={`flex group ${customButtonStyle} ${customJustifyStyle} ${relativeClass} ${heightClass} ${conditionalButtonStyles} items-center ${borderStyle}   ${cursorType} ${paddingClass} ${lengthStyle}   ${customTextOverFlowClass} ${textColor} ${customWidthClass} ${customHeightClass}`}
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
          <span className={`flex items-center ${iconColor} ${iconMargin}`}>
            <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
          </span>
        | CustomIcon(element) =>
          <span className={`flex items-center ${iconMargin}`}> {element} </span>
        | _ => React.null
        }
      }}
      {switch text {
      | Some(textStr) =>
        if !(textStr->LogicUtils.isEmptyString) {
          let btnContent =
            <AddDataAttributes attributes=[("data-button-text", textStr)]>
              <div
                className={`${textPaddingClass} px-3 ${textSize} ${textWeight} ${ellipsisClass} whitespace-pre ${textStyle}`}>
                {buttonState == Loading ? React.string(loadingText) : React.string(textStr)}
              </div>
            </AddDataAttributes>

          if showBtnTextToolTip {
            <div className=ellipsisParentClass>
              <ToolTip
                description={tooltipText->Option.getOr("")}
                toolTipFor=btnContent
                contentAlign=Default
                justifyClass="justify-start"
                toolTipPosition
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
        <RenderIf condition={!(text->LogicUtils.isEmptyString)}>
          <span className="text-jp-2-light-primary-600 font-semibold text-fs-14">
            {React.string(text)}
          </span>
        </RenderIf>
      | None => React.null
      }}
      {switch rightIcon {
      | FontAwesome(iconName) =>
        <span className={`flex items-center ${rightIconSpacing}`}>
          <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
        </span>
      | Euler(iconName) =>
        <span className={`flex items-center ${iconMargin}`}>
          <Icon className={`align-middle ${strokeColor}`} size=iconSize name=iconName />
        </span>
      | CustomIcon(element) =>
        <span className={`flex items-center ${iconPadding} `}> {element} </span>
      | _ => React.null
      }}
    </button>
  </AddDataAttributes>
}

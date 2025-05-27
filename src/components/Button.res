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
    | Normal => "bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 hover:shadow dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none"
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
    | Normal => "hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 text-primary dark:text-primary dark:text-opacity-100 focus:outline-none"
    | Loading => "bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"
    | Disabled => "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"
    | NoHover => "hover:bg-jp-gray-600 hover:bg-opacity-40 dark:hover:bg-jp-gray-950 dark:hover:bg-opacity-100 dark:text-primary  focus:outline-none dark:text-opacity-100 text-opacity-50"
    }
  | Pagination =>
    switch buttonState {
    | Focused
    | Normal => "font-medium border-transparent text-nd_gray-500  focus:outline-none"

    | Loading => "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10"

    | Disabled => "border-left-1 border-right-1 font-normal border-left-1 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50"

    | NoHover => "bg-primary bg-opacity-10 border-transparent font-medium  dark:text-jp-gray-text_darktheme dark:text-opacity-75"
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
      showBorder ? buttonConfig.secondaryNormal : buttonConfig.secondaryNoBorder
    | Loading => showBorder ? buttonConfig.secondaryLoading : buttonConfig.secondaryNoBorder
    | Disabled => showBorder ? buttonConfig.secondaryDisabled : buttonConfig.secondaryNoBorder
    | NoHover => buttonConfig.secondaryNoHover
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

  | DarkPurple =>
    switch buttonState {
    | Focused
    | Normal => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | Loading => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | Disabled => "bg-[#4F54EF] dark:bg-black focus:outline-none"
    | NoHover => "bg-[#4F54EF] dark:bg-black focus:outline-none"
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
    | Disabled => "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
    | Loading => "text-jp-gray-800 hover:text-black dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    | _ => "text-jp-gray-800 hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75"
    }

  | DarkPurple => "text-white"
  | Pagination =>
    switch buttonState {
    | Disabled => "font-medium text-nd_gray-300"
    | NoHover => "font-medium text-primary text-opacity-1 hover:text-opacity-70"
    | _ => "text-nd_gray-500 hover:bg-nd_gray-150"
    }

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
    | BadgeGreen => "bg-green-950 dark:bg-opacity-50"
    | BadgeRed => "bg-red-960 dark:bg-opacity-50"
    | BadgeBlue => "bg-primary dark:bg-opacity-50"
    | BadgeGray => "bg-blue-table_gray"
    | BadgeOrange => "bg-orange-950 dark:bg-opacity-50"
    | BadgeYellow => "bg-blue-table_yellow"
    | BadgeDarkGreen => "bg-green-700"
    | BadgeDarkRed => "bg-red-400"
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
          | _ => `${borderWidth} border-border_gray dark:border-jp-gray-960 dark:border-opacity-100`
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
    | SelectTransparent => "border border-1 border-primary"
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

  let buttonComp =
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

            if showBtnTextToolTip && !showTooltip {
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

  showTooltip
    ? <ToolTip
        description={tooltipText->Option.getOr("")}
        toolTipFor=buttonComp
        contentAlign=Default
        justifyClass="justify-start"
        toolTipPosition
      />
    : buttonComp
}

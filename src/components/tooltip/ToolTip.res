type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight
type contentPosition = Left | Right | Middle | Default
type toolTipSize = Large | Medium | Small | XSmall

@send external getBoundingClientRect: Dom.element => Window.boundingClient = "getBoundingClientRect"

type tooltipPositioning = [#fixed | #absolute | #static]

let toolTipArrowBorder = 4

module TooltipMainWrapper = {
  @react.component
  let make = (
    ~children,
    ~visibleOnClick,
    ~hoverOnToolTip,
    ~setIsToolTipVisible,
    ~isRelative,
    ~flexClass,
    ~height,
    ~contentAlign,
    ~justifyClass,
  ) => {
    let relativeClass = isRelative ? "relative" : ""
    let flexCss = hoverOnToolTip ? "inline-flex" : "flex"
    let alignClass = switch contentAlign {
    | Left => "items-start"
    | Right => "items-end"
    | Middle => "items-center"
    | Default => ""
    }

    let timeoutRef = React.useRef(None)

    let handleMouseOver = _evt => {
      if !visibleOnClick {
        switch timeoutRef.current {
        | Some(timerId) => Js.Global.clearTimeout(timerId)
        | None => ()
        }
        setIsToolTipVisible(_ => true)
      }
    }

    let handleClick = _evt => {
      if visibleOnClick {
        switch timeoutRef.current {
        | Some(timerId) => Js.Global.clearTimeout(timerId)
        | None => ()
        }
        setIsToolTipVisible(_ => true)
      }
    }

    let handleMouseOut = _evt => {
      if hoverOnToolTip {
        timeoutRef.current = Js.Global.setTimeout(() => {
            setIsToolTipVisible(_ => false)
          }, 200)->Some
      } else {
        setIsToolTipVisible(_ => false)
      }
    }

    <AddDataAttributes attributes=[("data-tooltip", "tooltip")]>
      <div
        className={`${relativeClass} ${flexCss} ${flexClass} ${height} ${alignClass} ${justifyClass}`}
        onMouseOver=handleMouseOver
        onClick=handleClick
        onMouseOut=handleMouseOut>
        children
      </div>
    </AddDataAttributes>
  }
}

module TooltipWrapper = {
  let getToolTipFixedStyling = (
    ~hoverOnToolTip,
    ~positionX,
    ~positionY,
    ~tooltipWidth,
    ~tooltipHeight,
    ~tooltipArrowSize,
    ~componentWidth,
    ~componentHeight,
    ~position,
  ) => {
    let toolTipTopPosition = switch position {
    | Top =>
      hoverOnToolTip
        ? positionY - tooltipHeight - toolTipArrowBorder - (tooltipArrowSize - 5) - 4
        : positionY - tooltipHeight - toolTipArrowBorder - 4
    | Right => positionY - tooltipHeight / 2 + componentHeight / 2
    | Bottom =>
      hoverOnToolTip
        ? positionY + componentHeight + toolTipArrowBorder + (tooltipArrowSize - 5) + 4
        : positionY + componentHeight + toolTipArrowBorder + 4
    | BottomLeft
    | BottomRight =>
      positionY + componentHeight + toolTipArrowBorder + 4
    | Left => positionY - tooltipHeight / 2 + componentHeight / 2
    | TopLeft
    | TopRight =>
      positionY - tooltipHeight - toolTipArrowBorder - 4
    }
    let toolTipLeftPosition = switch position {
    | Top => positionX - tooltipWidth / 2 + componentWidth / 2
    | Right =>
      hoverOnToolTip
        ? positionX + componentWidth + toolTipArrowBorder + (tooltipArrowSize - 5) + 4
        : positionX + componentWidth + toolTipArrowBorder + 4
    | Bottom => positionX - tooltipWidth / 2 + componentWidth / 2
    | Left =>
      hoverOnToolTip
        ? positionX - tooltipWidth - toolTipArrowBorder + 2 - (tooltipArrowSize - 5) - 4
        : positionX - tooltipWidth - toolTipArrowBorder + 2 - 4
    | TopLeft
    | BottomLeft =>
      positionX + componentWidth / 2 - tooltipWidth + 9
    | TopRight
    | BottomRight =>
      positionX + componentWidth / 2 - 9
    }

    ReactDOMStyle.make(
      ~top=`${toolTipTopPosition->string_of_int}px`,
      ~left=`${toolTipLeftPosition->string_of_int}px`,
      (),
    )
  }

  let getToolTipAbsoluteStyling = (
    ~tooltipArrowHeight,
    ~tooltipHeightFloat,
    ~tooltipArrowWidth,
    ~tooltipWidth,
    ~componentWidth,
    ~componentHeight,
    ~position,
  ) => {
    let toolTipTopPosition = switch position {
    | Top =>
      tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. -100.0 +.
        tooltipHeightFloat /. componentHeight->Belt.Int.toFloat *. -100.0
    | Right => 50.0 -. tooltipHeightFloat /. componentHeight->Belt.Int.toFloat *. 50.0
    | Bottom => 100.0 +. tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. 100.0
    | BottomLeft => 100.0 +. tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. 100.0
    | BottomRight => 100.0 +. tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. 100.0
    | Left => 50.0 -. tooltipHeightFloat /. componentHeight->Belt.Int.toFloat *. 50.0
    | TopLeft =>
      tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. -100.0 +.
        tooltipHeightFloat /. componentHeight->Belt.Int.toFloat *. -100.0
    | TopRight =>
      tooltipArrowHeight /. componentHeight->Belt.Int.toFloat *. -100.0 +.
        tooltipHeightFloat /. componentHeight->Belt.Int.toFloat *. -100.0
    }

    let toolTipLeftPosition = switch position {
    | Top => 50.0 -. tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. 50.0
    | Right =>
      100.0 +. tooltipArrowWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. 100.0
    | Bottom => 50.0 -. tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. 50.0
    | Left =>
      tooltipArrowWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -100.0 +.
        tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -100.0
    | TopLeft => tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -50.0
    | BottomLeft => tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -50.0
    | TopRight =>
      100.0 +. tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -60.0
    | BottomRight =>
      100.0 +. tooltipWidth->Belt.Int.toFloat /. componentWidth->Belt.Int.toFloat *. -60.0
    }

    ReactDOMStyle.make(
      ~top=`${toolTipTopPosition->Js.Float.toString}%`,
      ~left=`${toolTipLeftPosition->Js.Float.toString}%`,
      (),
    )
  }

  @react.component
  let make = (
    ~isToolTipVisible,
    ~descriptionComponent,
    ~description,
    ~hoverOnToolTip,
    ~tooltipPositioning: tooltipPositioning,
    ~tooltipWidthClass,
    ~toolTipRef,
    ~textStyle,
    ~bgColor,
    ~customStyle,
    ~positionX,
    ~positionY,
    ~tooltipArrowHeight,
    ~tooltipHeightFloat,
    ~tooltipArrowWidth,
    ~tooltipWidth,
    ~tooltipHeight,
    ~tooltipArrowSize,
    ~componentWidth,
    ~componentHeight,
    ~toolTipPosition,
    ~defaultPosition,
    ~children,
  ) => {
    let descriptionExists = description != "" || descriptionComponent != React.null

    let textStyle = textStyle
    let fontWeight = "font-semibold"
    let borderRadius = "rounded"
    let tooltipOpacity = isToolTipVisible && descriptionExists ? "opacity-100" : "opacity-0"
    let pointerEvents = if isToolTipVisible && hoverOnToolTip {
      ""
    } else {
      " pointer-events-none"
    }
    let toolTipPositionString = switch tooltipPositioning {
    | #fixed => "fixed"
    | #absolute => "absolute"
    | #static => "static"
    }

    let paddingClass = "p-3"

    let tooltipPositionStyle = if tooltipPositioning === #fixed {
      getToolTipFixedStyling(
        ~hoverOnToolTip,
        ~positionX,
        ~positionY,
        ~tooltipWidth,
        ~tooltipHeight,
        ~tooltipArrowSize,
        ~componentWidth,
        ~componentHeight,
        ~position=toolTipPosition->Belt.Option.getWithDefault(defaultPosition),
      )
    } else {
      getToolTipAbsoluteStyling(
        ~tooltipArrowHeight,
        ~tooltipHeightFloat,
        ~tooltipArrowWidth,
        ~tooltipWidth,
        ~componentWidth,
        ~componentHeight,
        ~position=toolTipPosition->Belt.Option.getWithDefault(defaultPosition),
      )
    }

    <div className={`${tooltipOpacity} ${pointerEvents}`}>
      <div
        className={`${toolTipPositionString} ${tooltipWidthClass} z-30 h-auto break-words`}
        style={ReactDOMStyle.combine(tooltipPositionStyle, ReactDOMStyle.make(~hyphens="auto", ()))}
        ref={toolTipRef->ReactDOM.Ref.domRef}>
        <div
          className={`relative whitespace-pre-line max-w-xs text-left ${paddingClass} ${textStyle} ${fontWeight} ${borderRadius} ${bgColor} ${customStyle}`}>
          children
        </div>
      </div>
    </div>
  }
}

module DescriptionSection = {
  @react.component
  let make = (
    ~description,
    ~descriptionComponent,
    ~textStyleGap,
    ~descriptionComponentClass,
    ~setIsToolTipVisible,
    ~dismissable,
  ) => {
    <div className={textStyleGap}>
      {description
      ->String.split("\n")
      ->Array.filter(str => str !== "")
      ->Array.mapWithIndex((item, i) => {
        <AddDataAttributes attributes=[("data-text", item)] key={i->string_of_int}>
          <div key={item} className="flex flex-col gap-1"> {React.string(item)} </div>
        </AddDataAttributes>
      })
      ->React.array}
      <div className=descriptionComponentClass>
        <UIUtils.RenderIf condition=dismissable>
          <Icon
            name="popUpClose"
            className="stroke-jp-2-dark-gray-2000 cursor-pointer"
            parentClass="mt-5 mr-4"
            size=20
            onClick={_ => setIsToolTipVisible(prev => !prev)}
          />
        </UIUtils.RenderIf>
        {descriptionComponent}
      </div>
    </div>
  }
}

module TooltipFor = {
  @react.component
  let make = (~toolTipFor, ~tooltipForWidthClass, ~componentRef) => {
    let tooltipInfoIcon = "tooltip_info"
    let tooltipInfoIconSize = 16
    let iconStrokeColor = ""

    <div
      className={`inline h-min desktop:flex ${tooltipForWidthClass}`}
      ref={componentRef->ReactDOM.Ref.domRef}>
      {switch toolTipFor {
      | Some(element) => element
      | None =>
        <Icon
          name=tooltipInfoIcon
          size=tooltipInfoIconSize
          className={`opacity-50 hover:opacity-100 dark:brightness-50 dark:opacity-35 dark:invert dark:hover:opacity-70 ${iconStrokeColor}`}
        />
      }}
    </div>
  }
}

module Arrow = {
  let getArrowFixedPosition = (
    ~hoverOnToolTip,
    ~positionX,
    ~positionY,
    ~tooltipArrowSize,
    ~componentWidth,
    ~componentHeight,
    ~arrowColor,
    ~position,
  ) => {
    let arrowTopPosition = switch position {
    | Top =>
      hoverOnToolTip
        ? positionY - toolTipArrowBorder - (tooltipArrowSize - 5) - 5
        : positionY - toolTipArrowBorder - 5
    | TopLeft
    | TopRight =>
      positionY - toolTipArrowBorder - 4
    | Bottom
    | BottomRight
    | BottomLeft =>
      positionY + componentHeight + 4
    // | Left => positionY + componentHeight / 2 - toolTipArrowBorder - 20
    | _ => positionY + componentHeight / 2 - toolTipArrowBorder
    }

    let arrowLeftPosition = switch position {
    | Left =>
      hoverOnToolTip
        ? positionX - toolTipArrowBorder - (tooltipArrowSize - 5) - 4
        : positionX - toolTipArrowBorder - 4
    | Right => positionX + componentWidth + 4
    | TopRight
    | BottomRight
    | TopLeft
    | BottomLeft =>
      positionX + componentWidth / 2 - 5
    | _ => positionX + componentWidth / 2 - 5
    }

    let tooltipArrowpixel = `${tooltipArrowSize->Belt.Int.toString}px`
    let borderWidth = switch position {
    | Top => `${tooltipArrowpixel} ${tooltipArrowpixel} 0`
    | TopLeft => `${tooltipArrowpixel} ${tooltipArrowpixel} 0`
    | TopRight => `${tooltipArrowpixel} ${tooltipArrowpixel} 0`
    | Right => `${tooltipArrowpixel} ${tooltipArrowpixel} ${tooltipArrowpixel} 0`
    | Bottom => `0 ${tooltipArrowpixel} ${tooltipArrowpixel}`
    | BottomLeft => `0 ${tooltipArrowpixel} ${tooltipArrowpixel}`
    | BottomRight => `0 ${tooltipArrowpixel} ${tooltipArrowpixel}`
    | Left => `${tooltipArrowpixel} 0 ${tooltipArrowpixel} ${tooltipArrowpixel}`
    }

    let borderTopColor = if position === Top || position === TopLeft || position === TopRight {
      arrowColor
    } else {
      "transparent"
    }

    let borderRightColor = position === Right ? arrowColor : "transparent"

    let borderBottomColor = if (
      position === Bottom || position === BottomLeft || position === BottomRight
    ) {
      arrowColor
    } else {
      "transparent"
    }

    let borderLeftColor = position === Left ? arrowColor : "transparent"

    ReactDOMStyle.make(
      ~top=`${arrowTopPosition->string_of_int}px`,
      ~left=`${arrowLeftPosition->string_of_int}px`,
      ~borderWidth,
      ~width="0",
      ~height="0",
      ~borderTopColor,
      ~borderRightColor,
      ~borderLeftColor,
      ~borderBottomColor,
      (),
    )
  }

  let getArrowAbsolutePosition = (
    ~tooltipArrowWidth,
    ~tooltipArrowHeight,
    ~tooltipHeightFloat,
    ~tooltipWidth,
    ~arrowColor,
    ~position,
  ) => {
    //calculations are in relative to the tooltip text

    let arrowTopPosition = switch position {
    | Top => 100.0 -. tooltipArrowHeight /. tooltipHeightFloat *. -10.0
    | TopLeft => 100.0 -. tooltipArrowHeight /. tooltipHeightFloat *. -10.0
    | TopRight => 100.0 -. tooltipArrowHeight /. tooltipHeightFloat *. -10.0
    | Bottom => tooltipArrowHeight /. tooltipHeightFloat *. -100.0
    | BottomRight => tooltipArrowHeight /. tooltipHeightFloat *. -100.0
    | BottomLeft => tooltipArrowHeight /. tooltipHeightFloat *. -100.0
    | _ => 50.0 -. tooltipArrowHeight /. tooltipHeightFloat *. 50.0
    }

    let arrowLeftPosition = switch position {
    | Left => 100.0 +. tooltipArrowWidth->Belt.Int.toFloat /. tooltipWidth->Belt.Int.toFloat
    | Right => tooltipArrowWidth->Belt.Int.toFloat /. tooltipWidth->Belt.Int.toFloat *. -100.0
    | _ => 50.0 -. tooltipArrowWidth->Belt.Int.toFloat /. tooltipWidth->Belt.Int.toFloat *. 50.0
    }

    let borderWidth = switch position {
    | Top => "5px 5px 0"
    | TopLeft => "5px 5px 0"
    | TopRight => "5px 5px 0"
    | Right => "5px 5px 5px 0"
    | Bottom => "0 5px 5px"
    | BottomLeft => "0 5px 5px"
    | BottomRight => "0 5px 5px"
    | Left => "5px 0 5px 5px"
    }

    let borderTopColor = if position === Top || position === TopLeft || position === TopRight {
      arrowColor
    } else {
      "transparent"
    }

    let borderRightColor = position === Right ? arrowColor : "transparent"

    let borderBottomColor = if (
      position === Bottom || position === BottomLeft || position === BottomRight
    ) {
      arrowColor
    } else {
      "transparent"
    }

    let borderLeftColor = position === Left ? arrowColor : "transparent"

    ReactDOMStyle.make(
      ~top=`${arrowTopPosition->Belt.Float.toString}%`,
      ~left=`${arrowLeftPosition->Belt.Float.toString}%`,
      ~borderWidth,
      ~width="0",
      ~height="0",
      ~borderTopColor,
      ~borderRightColor,
      ~borderLeftColor,
      ~borderBottomColor,
      (),
    )
  }

  @react.component
  let make = (
    ~toolTipArrowRef,
    ~arrowCustomStyle,
    ~tooltipPositioning: tooltipPositioning,
    ~toolTipPosition,
    ~hoverOnToolTip,
    ~positionX,
    ~positionY,
    ~tooltipArrowWidth,
    ~tooltipArrowHeight,
    ~tooltipHeightFloat,
    ~tooltipArrowSize,
    ~tooltipWidth,
    ~componentWidth,
    ~componentHeight,
    ~bgColor,
    ~arrowBgClass,
    ~defaultPosition,
  ) => {
    let theme = ThemeProvider.useTheme()

    let arrowBackGroundClass = switch theme {
    | Light => "#000"
    | Dark => "#fff"
    }

    let arrowColor = if arrowBgClass !== "" && bgColor !== "" {
      arrowBgClass
    } else {
      arrowBackGroundClass
    }

    let tooltipArrowPosition = switch toolTipPosition {
    | Some(position) =>
      if tooltipPositioning === #fixed {
        getArrowFixedPosition(
          ~hoverOnToolTip,
          ~positionX,
          ~positionY,
          ~tooltipArrowSize,
          ~componentWidth,
          ~componentHeight,
          ~arrowColor,
          ~position,
        )
      } else {
        getArrowAbsolutePosition(
          ~tooltipArrowWidth,
          ~tooltipArrowHeight,
          ~tooltipHeightFloat,
          ~tooltipWidth,
          ~arrowColor,
          ~position,
        )
      }
    | None =>
      getArrowFixedPosition(
        ~hoverOnToolTip,
        ~positionX,
        ~positionY,
        ~tooltipArrowSize,
        ~componentWidth,
        ~componentHeight,
        ~arrowColor,
        ~position=defaultPosition,
      )
    }

    let toolTipPositionString = switch tooltipPositioning {
    | #fixed => "fixed"
    | #absolute => "absolute"
    | #static => "static"
    }

    <div
      style=tooltipArrowPosition
      ref={toolTipArrowRef->ReactDOM.Ref.domRef}
      className={`${arrowCustomStyle} ${toolTipPositionString} border-solid z-30 w-auto`}
    />
  }
}

let getDefaultPosition = (
  ~positionX,
  ~positionY,
  ~componentWidth,
  ~componentHeight,
  ~tooltipWidth,
  ~tooltipHeight,
) => {
  let tBoundingMidHeight = (componentHeight + tooltipHeight) / 2
  let tBoundingMidWidth = (componentWidth + tooltipWidth) / 2

  if Window.innerWidth / 2 > positionX {
    let rightPosition = if Window.innerHeight < tBoundingMidHeight + positionY {
      if positionX < tBoundingMidWidth {
        TopRight
      } else {
        Top
      }
    } else if 0 < tBoundingMidHeight - positionY {
      if positionX < tBoundingMidWidth {
        BottomRight
      } else {
        Bottom
      }
    } else {
      Right
    }

    rightPosition
  } else {
    let leftPosition = if Window.innerHeight < tBoundingMidHeight + positionY {
      if Window.innerWidth < positionX + tBoundingMidWidth {
        TopLeft
      } else {
        Top
      }
    } else if 0 < tBoundingMidHeight - positionY {
      if Window.innerWidth < positionX + tBoundingMidWidth {
        BottomLeft
      } else {
        Bottom
      }
    } else {
      Left
    }

    leftPosition
  }
}

@react.component
let make = (
  ~description="",
  ~descriptionComponent=React.null,
  ~tooltipPositioning: tooltipPositioning=#fixed,
  ~toolTipFor=?,
  ~tooltipWidthClass="w-fit",
  ~tooltipForWidthClass="",
  ~toolTipPosition: option<toolTipPosition>=?,
  ~customStyle="",
  ~arrowCustomStyle="",
  ~textStyleGap="",
  ~arrowBgClass="",
  ~bgColor="",
  ~contentAlign: contentPosition=Middle,
  ~justifyClass="justify-center",
  ~flexClass="flex-col",
  ~height="h-full",
  ~textStyle="text-fs-11",
  ~hoverOnToolTip=false,
  ~tooltipArrowSize=5,
  ~visibleOnClick=false,
  ~descriptionComponentClass="flex flex-row-reverse",
  ~isRelative=true,
  ~dismissable=false,
  (),
) => {
  let (isToolTipVisible, setIsToolTipVisible) = React.useState(_ => false)
  let toolTipRef = React.useRef(Js.Nullable.null)
  let componentRef = React.useRef(Js.Nullable.null)
  let toolTipArrowRef = React.useRef(Js.Nullable.null)

  React.useEffect1(() => {
    if isToolTipVisible {
      let handleScroll = (_e: Webapi.Dom.Event.t) => {
        setIsToolTipVisible(_ => false)
      }
      Window.addEventListener3("scroll", handleScroll, true)
      Some(() => Window.removeEventListener("scroll", handleScroll))
    } else {
      None
    }
  }, [isToolTipVisible])

  let getBoundingRectInfo = (ref: React.ref<Js.Nullable.t<Dom.element>>, getter) => {
    ref.current
    ->Js.Nullable.toOption
    ->Belt.Option.map(getBoundingClientRect)
    ->Belt.Option.mapWithDefault(0, getter)
  }

  let tooltipWidth = toolTipRef->getBoundingRectInfo(val => val.width)
  let tooltipHeight = toolTipRef->getBoundingRectInfo(val => val.height)
  let tooltipHeightFloat = tooltipHeight->Belt.Int.toFloat
  let tooltipArrowWidth = toolTipArrowRef->getBoundingRectInfo(val => val.width)
  let tooltipArrowHeight = toolTipArrowRef->getBoundingRectInfo(val => val.height)->Belt.Int.toFloat
  let positionX = componentRef->getBoundingRectInfo(val => val.x)
  let positionY = componentRef->getBoundingRectInfo(val => val.y)
  let componentWidth = componentRef->getBoundingRectInfo(val => val.width)
  let componentHeight = componentRef->getBoundingRectInfo(val => val.height)

  let tooltipBgClass = "dark:bg-jp-gray-tooltip_bg_dark bg-jp-gray-tooltip_bg_light dark:text-jp-gray-lightgray_background dark:text-opacity-75 text-jp-gray-text_darktheme text-opacity-75"

  let bgColor = bgColor === "" ? tooltipBgClass : bgColor

  let defaultPosition = getDefaultPosition(
    ~positionX,
    ~positionY,
    ~componentWidth,
    ~componentHeight,
    ~tooltipWidth,
    ~tooltipHeight,
  )

  <TooltipMainWrapper
    visibleOnClick
    hoverOnToolTip
    setIsToolTipVisible
    isRelative
    flexClass
    height
    contentAlign
    justifyClass>
    <TooltipFor toolTipFor tooltipForWidthClass componentRef />
    <TooltipWrapper
      isToolTipVisible
      descriptionComponent
      description
      hoverOnToolTip
      tooltipPositioning
      tooltipWidthClass
      toolTipRef
      textStyle
      bgColor
      customStyle
      positionX
      positionY
      tooltipArrowHeight
      tooltipHeightFloat
      tooltipArrowWidth
      tooltipWidth
      tooltipHeight
      tooltipArrowSize
      componentWidth
      componentHeight
      toolTipPosition
      defaultPosition>
      <DescriptionSection
        description
        descriptionComponent
        textStyleGap
        descriptionComponentClass
        setIsToolTipVisible
        dismissable
      />
      <Arrow
        toolTipArrowRef
        arrowCustomStyle
        tooltipPositioning
        hoverOnToolTip
        positionX
        positionY
        tooltipArrowWidth
        tooltipArrowHeight
        tooltipHeightFloat
        tooltipArrowSize
        tooltipWidth
        componentWidth
        componentHeight
        bgColor
        arrowBgClass
        toolTipPosition
        defaultPosition
      />
    </TooltipWrapper>
  </TooltipMainWrapper>
}

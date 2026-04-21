type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight

@react.component
let make = (
  ~description="",
  ~descriptionComponent=React.null,
  ~toolTipFor=?,
  ~toolTipPosition: option<toolTipPosition>=?,
  ~hoverOnToolTip=false,
  ~visibleOnClick=false,
  ~enableTooltipDelay=false,
  ~tooltipDelay: option<int>=?,
  (),
) => {
  let (isOpen, setIsOpen) = React.useState(_ => false)

  let side = switch toolTipPosition {
  | Some(Top) | Some(TopLeft) | Some(TopRight) => Some(ToolTipBinding.Top)
  | Some(Bottom) | Some(BottomLeft) | Some(BottomRight) => Some(ToolTipBinding.Bottom)
  | Some(Left) => Some(ToolTipBinding.Left)
  | Some(Right) => Some(ToolTipBinding.Right)
  | None => None
  }

  let align = switch toolTipPosition {
  | Some(TopLeft) | Some(BottomLeft) => Some(ToolTipBinding.Start)
  | Some(TopRight) | Some(BottomRight) => Some(ToolTipBinding.End)
  | _ => None
  }

  let content = if descriptionComponent != React.null {
    descriptionComponent
  } else {
    description->React.string
  }

  let triggerElement = switch toolTipFor {
  | Some(el) => el
  | None => <Icon name="nd-info-circle" size=14 />
  }

  let delayDuration = if visibleOnClick {
    0
  } else if enableTooltipDelay {
    tooltipDelay->Option.getOr(500)
  } else {
    100
  }

  let descriptionExists =
    description->LogicUtils.isNonEmptyString || descriptionComponent != React.null

  if !descriptionExists {
    triggerElement
  } else if visibleOnClick {
    <ToolTipBinding
      content
      size=Lg
      ?side
      ?align
      delayDuration
      open_=isOpen
      onOpenChange={v => setIsOpen(_ => v)}
      disableInteractive={!hoverOnToolTip}>
      triggerElement
    </ToolTipBinding>
  } else {
    <ToolTipBinding
      content size=Lg ?side ?align delayDuration disableInteractive={!hoverOnToolTip}>
      triggerElement
    </ToolTipBinding>
  }
}

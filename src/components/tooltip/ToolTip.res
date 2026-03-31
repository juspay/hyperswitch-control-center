type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight
type contentPosition = Left | Right | Middle | Default
type toolTipSize = Large | Medium | Small | XSmall

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
    Some(0)
  } else if enableTooltipDelay {
    Some(tooltipDelay->Option.getOr(500))
  } else {
    Some(100)
  }

  let open_ = if visibleOnClick {
    Some(isOpen)
  } else {
    None
  }

  let descriptionExists =
    description->LogicUtils.isNonEmptyString || descriptionComponent != React.null

  let trigger = if visibleOnClick {
    <div onClick={_ => setIsOpen(prev => !prev)}> triggerElement </div>
  } else {
    triggerElement
  }

  if !descriptionExists {
    triggerElement
  } else {
    <ToolTipBinding
      content
      size=Lg
      ?side
      ?align
      ?delayDuration
      ?open_
      disableInteractive={!hoverOnToolTip}>
      trigger
    </ToolTipBinding>
  }
}

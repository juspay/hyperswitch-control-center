type step

@obj
external makeStep: (
  ~intro: string,
  ~title: string=?,
  ~element: string=?,
  ~position: @string
  [
    | #top
    | #right
    | #bottom
    | #left
    | @as("bottom-middle-aligned") #bottomLeftAligned
    | @as("bottomleft-aligned") #bottomMiddleAligned
    | @as("bottom-right-aligned") #bottomRightAligned
    | @as("top-left-aligned") #topLeftAligned
    | @as("top-middle-aligned") #topmiddleAligned
    | @as("top-right-aligned") #topRightAligned
    | #auto
  ]=?,
  ~tooltipClass: string=?,
  ~highlightClass: string=?,
  unit,
) => step = ""

type stepOptions

@obj
external defineOptions: (
  ~showStepNumbers: bool,
  ~nextLabel: string=?,
  ~prevLabel: string=?,
  ~skipLabel: string=?,
  ~doneLabel: string=?,
  ~hidePrev: bool=?,
  ~hideNext: bool=?,
  ~tooltipPosition: string=?,
  ~tooltipClass: string=?,
  ~highlightClass: string=?,
  ~buttonClass: string=?,
  ~exitOnEsc: bool=?,
  ~exitOnOverlayClick: bool=?,
  ~keyboardNavigation: bool=?,
  ~showButtons: bool=?,
  ~showBullets: bool=?,
  ~showProgress: bool=?,
  ~scrollToElement: bool=?,
  ~overlayOpacity: float=?,
  ~scrollPadding: float=?,
  ~positionPrecedence: array<string>=?,
  ~disableInteraction: bool=?,
  ~hintPosition: string=?,
  ~hintButtonLabel: string=?,
  ~hintAnimation: bool=?,
  ~steps: array<step>=?,
  ~stepNumbersOfLabel: string=?,
  unit,
) => stepOptions = ""

module Steps = {
  @react.component @module("intro.js-react")
  external make: (
    ~enabled: bool=?,
    ~initialStep: int,
    ~steps: array<step>,
    ~onExit: int => unit,
    ~onComplete: unit => unit=?,
    ~onBeforeExit: int => option<bool>=?,
    ~options: stepOptions=?,
    ~onStart: int => unit=?,
    ~onChange: (int, React.element) => unit=?,
  ) => React.element = "Steps"
}

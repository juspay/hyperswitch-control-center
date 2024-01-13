type tabView = Compress | Expand
type tab = {
  title: string,
  tabElement?: React.element,
  renderContent: unit => React.element,
  onTabSelection?: unit => unit,
}
type activeButton = {left: bool, right: bool}
type boundingClient = {x: int, right: int}
type scrollIntoViewParams = {behavior: string, block: string, inline: string}
@send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"
@send external getBoundingClientRect: Dom.element => boundingClient = "getBoundingClientRect"
module TabInfo: {
  @react.component
  let make: (
    ~title: string,
    ~tabElement: option<React.element>=?,
    ~isSelected: bool,
    ~isScrollIntoViewRequired: bool=?,
    ~index: 'index,
    ~handleSelectedIndex: 'index => unit,
    ~isDisabled: bool=?,
    ~disabledTab: array<string>=?,
    ~textStyle: string=?,
    ~tabsCustomClass: string=?,
    ~borderBottomStyle: string=?,
    ~lightThemeColor: string=?,
    ~darkThemeColor: string=?,
    ~backgroundStyle: string=?,
    ~tabView: tabView=?,
    ~showRedDot: bool=?,
    ~visitedTabs: array<string>=?,
    ~borderSelectionStyle: string=?,
    ~borderDefaultStyle: string=?,
    ~showBottomBorder: bool=?,
    ~onTabSelection: unit => unit=?,
  ) => React.element
}
module IndicationArrow: {
  @react.component
  let make: (
    ~iconName: string,
    ~side: string,
    ~refElement: React.ref<Js.nullable<Dom.element>>,
    ~isVisible: bool,
  ) => React.element
}
let getBoundingRectInfo: (React.ref<Js.Nullable.t<Dom.element>>, boundingClient => int) => int
@react.component
let make: (
  ~tabs: array<tab>,
  ~tabsCustomClass: string=?,
  ~initialIndex: int=?,
  ~onTitleClick: int => unit=?,
  ~disableIndicationArrow: bool=?,
  ~tabContainerClass: string=?,
  ~borderBottomStyle: string=?,
  ~isScrollIntoViewRequired: bool=?,
  ~textStyle: string=?,
  ~isDisabled: bool=?,
  ~showRedDot: bool=?,
  ~visitedTabs: array<string>=?,
  ~disabledTab: array<string>=?,
  ~tabBottomShadow: string=?,
  ~lightThemeColor: string=?,
  ~darkThemeColor: string=?,
  ~defaultClasses: string=?,
  ~showBorder: bool=?,
  ~renderedTabClassName: string=?,
  ~bottomMargin: string=?,
  ~topPadding: string=?,
  ~includeMargin: bool=?,
  ~backgroundStyle: string=?,
  ~tabView: tabView=?,
  ~gapBetweenTabs: string=?,
  ~borderSelectionStyle: string=?,
  ~borderDefaultStyle: string=?,
  ~showBottomBorder: bool=?,
  ~showStickyHeader: bool=?,
  ~contentHeight: string=?,
) => // ~icon: REact.element=?,
React.element

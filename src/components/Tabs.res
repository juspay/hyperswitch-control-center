type tabView = Compress | Expand

type tab = {
  title: string,
  tabElement?: React.element,
  renderContent: unit => React.element,
  onTabSelection?: unit => unit,
}
type activeButton = {
  left: bool,
  right: bool,
}
type boundingClient = {x: int, right: int}
type scrollIntoViewParams = {behavior: string, block: string, inline: string}
@send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"
@send external getBoundingClientRect: Dom.element => boundingClient = "getBoundingClientRect"

module TabInfo = {
  @react.component
  let make = (
    ~title,
    ~tabElement=None,
    ~isSelected,
    ~isScrollIntoViewRequired=false,
    ~index,
    ~handleSelectedIndex,
    ~isDisabled=false,
    ~disabledTab=[],
    ~textStyle="",
    ~tabsCustomClass="",
    ~borderBottomStyle="",
    ~lightThemeColor="blue-800",
    ~darkThemeColor="blue-800",
    ~backgroundStyle="bg-gradient-to-b",
    ~tabView=Compress,
    ~showRedDot=false,
    ~visitedTabs=[],
    ~borderSelectionStyle="",
    ~borderDefaultStyle="",
    ~showBottomBorder=true,
    ~onTabSelection=() => (),
  ) => {
    let tabRef = React.useRef(Js.Nullable.null)
    let fontClass = "font-inter-style"

    let defaultBorderClass = "border-0"

    let tabTextPadding = "px-6"
    let backgroundStyle = backgroundStyle

    let tabDisabledStyle = "from-white to-white dark:from-jp-gray-950 dark:to-jp-gray-950 border-b-0 border-jp-gray-500 dark:border-jp-gray-960"

    let roundedClass = "rounded-t-md"

    let defaultClasses = if isDisabled && disabledTab->Array.includes(title) {
      `cursor-not-allowed ${fontClass} w-max flex flex-auto flex-row items-center justify-center ${roundedClass} ${tabTextPadding} ${backgroundStyle} ${tabDisabledStyle} ${defaultBorderClass} font-semibold dark:text-jp-gray-text_darktheme dark:text-opacity-50 text-opacity-50 hover:text-opacity-50 dark:hover:text-opacity-50`
    } else {
      `${fontClass} w-max flex flex-auto flex-row items-center justify-center ${tabTextPadding} ${roundedClass} ${defaultBorderClass}  font-semibold text-body`
    }

    let selectionClasses = if isSelected {
      `font-semibold text-${lightThemeColor} dark:text-${darkThemeColor} ${textStyle} ${borderSelectionStyle} `
    } else {
      `text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-75 text-opacity-50 hover:text-opacity-75 dark:hover:text-opacity-100  ${borderDefaultStyle}`
    }
    let handleClick = React.useCallback2(_ev => {
      if isDisabled && disabledTab->Array.includes(title) {
        ()
      } else {
        handleSelectedIndex(index)
      }
      onTabSelection()
    }, (index, handleSelectedIndex))

    let lineStyle = showBottomBorder ? "bg-black w-full h-0.5 rounded-full" : ""

    React.useEffect2(() => {
      if isSelected && isScrollIntoViewRequired {
        tabRef.current
        ->Js.Nullable.toOption
        ->Belt.Option.forEach(input =>
          input->scrollIntoView(_, {behavior: "smooth", block: "nearest", inline: "nearest"})
        )
      }
      None
    }, (isSelected, isScrollIntoViewRequired))

    let tab =
      <div className={"flex flex-col cursor-pointer w-max"}>
        <div
          className={`${defaultClasses} ${selectionClasses} select-none pb-2`}
          onClick={handleClick}>
          {React.string(title)}
        </div>
        {if isSelected {
          <FramerMotion.Motion.Div className=lineStyle layoutId="underline" />
        } else {
          <div className="h-0.5" />
        }}
      </div>

    {tab}
  }
}
module IndicationArrow = {
  @react.component
  let make = (~iconName, ~side, ~refElement: React.ref<Js.nullable<Dom.element>>, ~isVisible) => {
    let onClick = {
      _ev =>
        refElement.current
        ->Js.Nullable.toOption
        ->Belt.Option.forEach(input =>
          input->scrollIntoView(_, {behavior: "smooth", block: "nearest", inline: "start"})
        )
    }
    let roundness = side == "left" ? "rounded-tr-md" : "rounded-tl-md"
    let className = if isVisible {
      `absolute ${side}-0 bottom-0 shadow-side_shadow 2xl:hidden  ${roundness} bg-gray-50`
    } else {
      `hidden`
    }

    <div className>
      <Button buttonType=Secondary leftIcon={FontAwesome(iconName)} onClick flattenBottom=true />
    </div>
  }
}

let getBoundingRectInfo = (ref: React.ref<Js.Nullable.t<Dom.element>>, getter) => {
  ref.current
  ->Js.Nullable.toOption
  ->Belt.Option.map(getBoundingClientRect)
  ->Belt.Option.mapWithDefault(0, getter)
}

@react.component
let make = (
  ~tabs: array<tab>,
  ~tabsCustomClass="",
  ~initialIndex=?,
  ~onTitleClick=?,
  ~disableIndicationArrow=false,
  ~tabContainerClass="",
  ~borderBottomStyle="",
  ~isScrollIntoViewRequired=false,
  ~textStyle="",
  ~isDisabled=false,
  ~showRedDot=false,
  ~visitedTabs=[],
  ~disabledTab=[],
  ~tabBottomShadow="shadow-md",
  ~lightThemeColor="blue-800",
  ~darkThemeColor="blue-800",
  ~defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 rounded-t-md bg-gradient-to-b from-white to-white hover:from-jp-gray-250 hover:to-jp-gray-200 hover:bg-jp-gray-100 dark:from-jp-gray-950 dark:to-jp-gray-950 border border-b-0 border-jp-gray-500 dark:border-jp-gray-960 font-semibold text-body",
  ~showBorder=true,
  ~renderedTabClassName="",
  ~bottomMargin="pb-8",
  ~topPadding="",
  ~includeMargin=true,
  ~backgroundStyle="bg-gradient-to-b",
  ~tabView=Compress,
  ~gapBetweenTabs="gap-1.5",
  ~borderSelectionStyle="",
  ~borderDefaultStyle="",
  ~showBottomBorder=true,
  ~showStickyHeader=false,
  ~contentHeight="",
) => {
  // ~icon=React.null,

  let _ = defaultClasses
  let initialIndex = initialIndex->Belt.Option.getWithDefault(0)
  let (selectedIndex, setSelectedIndex) = React.useState(() => initialIndex)
  let tabOuterClass = `${tabBottomShadow} ${gapBetweenTabs}`
  let bottomBorderClass = "border-b border-jp-gray-500 dark:border-jp-gray-960"

  let renderedTabClassName = renderedTabClassName

  React.useEffect1(() => {
    setSelectedIndex(_ => initialIndex)
    None
  }, [initialIndex])
  let (_isLeftArrowVisible, setIsLeftArrowVisible) = React.useState(() => false)
  let (_isRightArrowVisible, setIsRightArrowVisible) = React.useState(() => true)

  let firstTabRef = React.useRef(Js.Nullable.null)
  let scrollRef = React.useRef(Js.Nullable.null)
  let lastTabRef = React.useRef(Js.Nullable.null)
  let numberOfTabs = Array.length(tabs)
  let onScroll = _ev => {
    let leftVal = firstTabRef->getBoundingRectInfo(val => val.x)
    let rightVal = lastTabRef->getBoundingRectInfo(val => val.right)
    let scrollValLeft = scrollRef->getBoundingRectInfo(val => val.x)
    let scrollValRight = scrollRef->getBoundingRectInfo(val => val.right)

    let newIsLeftArrowVisible = leftVal - scrollValLeft < 0
    let newIsRightArrowVisible = rightVal - scrollValRight >= 10

    setIsLeftArrowVisible(_ => newIsLeftArrowVisible)
    setIsRightArrowVisible(_ => newIsRightArrowVisible)
  }
  let handleSelectedIndex = index => {
    switch onTitleClick {
    | Some(fn) => fn(index)
    | None => ()
    }

    setSelectedIndex(_ => index)
  }

  let tabClass = switch tabView {
  | Compress => ""
  | Expand => "w-full"
  }
  let topMargin = "mt-5"
  let stickyHeader = showStickyHeader
    ? `top-0 height-50 sticky bg-white border-b dark:bg-black border-jp-gray-500 dark:border-jp-gray-960`
    : ""
  <ErrorBoundary>
    <div className={`flex flex-col ${contentHeight}`}>
      <div className={`py-0 ${stickyHeader}`}>
        <div
          className="overflow-x-auto no-scrollbar overflow-y-hidden"
          ref={scrollRef->ReactDOM.Ref.domRef}
          onScroll>
          <div
            className={`flex flex-row ${topMargin} pr-8 ${tabOuterClass}
          ${showBorder && includeMargin ? "ml-5" : ""}  ${tabContainerClass}`}>
            {tabs
            ->Array.mapWithIndex((tab, i) => {
              let ref = if i == 0 {
                firstTabRef->ReactDOM.Ref.domRef->Some
              } else if i == numberOfTabs - 1 {
                lastTabRef->ReactDOM.Ref.domRef->Some
              } else {
                None
              }
              <div className=tabClass ?ref key={string_of_int(i)}>
                <TabInfo
                  title={tab.title}
                  tabElement=tab.tabElement
                  isSelected={selectedIndex === i}
                  index={i}
                  tabsCustomClass
                  handleSelectedIndex
                  borderBottomStyle
                  isScrollIntoViewRequired
                  textStyle
                  lightThemeColor
                  darkThemeColor
                  backgroundStyle
                  disabledTab
                  isDisabled
                  tabView
                  borderSelectionStyle
                  borderDefaultStyle
                  showBottomBorder
                  onTabSelection=?{tab.onTabSelection}
                />
              </div>
            })
            ->React.array}
          </div>
        </div>
      </div>
      <UIUtils.RenderIf condition={!showStickyHeader && showBorder}>
        <div className=bottomBorderClass />
      </UIUtils.RenderIf>
      <div className=renderedTabClassName>
        <ErrorBoundary key={string_of_int(selectedIndex)}>
          {switch tabs->Belt.Array.get(selectedIndex) {
          | Some(selectedTab) => {
              let component = selectedTab.renderContent()
              <FramerMotion.TransitionComponent
                id={string_of_int(selectedIndex)} className=contentHeight>
                {component}
              </FramerMotion.TransitionComponent>
            }

          | None => React.string("No tabs found")
          }}
        </ErrorBoundary>
      </div>
    </div>
  </ErrorBoundary>
}

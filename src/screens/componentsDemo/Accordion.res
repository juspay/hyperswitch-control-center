type accordion = {
  title: string,
  renderContent: unit => React.element,
  renderContentOnTop: option<unit => React.element>,
}

type arrowPosition = Left | Right
type mobileRenderType = Modal | Accordion

module SectionAccordion = {
  @react.component
  let make = (
    ~title="",
    ~subtext="",
    ~children,
    ~headerBg="md:bg-jp-gray-100 dark:bg-transparent",
    ~headingClass="",
    ~mobileRenderType: mobileRenderType=Accordion,
    ~hideHeaderWeb=false,
    ~setShow=_ => (),
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()

    let (isExpanded, setIsExpanded) = React.useState(_ => !isMobileView)
    let titleClass = "md:font-bold font-semibold md:text-fs-16 text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-white  dark:text-opacity-75"

    <AddDataAttributes attributes=[("data-section", title)]>
      <div className={`border md:border-0 dark:border-jp-gray-950 ${headerBg}`}>
        <DesktopView>
          <UIUtils.RenderIf condition={!hideHeaderWeb}>
            <h3 className={`text-base ${headingClass}`}> {title->React.string} </h3>
          </UIUtils.RenderIf>
          <p
            className="text-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
            {subtext->React.string}
          </p>
          <AddDataAttributes attributes=[("data-section", title)]> children </AddDataAttributes>
        </DesktopView>
        <MobileView>
          <div
            className={`${titleClass} bg-white dark:bg-jp-gray-lightgray_background px-4 py-3 flex justify-start  text-jp-gray-900 text-opacity-75 `}
            onClick={_ => {
              setIsExpanded(prev => !prev)
              setShow(_ => title)
            }}>
            <div className="py-1 !text-lg"> {title->React.string} </div>
            <div
              className="cursor-pointer flex  justify-center align-center text-jp-gray-900 text-right text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-auto">
              <Icon name={isExpanded ? "angle-down" : "angle-right"} size=15 />
            </div>
          </div>
          {switch mobileRenderType {
          | Modal =>
            <Modal
              modalHeading=title
              showModal=isExpanded
              setShowModal=setIsExpanded
              borderBottom=true
              childClass="">
              <div className="mx-4 mb-4"> {children} </div>
            </Modal>
          | Accordion =>
            <div
              className={`${!isExpanded
                  ? "hidden"
                  : ""} border-t-2 dark:border-jp-gray-950 md:border-0`}>
              {children}
            </div>
          }}
        </MobileView>
      </div>
    </AddDataAttributes>
  }
}

module AccordionInfo = {
  @react.component
  let make = (
    ~accordion,
    ~arrowFillColor="",
    ~arrowPosition=Left,
    ~accordianTopContainerCss="",
    ~accordianBottomContainerCss="",
    ~expanded=false,
    ~contentExpandCss="",
    ~titleStyle="",
  ) => {
    let (isExpanded, setIsExpanded) = React.useState(() => expanded)

    let handleClick = _e => {
      setIsExpanded(prevExpanded => !prevExpanded)
    }

    let contentClasses = if isExpanded {
      `flex-wrap bg-white dark:bg-jp-gray-lightgray_background text-lg ${contentExpandCss}`
    } else {
      "hidden"
    }

    let svgDeg = if isExpanded {
      "90"
    } else {
      "0"
    }

    <div
      className={`overflow-hidden border bg-white  border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 ${accordianTopContainerCss}`}>
      <div
        onClick={handleClick}
        className={`flex cursor-pointer items-center font-ibm-plex  bg-white hover:bg-jp-gray-100 dark:bg-jp-gray-950  dark:border-jp-gray-960 ${titleStyle} ${accordianBottomContainerCss}`}>
        {if arrowPosition == Left {
          <svg
            width="7"
            height="11"
            viewBox="0 0 7 11"
            fill="none"
            transform={`rotate(${svgDeg})`}
            xmlns="http://www.w3.org/2000/svg">
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M-0.000107288 0L6.01489 5.013L-0.000107288 10.025V0Z"
              fill=arrowFillColor
            />
          </svg>
        } else {
          React.null
        }}
        {switch accordion.renderContentOnTop {
        | Some(ui) => ui()
        | None => <div className="ml-5"> {React.string(accordion.title)} </div>
        }}
        {if arrowPosition == Right {
          <svg
            width="7"
            height="11"
            viewBox="0 0 7 11"
            fill="none"
            transform={`rotate(${svgDeg})`}
            xmlns="http://www.w3.org/2000/svg">
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M-0.000107288 0L6.01489 5.013L-0.000107288 10.025V0Z"
              fill=arrowFillColor
            />
          </svg>
        } else {
          React.null
        }}
      </div>
      <div
        className={`flex flex-col dark:border-jp-gray-960 border-t dark:hover:bg-jp-gray-900 dark:hover:bg-opacity-25 ${contentClasses}`}>
        {accordion.renderContent()}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~accordion: array<accordion>,
  ~arrowFillColor: string="#CED0DA",
  ~accordianTopContainerCss: string="mt-5 rounded-lg",
  ~accordianBottomContainerCss: string="p-4",
  ~contentExpandCss="px-8 font-bold",
  ~arrowPosition=Left,
  ~initialExpandedArray=[],
  ~gapClass="",
  ~titleStyle="font-bold text-lg text-jp-gray-700 dark:text-jp-gray-text_darktheme dark:text-opacity-50 hover:text-jp-gray-800 dark:hover:text-opacity-100",
) => {
  <ErrorBoundary>
    <div className={`w-full ${gapClass}`}>
      {accordion
      ->Array.mapWithIndex((accordion, i) => {
        <AccordionInfo
          key={string_of_int(i)}
          accordion
          arrowFillColor
          arrowPosition
          accordianTopContainerCss
          accordianBottomContainerCss
          contentExpandCss
          expanded={initialExpandedArray->Array.includes(i)}
          titleStyle
        />
      })
      ->React.array}
    </div>
  </ErrorBoundary>
}

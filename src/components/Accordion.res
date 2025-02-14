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
    ~headerBg="md:bg-gray-50 dark:bg-transparent",
    ~headingClass="",
    ~mobileRenderType: mobileRenderType=Accordion,
    ~hideHeaderWeb=false,
    ~setShow=_ => (),
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()

    let (isExpanded, setIsExpanded) = React.useState(_ => !isMobileView)
    let titleClass = "md:font-bold font-semibold md:text-fs-16 text-fs-13 text-gray-800/75 dark:text-white/75"

    <AddDataAttributes attributes=[("data-section", title)]>
      <div className={`border md:border-0 dark:border-gray-900 ${headerBg}`}>
        <DesktopView>
          <RenderIf condition={!hideHeaderWeb}>
            <h3 className={`text-base ${headingClass}`}> {title->React.string} </h3>
          </RenderIf>
          <p className="text-gray-900/50 dark:text-gray-50/50"> {subtext->React.string} </p>
          <AddDataAttributes attributes=[("data-section", title)]> children </AddDataAttributes>
        </DesktopView>
        <MobileView>
          <div
            className={`${titleClass} bg-white dark:bg-gray-900 px-4 py-3 flex justify-start  text-gray-800/75 `}
            onClick={_ => {
              setIsExpanded(prev => !prev)
              setShow(_ => title)
            }}>
            <div className="py-1 !text-lg"> {title->React.string} </div>
            <div
              className="cursor-pointer flex  justify-center align-center text-gray-800/50 text-right dark:text-gray-50/50 ml-auto">
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
                  : ""} border-t-2 dark:border-gray-900 md:border-0`}>
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

    let handleClick = _ => {
      setIsExpanded(prevExpanded => !prevExpanded)
    }

    let contentClasses = if isExpanded {
      `flex-wrap bg-white dark:bg-gray-900 text-lg ${contentExpandCss}`
    } else {
      "hidden"
    }

    let svgDeg = if isExpanded {
      "90"
    } else {
      "0"
    }

    <div
      className={`overflow-hidden border bg-white  border-gray-250 dark:border-gray-800 dark:bg-gray-900 ${accordianTopContainerCss}`}>
      <div
        onClick={handleClick}
        className={`flex cursor-pointer items-center font-ibm-plex  bg-white hover:bg-gray-50 dark:bg-gray-900  dark:border-gray-800 ${titleStyle} ${accordianBottomContainerCss}`}>
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
        className={`flex flex-col dark:border-gray-800 border-t dark:hover:bg-gray-800/25 ${contentClasses}`}>
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
  ~titleStyle="font-bold text-lg text-gray-500 dark:text-gray-50/50 hover:text-gray-500 dark:hover:text-gray-50/100",
) => {
  <div className={`w-full ${gapClass}`}>
    {accordion
    ->Array.mapWithIndex((accordion, i) => {
      <AccordionInfo
        key={Int.toString(i)}
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
}

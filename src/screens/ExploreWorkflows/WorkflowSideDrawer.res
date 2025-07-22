open ExploreWorkflowsTypes
open RenderIf
open Typography

module AccordionItemComponent = {
  @react.component
  let make = (~step: stepDetails) => {
    <div className="flex flex-col gap-4">
      {step.description}
      {switch step.videoPath {
      | Some(videoPath) =>
        <video className="w-full" controls=true preload="metadata">
          <source src={`/public/gifs/${videoPath}`} type_="video/mp4" />
          {"Your browser does not support video playback."->React.string}
        </video>
      | None => React.null
      }}
      {switch step.cta {
      | Some((text, action)) =>
        <a
          onClick={event => {
            ReactEvent.Mouse.preventDefault(event)
            switch action {
            | InternalRoute(link) =>
              RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=link))
            | ExternalLink({url, _}) => Window._open(url) /* Open in new tab */
            }
          }}
          className={`text-blue-500 hover:text-blue-700 ${body.md.medium} inline-flex items-center gap-1 pb-4`}>
          {text->React.string}
        </a>
      | None => React.null
      }}
    </div>
  }
}

@react.component
let make = () => {
  open ExploreWorkflowsUtils
  let {setWorkflowDrawerState, workflowDrawerState} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let isSmallerScreen = MatchMedia.useScreenSizeChecker(~screenSize="1279")

  let workflowTitle = switch workflowDrawerState {
  | FullWidth(title) | Minimised(title) => title
  | Closed => #ExploreSmartRetries
  }

  let (drawerHeading, subHeading, steps) = getCurrentWorkflowDetails(workflowTitle)

  let accordionItems = steps->Array.map(step => {
    let accItem: Accordion.accordion = {
      title: step.title,
      renderContent: () => <AccordionItemComponent step />,
      renderContentOnTop: None,
    }
    accItem
  })

  let drawerheight = switch workflowDrawerState {
  | FullWidth(_) => "h-full"
  | Minimised(_) => isSmallerScreen ? "h-full" : "h-1/2"
  | Closed => "h-0"
  }

  let drawerWidth = switch workflowDrawerState {
  | FullWidth(_) => "w-100"
  | Minimised(_) => isSmallerScreen ? "w-[26px]" : "w-100"
  | Closed => "w-0"
  }

  let cheveronAngle = switch workflowDrawerState {
  | FullWidth(_) | Closed => "rotate-0"
  | Minimised(_) => "rotate-180"
  }

  let padding = isSmallerScreen ? "p-4 pr-0" : "p-4"
  let roundedClass = isSmallerScreen ? "rounded-tl-lg rounded-bl-lg" : "rounded-lg"

  <RenderIf condition={workflowDrawerState !== Closed}>
    <div
      className={`fixed inset-0 z-40 bottom-0 flex justify-end items-end ${padding} pointer-events-none overflow-x-hidden`}>
      <div
        className={`${drawerWidth} ${drawerheight} bg-white ${roundedClass} border border-jp-gray-300 shadow-rightDrawerShadow flex flex-col pointer-events-auto transition-all duration-300 relative `}>
        <RenderIf condition={isSmallerScreen}>
          <div
            className="p-2 rounded-full shadow-lg absolute top-1/2 -left-4 cursor-pointer z-10 bg-white border">
            <Icon
              name="nd-angle-right"
              size=16
              className=cheveronAngle
              onClick={_ =>
                setWorkflowDrawerState(prevState => getNextStateBasedOnPrevState(prevState))}
            />
          </div>
        </RenderIf>
        <div className="flex flex-col justify-between overflow-y-scroll overflow-x-hidden">
          <div className="flex flex-col p-6 gap-2">
            <div className="flex gap-1 justify-between items-center">
              <p className={`${heading.sm.semibold} text-nd_gray-700`}>
                {drawerHeading->React.string}
              </p>
              <div className="flex items-center gap-6 justify-center">
                <RenderIf condition={!isSmallerScreen}>
                  <Icon
                    name="nd_minimise"
                    size=22
                    className="text-jp-gray-700  cursor-pointer"
                    onClick={_ =>
                      setWorkflowDrawerState(prevState => getNextStateBasedOnPrevState(prevState))}
                  />
                </RenderIf>
                <Icon
                  name="close"
                  size=14
                  className="text-jp-gray-700 cursor-pointer"
                  onClick={_ => setWorkflowDrawerState(_ => Closed)}
                />
              </div>
            </div>
            <span className={`${body.md.semibold} text-nd_gray-400 w-full`}>
              {subHeading->React.string}
            </span>
          </div>
          <hr />
          <div className="p-6 pt-3 overflow-y-scroll">
            <Accordion
              accordion=accordionItems
              initialExpandedArray=[0]
              arrowPosition=Right
              accordianTopContainerCss="border-0 border-b border-nd_br_gray-150"
              accordianBottomContainerCss="py-4 px-0 pb-6"
              contentExpandCss="border-none"
              titleStyle={`${body.md.semibold} text-nd_gray-700 justify-between hover:bg-white`}
              gapClass="space-y-4"
              accordionHeaderTextClass="!ml-0"
            />
          </div>
        </div>
      </div>
    </div>
  </RenderIf>
}

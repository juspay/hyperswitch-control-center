let bgClass = "bg-white hover:bg-jp-gray-100"
module GetProductionAccess = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let textStyles = HSwitchUtils.getTextClass((P2, Medium))
    let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
      GlobalProvider.defaultContext,
    )
    let isProdIntent = isProdIntentCompleted->Option.getOr(false)
    let cursorStyles = isProdIntent ? "cursor-default" : "cursor-pointer underline"
    let productionAccessString = isProdIntent
      ? "Production Access Requested"
      : "Get Production Access"

    let prodAccess = switch isProdIntentCompleted {
    | Some(_) =>
      <div
        className={`flex items-center gap-2 text-nd_yellow-200  ${cursorStyles}  whitespace-nowrap rounded-lg justify-between `}
        onClick={_ => {
          isProdIntent
            ? ()
            : {
                setShowProdIntentForm(_ => true)
                mixpanelEvent(~eventName="get_production_access")
              }
        }}>
        <div className={`text-nd_yellow-200 ${textStyles} !font-semibold `}>
          {productionAccessString->React.string}
        </div>
      </div>
    | None => React.null
    }

    <div
      className="absolute w-fit max-w-fixedPageWidth bg-white flex flex-col items-center -top-11">
      <div
        className="bg-nd_orange-100 px-4 py-[6px] rounded-br-md rounded-bl-md w-fit flex gap-2 items-center">
        <Icon name="nd-toast-info" size=14 customIconColor="text-nd_yellow-200 text-fs-12" />
        <p className="text-nd_yellow-200 text-base leading-5 font-medium text-nowrap">
          {"You're in Test Mode"->React.string}
        </p>
        {prodAccess}
      </div>
    </div>
  }
}

module MenuOption = {
  @react.component
  let make = (~text=?, ~children=?, ~onClick=?) => {
    <AddDataAttributes attributes=[("data-testid", text->Option.getOr("")->String.toLowerCase)]>
      <button
        className={`px-4 py-3 flex text-sm w-full text-gray-700 cursor-pointer ${bgClass}`}
        ?onClick>
        {switch text {
        | Some(str) => React.string(str)
        | None => React.null
        }}
        {switch children {
        | Some(elem) => elem
        | None => React.null
        }}
      </button>
    </AddDataAttributes>
  }
}

@react.component
let make = (
  ~headerActions=?,
  ~midUiActions=?,
  ~notificationActions=?,
  ~faqsActions as _=?,
  ~outageActions=?,
  ~liveMode=?,
  ~customHeight="",
  ~portalStyle="",
  ~homeLink="/",
  ~popOverPanelCustomClass="",
  ~headerLeftActions=?,
  ~midUiActionsCustomClass="",
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (isAppearancePopupOpen, setIsAppearancePopupOpen) = React.useState(_ => false)
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let ref = React.useRef(Nullable.null)
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([ref]),
    ~isActive=isAppearancePopupOpen,
    ~callback=() => {
      setIsAppearancePopupOpen(_ => false)
    },
  )

  let leftMarginOnNav = "ml-0"
  switch authStatus {
  | LoggedIn(_info) =>
    <div id="navbar" className={`w-full mx-auto`}>
      <div className={`flex flex-row min-h-16 items-center justify-between ${customHeight}`}>
        {switch headerLeftActions {
        | Some(actions) => actions
        | None => React.null
        }}
        <div className={midUiActionsCustomClass}>
          {switch midUiActions {
          | Some(actions) => actions
          | None => React.null
          }}
        </div>
        <div className="inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:pr-0">
          {switch headerActions {
          | Some(actions) => actions
          | None => React.null
          }}
          {switch outageActions {
          | Some(actions) => actions
          | None => React.null
          }}
          {if isMobileView {
            switch liveMode {
            | Some(actions) => actions
            | None => React.null
            }
          } else {
            React.null
          }}
          {switch notificationActions {
          | Some(actions) => actions
          | None => React.null
          }}
          <div className={`mt-2 ${leftMarginOnNav}`}>
            <PortalCapture key="onboarding" name="onboarding" />
          </div>
          <div
            onClick={_ => {
              setIsSidebarExpanded(prev => !prev)
            }}
            className={`h-full px-1.5 flex items-center focus:outline-none cursor-pointer transform transition duration-500 ease-in-out md:hidden`}>
            <Icon className="align-middle" name="bars" />
          </div>
        </div>
      </div>
      <div className="md:ml-5 ml-2">
        <PortalCapture key="navbarSecondRow" name="navbarSecondRow" />
      </div>
      <HSwitchFeedBackModal modalHeading="We'd love to hear from you!" setShowModal showModal />
    </div>

  | LoggedOut => React.null
  | PreLogin(_)
  | CheckingAuthStatus =>
    React.string("...")
  }
}

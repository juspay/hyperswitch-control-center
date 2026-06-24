open Typography
open ThemePreviewTypes
module MockOrgTiles = {
  @react.component
  let make = (~sidebarFromForm: HyperSwitchConfigTypes.sidebarConfig, ~orgs) => {
    <div
      className="flex flex-col gap-2 items-center py-4 border-r w-8 bg-nd_gray-50"
      style={ReactDOM.Style.make(~backgroundColor=sidebarFromForm.primary, ())}>
      {orgs
      ->Array.mapWithIndex((ele, index) => {
        <div
          className="flex items-center justify-center w-5 h-5 rounded-md bg-white border text-nd_gray-500"
          style={ReactDOM.Style.make(
            ~borderColor=index === 0 ? sidebarFromForm.textColorPrimary : "border",
            ~backgroundColor=sidebarFromForm.primary,
            ~color=index === 0 ? sidebarFromForm.textColorPrimary : sidebarFromForm.textColor,
            (),
          )}
          key={index->Int.toString}>
          <span className={`${body.xs.medium}`}> {React.string(ele)} </span>
        </div>
      })
      ->React.array}
    </div>
  }
}
module MockSidebarItem = {
  @react.component
  let make = (
    ~item: sidebarItem,
    ~index: int,
    ~sidebarFromForm: HyperSwitchConfigTypes.sidebarConfig,
  ) => {
    let textColor = item.active ? sidebarFromForm.textColorPrimary : sidebarFromForm.textColor
    let padding = index === 0 ? "" : "pl-3"

    <>
      <div
        key={item.label}
        className={`flex items-center gap-1 px-2 py-1 mx-2 rounded-md cursor-pointer hover:bg-opacity-75 transition-colors `}
        style={ReactDOM.Style.make(~color=textColor, ())}>
        <RenderIf condition={index == 0}>
          <Icon name="orchestrator-home" size=10 />
        </RenderIf>
        <span className={`${body.xs.medium} ${padding} `}> {React.string(item.label)} </span>
      </div>
    </>
  }
}

module MockButton = {
  @react.component
  let make = (
    ~text: string,
    ~backgroundColor: string,
    ~hoverBackgroundColor: string,
    ~textColor: string,
  ) => {
    let (isHovered, setIsHovered) = React.useState(_ => false)
    let bgColor = isHovered ? hoverBackgroundColor : backgroundColor
    <button
      type_="button"
      onMouseEnter={_ => setIsHovered(_ => true)}
      onMouseLeave={_ => setIsHovered(_ => false)}
      className="px-2 py-3 h-4 rounded flex items-center justify-between cursor-pointer transition-colors"
      style={ReactDOM.Style.make(~backgroundColor=bgColor, ~color=textColor, ())}>
      {React.string(text)}
    </button>
  }
}

module MockBrowserChrome = {
  @react.component
  let make = (~faviconUrl: option<string>) =>
    <div className="flex flex-col bg-nd_gray-100 border-b border-nd_gray-200 shrink-0">
      <div className="flex items-center gap-2 px-3 pt-2">
        <div className="flex items-center gap-1.5 mr-1">
          <span className="w-2 h-2 rounded-full bg-nd_red-400" />
          <span className="w-2 h-2 rounded-full bg-nd_yellow-500" />
          <span className="w-2 h-2 rounded-full bg-nd_green-400" />
        </div>
        <div className="flex items-center gap-1.5 bg-white rounded-t-lg px-2 py-1 w-28">
          <RenderIf condition={faviconUrl->Option.isSome}>
            <img
              src={faviconUrl->Option.getOr("")}
              alt="favicon"
              className="w-2.5 h-2.5 object-contain shrink-0"
            />
          </RenderIf>
          <RenderIf condition={faviconUrl->Option.isNone}>
            <span className="w-2.5 h-2.5 rounded-full bg-nd_gray-300 shrink-0" />
          </RenderIf>
          <span className={`flex-1 min-w-0 truncate text-nd_gray-700 ${body.xs.medium}`}>
            {React.string(mockValues.browserTabTitle)}
          </span>
          <Icon name="nd-cross" size=8 className="text-nd_gray-400 shrink-0" />
        </div>
        <Icon name="plus" size=12 className="text-nd_gray-400 shrink-0" />
      </div>
      <div className="flex items-center gap-2 bg-white px-3 py-1.5">
        <Icon name="chevron-left" size=12 className="text-nd_gray-400 shrink-0" />
        <Icon name="chevron-right" size=12 className="text-nd_gray-300 shrink-0" />
        <Icon name="sync" size=12 className="text-nd_gray-400 shrink-0" />
        <div
          className="flex items-center gap-1.5 flex-1 min-w-0 bg-nd_gray-100 rounded-full px-3 py-1">
          <Icon name="lock-icon" size=10 className="text-nd_gray-400 shrink-0" />
          <span className={`truncate text-nd_gray-500 ${body.xs.regular}`}>
            {React.string(mockValues.browserUrl)}
          </span>
        </div>
      </div>
    </div>
}

module MockNavbar = {
  @react.component
  let make = (~logoUrl: option<string>) =>
    <div className="flex flex-row gap-4 justify-between items-center w-full p-2">
      <div className="flex items-center gap-2 shrink-0">
        <RenderIf condition={logoUrl->Option.isSome}>
          <img src={logoUrl->Option.getOr("")} alt="logo" className="h-5 w-auto object-contain" />
        </RenderIf>
        <RenderIf condition={logoUrl->Option.isNone}>
          <div
            className="flex items-center border border-dashed border-nd_gray-300 rounded px-2 py-1">
            <span className={`${body.xs.regular} text-nd_gray-400`}>
              {React.string(mockValues.logoPlaceholder)}
            </span>
          </div>
        </RenderIf>
        <div
          className={`flex items-center whitespace-nowrap border rounded-lg px-3 py-1 bg-white ${body.xs.regular} text-nd_gray-400`}>
          <span> {"Profile :"->React.string} </span>
          <span className={`ml-1 ${body.xs.semibold} text-nd_gray-500`}>
            {"Test_profile"->React.string}
          </span>
          <Icon name="chevron-down" size=10 className="ml-1 text-nd_gray-400" />
        </div>
      </div>
      <div
        className={`flex items-center min-w-0 w-72 border rounded-lg px-3 py-1 bg-white ${body.xs.regular} text-nd_gray-400`}>
        <Icon name="search" size=12 className="mr-2 shrink-0 text-nd_gray-400" />
        <input
          className={`flex-1 min-w-0 outline-none bg-transparent ${body.xs.regular} text-nd_gray-700`}
          placeholder="Search"
          style={ReactDOM.Style.make(~border="none", ())}
        />
        <span className={`ml-2 shrink-0 ${body.xs.regular} text-nd_gray-300`}>
          {"⌘ + K"->React.string}
        </span>
      </div>
    </div>
}

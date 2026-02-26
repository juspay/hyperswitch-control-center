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

module MockNavbar = {
  @react.component
  let make = () =>
    <div className="flex flex-row gap-8 justify-between items-center w-full p-2">
      <div
        className={`flex items-center border rounded-lg px-3 py-1 bg-white ${body.xs.regular} text-nd_gray-400`}>
        <span> {"Profile :"->React.string} </span>
        <span className={`ml-1 ${body.xs.semibold} text-nd_gray-500`}>
          {"Test_profile"->React.string}
        </span>
        <Icon name="chevron-down" size=10 className="ml-1 text-nd_gray-400" />
      </div>
      <div
        className={`flex items-center border rounded-lg px-3 py-1 bg-white ${body.xs.regular} text-nd_gray-400 w-72`}>
        <Icon name="search" size=12 className="mr-2 text-nd_gray-400" />
        <input
          className={`flex-1 outline-none bg-transparent ${body.xs.regular} text-nd_gray-700`}
          placeholder="Search"
          style={ReactDOM.Style.make(~border="none", ())}
        />
        <span className={`ml-2 ${body.xs.regular} text-nd_gray-300`}>
          {"⌘ + K"->React.string}
        </span>
      </div>
    </div>
}

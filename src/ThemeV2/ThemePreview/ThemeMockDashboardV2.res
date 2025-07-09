open ThemePreviewUtils
open Typography
open ThemePreviewTypes
open ThemeHookV2
@react.component
let make = () => {
  let (_themeName, colorsFromForm, sidebarFromForm, buttonsFromForm) = useThemeFormValues()

  let orgs = ["S", "A"]

  let renderOrgTiles = () => {
    <div
      className="flex flex-col gap-2 items-center py-4 bg-white border-r w-8 bg-nd_gray-50"
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
          )}>
          <span className="text-fs-10 font-medium "> {React.string(ele)} </span>
        </div>
      })
      ->React.array}
    </div>
  }
  let renderSidebarItem = (item: sidebarItem, index: int) => {
    let textColor = item.active ? sidebarFromForm.textColorPrimary : sidebarFromForm.textColor
    let bgColor = item.active ? "rgba(153, 155, 159, 0.1)" : "transparent"
    let fontSize = index === 0 ? "text-fs-10" : "text-fs-10 pl-3"

    <>
      <div
        key={item.label}
        className="flex items-center gap-1 px-2 py-1 mx-2 rounded-md cursor-pointer hover:bg-opacity-75 transition-colors"
        style={ReactDOM.Style.make(~backgroundColor=bgColor, ~color=textColor, ())}>
        {index === 0 ? <Icon name="orchestrator-home" size=10 /> : React.null}
        <span className={`${fontSize} font-medium`}> {React.string(item.label)} </span>
      </div>
    </>
  }

  let renderNavbar = () =>
    <div className="flex flex-row gap-8 justify-between items-center w-full p-2">
      <div
        className="flex items-center border rounded-lg px-3 py-1 bg-white text-fs-10 text-nd_gray-400">
        <span> {"Profile :"->React.string} </span>
        <span className="ml-1 font-semibold text-nd_gray-500">
          {"Test_profile"->React.string}
        </span>
        <Icon name="chevron-down" size=10 className="ml-1 text-nd_gray-400" />
      </div>
      <div
        className="flex items-center border rounded-lg px-3 py-1 bg-white text-fs-10 text-nd_gray-400 w-72">
        <Icon name="search" size=12 className="mr-2 text-nd_gray-400" />
        <input
          className="flex-1 outline-none bg-transparent text-fs-10 text-nd_gray-700"
          placeholder="Search"
          style={ReactDOM.Style.make(~border="none", ())}
        />
        <span className="ml-2 text-fs-8 text-nd_gray-300"> {"⌘ + K"->React.string} </span>
      </div>
    </div>

  <div className="bg-white rounded-lg overflow-hidden w-full shadow-xl h-3/4">
    <div className="flex h-full">
      {renderOrgTiles()}
      <div
        className="w-36 flex flex-col border-r bg-nd_gray-50"
        style={ReactDOM.Style.make(~backgroundColor=sidebarFromForm.primary, ())}>
        <div className="p-2 pt-3 border-b border-gray-200">
          <div
            className="font-semibold text-fs-10"
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {React.string("Merchant Tester")}
          </div>
        </div>
        <nav className="flex-1 py-1 ">
          {sidebarItems
          ->Array.mapWithIndex(renderSidebarItem)
          ->React.array}
        </nav>
        <div className="p-3 border-t flex items-center gap-2">
          <span
            className="rounded-full bg-nd_gray-600 w-4 h-4 flex items-center justify-center text-fs-10 text-white">
            <Icon name="user" size=8 />
          </span>
          <span
            className="text-fs-10 text-nd_gray-600 truncate"
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {"test@gmail.com"->React.string}
          </span>
          <Icon name="chevron-down" size=10 className="text-nd_gray-400" />
        </div>
      </div>
      <div className="flex-1 flex flex-col overflow-hidden ">
        {renderNavbar()}
        <div className="p-2">
          <span className="font-semibold text-gray-900 text-fs-12">
            {React.string("Page Heading")}
          </span>
          <p className="text-gray-600 mb-4 text-fs-10">
            {React.string("Page Descriptions will go here")}
          </p>
        </div>
        <div className="p-2 m-2 rounded-lg border-nd_gray-50 border flex flex-col gap-0.5">
          <span className={`${body.xs.semibold}`}> {"Card Heading"->React.string} </span>
          <span className={`text-fs-10 text-nd_gray-400`}>
            {"Lorem ipsum dolor sit amet, consectetur adipiscing elit"->React.string}
          </span>
          <div className="flex flex-row gap-2 mt-2 font-semibold text-fs-8">
            <div
              className="px-2 py-3 h-4 rounded flex items-center justify-between cursor-pointer"
              style={ReactDOM.Style.make(
                ~backgroundColor=buttonsFromForm.primary.backgroundColor,
                ~color=buttonsFromForm.primary.textColor,
                (),
              )}>
              {React.string("Primary Button")}
            </div>
            <div
              className="px-2 py-3 rounded h-4 flex justify-between items-center cursor-pointer"
              style={ReactDOM.Style.make(
                ~backgroundColor=buttonsFromForm.secondary.backgroundColor,
                ~color=buttonsFromForm.secondary.textColor,
                (),
              )}>
              {React.string("Secondary Button")}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}

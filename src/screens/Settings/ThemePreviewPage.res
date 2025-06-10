// ThemePreview.res

open ThemePreviewTypes
open ThemePreviewUtils
open Typography

module ActionButtons = {
  @react.component
  let make = () => {
    // Actions
    <div className="flex flex-row gap-4 justify-end w-full">
      <Button
        text="Reset to Default"
        buttonType=Secondary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
      />
      <Button
        text="Apply Theme"
        buttonType=Primary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
      />
    </div>
  }
}
module MockDashboard = {
  @react.component
  let make = (~theme) => {
    let renderOrgTiles = () => {
      let orgs = ["S", "A"]
      <div
        className="flex flex-col gap-2 items-center py-4 bg-white border-r w-8 bg-nd_gray-50"
        style={ReactDOM.Style.make(~backgroundColor=theme.sidebar.primary, ())}>
        {orgs
        ->Array.mapWithIndex((ele, index) => {
          <div
            className="flex items-center justify-center w-5 h-5 rounded-md bg-white border text-nd_gray-500"
            style={ReactDOM.Style.make(
              ~borderColor=index === 0 ? theme.sidebar.textColorPrimary : "border",
              ~backgroundColor=theme.sidebar.primary,
              ~color=index === 0 ? theme.sidebar.textColorPrimary : theme.sidebar.textColor,
              (),
            )}>
            <span className="text-fs-10 font-medium "> {React.string(ele)} </span>
          </div>
        })
        ->React.array}
      </div>
    }
    let renderSidebarItem = (item: sidebarItem, index: int) => {
      let textColor = item.active ? theme.sidebar.textColorPrimary : theme.sidebar.textColor
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

    <div className="bg-white rounded-lg overflow-hidden w-full shadow-xl h-3/4">
      <div className="flex h-full">
        // Org Sidebar
        {renderOrgTiles()}
        // Main Sidebar
        <div
          className="w-36 flex flex-col border-r bg-nd_gray-50"
          style={ReactDOM.Style.make(~backgroundColor=theme.sidebar.primary, ())}>
          <div className="p-2 pt-3 border-b border-gray-200">
            <div
              className="font-semibold text-fs-10"
              style={ReactDOM.Style.make(~color=theme.sidebar.textColor, ())}>
              {React.string("Merchant Tester")}
            </div>
          </div>
          <nav className="flex-1 py-1 ">
            {sidebarItems
            ->Array.mapWithIndex(renderSidebarItem)
            ->React.array}
          </nav>
          <div />
        </div>
        // Main Content
        <div className="flex-1 flex flex-col overflow-hidden ">
          // Navbar
          <div className="flex flex-row gap-8 space-between p-2">
            <img className="w-32 h-6" alt="Nav" src="/assets/profileMock.png" />
            <img className="w-72 h-6" alt="Search" src="/assets/searchMock.png" />
          </div>
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
                  ~backgroundColor=theme.buttons.primary.backgroundColor,
                  ~color=theme.buttons.primary.textColor,
                  (),
                )}>
                {React.string("Primary Button")}
              </div>
              <div
                className="px-2 py-3 rounded h-4 flex justify-between items-center cursor-pointer"
                style={ReactDOM.Style.make(
                  ~backgroundColor=theme.buttons.secondary.backgroundColor,
                  ~color=theme.buttons.secondary.textColor,
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
}
module PreviewTheme = {
  @react.component
  let make = (~theme) => {
    <div className="flex flex-col gap-8 w-full lg:col-span-2 ">
      <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
      <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
        <div
          className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
          <Icon name="eye" size=18 className="text-gray-500 opacity-70" />
        </div>
        // Mock Dashboard
        <MockDashboard theme />
      </div>
      <ActionButtons />
    </div>
  }
}

module UploadAssets = {
  @react.component
  let make = (~theme, ~updateTheme) => {
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Assets")} </div>
      {renderImageUploader(~asset="Favicon", theme.faviconUrl, v =>
        updateTheme(t => {...t, faviconUrl: v})
      )}
      {renderImageUploader(~asset="Logo", theme.logoUrl, v => updateTheme(t => {...t, logoUrl: v}))}
    </div>
  }
}

module BrandSettings = {
  @react.component
  let make = (~theme, ~updateTheme) => {
    let handleThemeNameChange = (value: string) => {
      updateTheme(t => {...t, themeName: value})
    }

    let handlePrimaryColorChange = (value: string) => {
      updateTheme(t => {...t, primaryColor: value})
    }
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Brand Settings")} </div>
      <div className="space-y-4">
        {renderTextInput("Theme Name", theme.themeName, handleThemeNameChange)}
        {renderColorInput("Primary Color", theme.primaryColor, handlePrimaryColorChange)}
      </div>
    </div>
  }
}

module SidebarSettings = {
  @react.component
  let make = (~theme, ~updateTheme) => {
    let handleSidebarChange = (field: string, value: string) => {
      updateTheme(t => {
        let newSidebar = switch field {
        | "primary" => {...t.sidebar, primary: value}
        | "textColor" => {...t.sidebar, textColor: value}
        | "textColorPrimary" => {...t.sidebar, textColorPrimary: value}
        | _ => t.sidebar
        }
        {...t, sidebar: newSidebar}
      })
    }
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Sidebar Settings")} </div>
      <div className="space-y-4">
        {renderColorInput("Background Color", theme.sidebar.primary, v =>
          handleSidebarChange("primary", v)
        )}
        {renderColorInput("Text Color", theme.sidebar.textColor, v =>
          handleSidebarChange("textColor", v)
        )}
        {renderColorInput("Active Item Color", theme.sidebar.textColorPrimary, v =>
          handleSidebarChange("textColorPrimary", v)
        )}
      </div>
    </div>
  }
}

module ButtonSettings = {
  @react.component
  let make = (~theme, ~updateTheme) => {
    let handleButtonChange = (buttonType: string, field: string, value: string) => {
      updateTheme(t => {
        let newButtons = switch buttonType {
        | "primary" => {
            let newPrimary = switch field {
            | "backgroundColor" => {...t.buttons.primary, backgroundColor: value}
            | "textColor" => {...t.buttons.primary, textColor: value}
            | "hoverBackgroundColor" => {...t.buttons.primary, hoverBackgroundColor: value}
            | _ => t.buttons.primary
            }
            {...t.buttons, primary: newPrimary}
          }
        | "secondary" => {
            let newSecondary = switch field {
            | "backgroundColor" => {...t.buttons.secondary, backgroundColor: value}
            | "textColor" => {...t.buttons.secondary, textColor: value}
            | "hoverBackgroundColor" => {...t.buttons.secondary, hoverBackgroundColor: value}
            | _ => t.buttons.secondary
            }
            {...t.buttons, secondary: newSecondary}
          }
        | _ => t.buttons
        }
        {...t, buttons: newButtons}
      })
    }
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Button Settings")} </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.md.semibold}`}> {React.string("Primary Button")} </div>
        <div className="space-y-3 pointer-events-auto">
          {renderColorInput("Background", theme.buttons.primary.backgroundColor, v =>
            handleButtonChange("primary", "backgroundColor", v)
          )}
          {renderColorInput("Text Color", theme.buttons.primary.textColor, v =>
            handleButtonChange("primary", "textColor", v)
          )}
          {renderColorInput("Hover Background", theme.buttons.primary.hoverBackgroundColor, v =>
            handleButtonChange("primary", "hoverBackgroundColor", v)
          )}
        </div>
        <div className="flex flex-col gap-4">
          <div className={`${body.md.semibold}`}> {React.string("Secondary Button")} </div>
          <div className="space-y-3 pointer-events-auto">
            {renderColorInput("Background", theme.buttons.secondary.backgroundColor, v =>
              handleButtonChange("secondary", "backgroundColor", v)
            )}
            {renderColorInput("Text Color", theme.buttons.secondary.textColor, v =>
              handleButtonChange("secondary", "textColor", v)
            )}
            {renderColorInput("Hover Background", theme.buttons.secondary.hoverBackgroundColor, v =>
              handleButtonChange("secondary", "hoverBackgroundColor", v)
            )}
          </div>
        </div>
      </div>
    </div>
  }
}

module ConfigurationSettings = {
  @react.component
  let make = (~theme, ~setTheme) => {
    let updateTheme = (updater: theme => theme) => {
      setTheme(prevTheme => updater(prevTheme))
    }
    <div className="flex flex-col gap-8 max-h-screen overflow-y-auto p-2">
      // Upload Assets
      <UploadAssets theme updateTheme />
      // Basic Settings
      <BrandSettings theme updateTheme />
      // Sidebar Settings
      <SidebarSettings theme updateTheme />
      // // Button Settings
      // <ButtonSettings theme updateTheme />
    </div>
  }
}
@react.component
let make = () => {
  let (theme, setTheme) = React.useState(() => defaultTheme)
  <div className="flex flex-col gap-8">
    <div className="flex flex-col">
      <PageUtils.PageHeading
        title="Theme Configuration"
        subTitle="Personalize your dashboard look with a live preview."
        customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
      />
      <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
        // Configuration Panel
        <ConfigurationSettings theme setTheme />
        // Preview Section
        <PreviewTheme theme />
      </div>
    </div>
  </div>
}

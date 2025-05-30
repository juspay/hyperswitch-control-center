// ThemePreview.res

type buttonConfig = {
  backgroundColor: string,
  textColor: string,
  hoverBackgroundColor: string,
}
type sidebarConfig = {
  primary: string,
  textColor: string,
  textColorPrimary: string,
}

type buttonsConfig = {
  primary: buttonConfig,
  secondary: buttonConfig,
}

type theme = {
  themeName: string,
  primaryColor: string,
  sidebar: sidebarConfig,
  buttons: buttonsConfig,
  faviconUrl: string,
  logoUrl: string,
}

type sidebarItem = {
  iconName: string,
  label: string,
  active: bool,
  hasSubmenu: bool,
}

let defaultTheme = {
  themeName: "Default Theme",
  primaryColor: "#006DF9",
  sidebar: {
    primary: "#FCFCFD",
    textColor: "#525866",
    textColorPrimary: "#1C6DEA",
  },
  buttons: {
    primary: {
      backgroundColor: "#1272f9",
      textColor: "#ffffff",
      hoverBackgroundColor: "#0860dd",
    },
    secondary: {
      backgroundColor: "#f3f3f3",
      textColor: "#626168",
      hoverBackgroundColor: "#fcfcfd",
    },
  },
  faviconUrl: "",
  logoUrl: "",
}

let sidebarItems = [
  {iconName: "home", label: "Overview", active: true, hasSubmenu: false},
  {iconName: "settings", label: "Operations", active: false, hasSubmenu: true},
  {iconName: "link", label: "Connectors", active: false, hasSubmenu: true},
  {iconName: "bar-chart", label: "Analytics", active: false, hasSubmenu: true},
  {iconName: "git-branch", label: "Workflow", active: false, hasSubmenu: true},
  {iconName: "refresh-cw", label: "Reconciliation", active: false, hasSubmenu: false},
  {iconName: "code", label: "Developers", active: false, hasSubmenu: true},
  {iconName: "settings", label: "Settings", active: false, hasSubmenu: true},
]

@react.component
let make = () => {
  open Typography
  let (theme, setTheme) = React.useState(() => defaultTheme)
  let greeting = HomeUtils.getGreeting()
  let updateTheme = (updater: theme => theme) => {
    setTheme(prevTheme => updater(prevTheme))
  }

  let handleThemeNameChange = (value: string) => {
    updateTheme(t => {...t, themeName: value})
  }

  let handlePrimaryColorChange = (value: string) => {
    updateTheme(t => {...t, primaryColor: value})
  }

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

  let renderSidebarItem = (item: sidebarItem) => {
    let textColor = item.active ? theme.sidebar.textColorPrimary : theme.sidebar.textColor
    let bgColor = item.active ? "rgba(28, 109, 234, 0.1)" : "transparent"
    <div
      key={item.label}
      className="flex items-center px-4 py-2 mx-2 rounded-md cursor-pointer hover:bg-opacity-75 transition-colors"
      style={ReactDOM.Style.make(~backgroundColor=bgColor, ~color=textColor, ())}>
      <div className="w-5 h-5 mr-3">
        <Icon name={item.iconName} size=14 />
      </div>
      <span className="text-sm font-medium flex-1"> {React.string(item.label)} </span>
    </div>
  }

  let renderTextInput = (label: string, value: string, onChange: string => unit) => {
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700"> {React.string(label)} </label>
      <input
        type_="text"
        value
        onChange={e => {
          let target = ReactEvent.Form.target(e)
          onChange(target["value"])
        }}
        className="w-full text-sm px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        placeholder="Enter theme name"
      />
    </div>
  }

  let renderColorInput = (label: string, value: string, onChange: string => unit) => {
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700"> {React.string(label)} </label>
      <div className="flex items-center space-x-3">
        <input
          type_="color"
          value
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            onChange(target["value"])
          }}
          className="w-12 h-10 text-sm rounded-md border border-gray-300 cursor-pointer"
        />
        <input
          type_="text"
          value
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            onChange(target["value"])
          }}
          className="flex-1 text-sm px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="#000000"
        />
      </div>
    </div>
  }

  let renderImageUploader = (label: string, value: string, onChange: string => unit) => {
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700"> {React.string(label)} </label>
      <div className="flex items-center space-x-3">
        <input
          type_="url"
          value
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            onChange(target["value"])
          }}
          className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="Enter image URL"
        />
        <button
          className="px-3 py-2 bg-gray-100 text-gray-700 rounded-md text-sm hover:bg-gray-200 transition-colors">
          {React.string("Upload")}
        </button>
      </div>
    </div>
  }

  let renderOrgTiles = () => {
    <div
      className="flex flex-col items-center py-4 bg-white border-r w-16"
      style={ReactDOM.Style.make(~backgroundColor=theme.sidebar.primary, ())}>
      <div
        className="flex items-center justify-center w-8 h-8 rounded-lg bg-white border-2"
        style={ReactDOM.Style.make(~borderColor=theme.primaryColor, ())}>
        <span className="text-xs font-medium text-gray-800"> {React.string("O")} </span>
      </div>
      <div
        className="flex items-center justify-center  w-8 h-8 rounded-lg bg-white border border-gray-300 mt-3">
        <span className="text-xs font-medium text-gray-800"> {React.string("J")} </span>
      </div>
    </div>
  }

  <div className="flex flex-col px-4 lg:px-10 gap-8">
    <div className="flex flex-col">
      <PageUtils.PageHeading
        title="Theme Configuration"
        subTitle="Configure your dashboard theme and see live preview"
        customSubTitleStyle={`${body.lg.medium} text-gray-500`}
      />
      <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
        // Preview Section
        <div className="lg:col-span-2">
          <div
            className=" relative bg-white rounded-xl shadow-lg overflow-hidden pointer-events-none">
            <div
              className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
              <Icon name="eye" size=18 className="text-gray-500" />
            </div>
            // Mock Dashboard
            <div className="bg-gray-100 p-2 overflow-hidden">
              <div className="bg-white rounded-lg shadow-sm overflow-hidden h-105 w-105">
                <div className="flex h-full">
                  // Org Sidebar
                  {renderOrgTiles()}
                  // Sidebar
                  <div
                    className="w-48 flex flex-col border-r"
                    style={ReactDOM.Style.make(~backgroundColor=theme.sidebar.primary, ())}>
                    <div className="p-4 border-b border-gray-200">
                      <div
                        className="font-semibold text-sm"
                        style={ReactDOM.Style.make(~color=theme.sidebar.textColor, ())}>
                        {React.string("Merchant Tester")}
                      </div>
                    </div>
                    <nav className="flex-1 py-4 space-y-1">
                      {sidebarItems
                      ->Belt.Array.map(renderSidebarItem)
                      ->React.array}
                    </nav>
                  </div>
                  // Main Content
                  <div className="flex-1 flex flex-col overflow-hidden bg-gray-50">
                    // Navbar
                    <div className="flex items-center justify-between h-14 px-6">
                      <div className="font-sm text-base text-gray-800">
                        {"new_profile"->React.string}
                      </div>
                      <div className="relative w-48 bg-white">
                        <input
                          type_="text"
                          placeholder="Search"
                          className="w-full pl-8 pr-3 py-2 rounded-md border border-gray-300 bg-gray-50 text-xs"
                        />
                        <Icon
                          name="search"
                          className="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-500"
                        />
                      </div>
                    </div>
                    <div className="flex-1 p-6  overflow-y-auto">
                      <div className="mb-6">
                        <h2 className="text-lg font-semibold text-gray-900 mb-2">
                          {`${greeting}, it's great to see you!`->React.string}
                        </h2>
                        <p className="text-gray-600 text-sm">
                          {React.string("Welcome to the home of your Payments Control Centre.")}
                        </p>
                      </div>
                      // Cards Row
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div
                          className="bg-white p-6 rounded-lg shadow-sm flex flex-col justify-between">
                          <div>
                            <div className="flex items-center mb-4">
                              <div
                                className="w-10 h-8 bg-green-100 rounded-lg flex items-center justify-center mr-4">
                                <div className="w-5 h-5 bg-green-500 rounded" />
                              </div>
                              <span className="font-semibold text-gray-900 text-md">
                                {React.string("Demo checkout..")}
                              </span>
                            </div>
                            <p className="text-gray-600 mb-4 text-sm">
                              {React.string("Visualise the checkout experience..")}
                            </p>
                          </div>
                          <button
                            className="w-full px-2 py-2 rounded-md text-xs font-medium transition-colors hover:opacity-90"
                            style={ReactDOM.Style.make(
                              ~backgroundColor=theme.buttons.primary.backgroundColor,
                              ~color=theme.buttons.primary.textColor,
                              (),
                            )}>
                            {React.string("Try it out")}
                          </button>
                        </div>
                        <div
                          className="bg-white p-6 rounded-lg shadow-sm flex flex-col justify-between">
                          <div>
                            <div className="flex items-center mb-4">
                              <div
                                className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
                                <div className="w-5 h-5 bg-blue-500 rounded" />
                              </div>
                              <span className="font-semibold text-gray-900 text-md">
                                {React.string("Credentials and Keys")}
                              </span>
                            </div>
                            <p className="text-gray-600 text-sm">
                              {React.string("Your secret credentials to start integrating")}
                            </p>
                          </div>
                          <button
                            className="w-full px-2 py-2 rounded-md text-xs font-medium transition-colors hover:opacity-90"
                            style={ReactDOM.Style.make(
                              ~backgroundColor=theme.buttons.secondary.backgroundColor,
                              ~color=theme.buttons.secondary.textColor,
                              (),
                            )}>
                            {React.string("Go to API keys")}
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        // Configuration Panel
        <div className="space-y-6 max-h-screen overflow-y-auto bg-gray-50 p-6">
          // Basic Settings
          <div className="bg-white rounded-xl shadow-lg p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-6">
              {React.string("Basic Settings")}
            </h2>
            <div className="space-y-4">
              {renderTextInput("Theme Name", theme.themeName, handleThemeNameChange)}
              {renderColorInput("Primary Color", theme.primaryColor, handlePrimaryColorChange)}
            </div>
          </div>
          // Sidebar Settings
          <div className="bg-white rounded-xl shadow-lg p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-6">
              {React.string("Sidebar Settings")}
            </h2>
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
          // Button Settings
          <div className="bg-white rounded-xl shadow-lg p-6 ">
            <h2 className="text-lg font-semibold text-gray-900 mb-6">
              {React.string("Button Settings")}
            </h2>
            <div className="space-y-6">
              <div>
                <h3 className="text-md font-medium text-gray-800 mb-3">
                  {React.string("Primary Button")}
                </h3>
                <div className="space-y-3 pointer-events-auto">
                  {renderColorInput("Background", theme.buttons.primary.backgroundColor, v =>
                    handleButtonChange("primary", "backgroundColor", v)
                  )}
                  {renderColorInput("Text Color", theme.buttons.primary.textColor, v =>
                    handleButtonChange("primary", "textColor", v)
                  )}
                  {renderColorInput(
                    "Hover Background",
                    theme.buttons.primary.hoverBackgroundColor,
                    v => handleButtonChange("primary", "hoverBackgroundColor", v),
                  )}
                </div>
              </div>
              <div>
                <h3 className="text-md font-medium text-gray-800 mb-3">
                  {React.string("Secondary Button")}
                </h3>
                <div className="space-y-3 pointer-events-auto">
                  {renderColorInput("Background", theme.buttons.secondary.backgroundColor, v =>
                    handleButtonChange("secondary", "backgroundColor", v)
                  )}
                  {renderColorInput("Text Color", theme.buttons.secondary.textColor, v =>
                    handleButtonChange("secondary", "textColor", v)
                  )}
                  {renderColorInput(
                    "Hover Background",
                    theme.buttons.secondary.hoverBackgroundColor,
                    v => handleButtonChange("secondary", "hoverBackgroundColor", v),
                  )}
                </div>
              </div>
            </div>
          </div>
          // Asset Settings
          <div className="bg-white rounded-xl shadow-lg p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-6"> {React.string("Assets")} </h2>
            <div className="space-y-4">
              {renderImageUploader("Logo URL", theme.logoUrl, v =>
                updateTheme(t => {...t, logoUrl: v})
              )}
              {renderImageUploader("Favicon URL", theme.faviconUrl, v =>
                updateTheme(t => {...t, faviconUrl: v})
              )}
            </div>
          </div>
          // Actions
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="space-y-3">
              <button
                className="w-full px-4 py-2 rounded-md font-medium transition-colors hover:opacity-90"
                style={ReactDOM.Style.make(
                  ~backgroundColor=theme.buttons.primary.backgroundColor,
                  ~color=theme.buttons.primary.textColor,
                  (),
                )}>
                {React.string("Apply Theme")}
              </button>
              <button
                className="w-full px-4 py-2 rounded-md font-medium transition-colors hover:opacity-90"
                style={ReactDOM.Style.make(
                  ~backgroundColor=theme.buttons.secondary.backgroundColor,
                  ~color=theme.buttons.secondary.textColor,
                  (),
                )}>
                {React.string("Reset to Default")}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}

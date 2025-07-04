open ThemePreviewUtils
open Typography
open ThemePreviewTypes

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

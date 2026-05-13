open ThemePreviewTypes

let sidebarItems = [
  {label: "Module Name", active: false},
  {label: "Section #1", active: false},
  {label: "Section #2", active: true},
  {label: "Section #3", active: false},
]

let getThemeFormValues = (~formValues) => {
  open LogicUtils
  let defaultThemeSettings = ThemeProvider.fallbackThemeConfig.settings
  let themeData = formValues->getDictfromDict("theme_data")
  let settings = themeData->getDictfromDict("settings")
  let colorsDict = settings->getDictfromDict("colors")
  let colors: HyperSwitchConfigTypes.colorPalette = {
    primary: colorsDict->getString("primary", defaultThemeSettings.colors.primary),
    secondary: colorsDict->getString("secondary", defaultThemeSettings.colors.secondary),
    background: colorsDict->getString("background", defaultThemeSettings.colors.background),
  }

  let sidebarDict = settings->getDictfromDict("sidebar")
  let sidebar: HyperSwitchConfigTypes.sidebarConfig = {
    primary: sidebarDict->getString("primary", defaultThemeSettings.sidebar.primary),
    textColor: sidebarDict->getString("textColor", defaultThemeSettings.sidebar.textColor),
    textColorPrimary: sidebarDict->getString(
      "textColorPrimary",
      defaultThemeSettings.sidebar.textColorPrimary,
    ),
  }

  let buttonsDict = settings->getDictfromDict("buttons")
  let primaryButtonDict = buttonsDict->getDictfromDict("primary")
  let secondaryButtonDict = buttonsDict->getDictfromDict("secondary")

  let buttons: HyperSwitchConfigTypes.buttonConfig = {
    primary: {
      backgroundColor: primaryButtonDict->getString(
        "backgroundColor",
        defaultThemeSettings.buttons.primary.backgroundColor,
      ),
      textColor: primaryButtonDict->getString(
        "textColor",
        defaultThemeSettings.buttons.primary.textColor,
      ),
      hoverBackgroundColor: primaryButtonDict->getString(
        "hoverBackgroundColor",
        defaultThemeSettings.buttons.primary.hoverBackgroundColor,
      ),
    },
    secondary: {
      backgroundColor: secondaryButtonDict->getString(
        "backgroundColor",
        defaultThemeSettings.buttons.secondary.backgroundColor,
      ),
      textColor: secondaryButtonDict->getString(
        "textColor",
        defaultThemeSettings.buttons.secondary.textColor,
      ),
      hoverBackgroundColor: secondaryButtonDict->getString(
        "hoverBackgroundColor",
        defaultThemeSettings.buttons.secondary.hoverBackgroundColor,
      ),
    },
  }

  (colors, sidebar, buttons)
}

let getEmailFormValues = (~formValues): HyperSwitchConfigTypes.emailConfig => {
  open LogicUtils
  let defaults = ThemeProvider.defaultEmailConfig
  let emailDict = formValues->getDictfromDict("email_config")
  {
    entity_name: emailDict->getString("entity_name", defaults.entity_name),
    entity_logo_url: emailDict->getString("entity_logo_url", defaults.entity_logo_url),
    primary_color: emailDict->getString("primary_color", defaults.primary_color),
    foreground_color: emailDict->getString("foreground_color", defaults.foreground_color),
    background_color: emailDict->getString("background_color", defaults.background_color),
  }
}

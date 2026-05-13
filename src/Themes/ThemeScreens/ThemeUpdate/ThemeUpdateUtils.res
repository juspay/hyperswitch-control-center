open ThemeUpdateType
open LogicUtils

let themeBodyMapper = (json: JSON.t): themeUpdate => {
  let dict = getDictFromJsonObject(json)
  let themeJsonObject = getJsonObjectFromDict(dict, "theme_data")
  let theme_data = ThemeUtils.parseThemeJson(
    ~uiConfig=themeJsonObject,
    ~fallbackThemeConfig=ThemeProvider.fallbackThemeConfig,
  )
  let emailDict = dict->getDictfromDict("email_config")
  let email_config: HyperSwitchConfigTypes.emailConfig = {
    entity_name: getString(emailDict, "entity_name", ""),
    entity_logo_url: getString(emailDict, "entity_logo_url", ""),
    primary_color: getString(emailDict, "primary_color", ""),
    foreground_color: getString(emailDict, "foreground_color", ""),
    background_color: getString(emailDict, "background_color", ""),
  }
  {
    theme_data,
    email_config,
  }
}

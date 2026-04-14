open ThemeUpdateType
open LogicUtils

let themeBodyMapper = (json: JSON.t): themeUpdate => {
  let dict = getDictFromJsonObject(json)
  let theme_data = getJsonObjectFromDict(dict, "theme_data")->ThemeProvider.parseThemeJson
  let emailConfigJson = dict->getvalFromDict("email_config")
  let email_config: option<HyperSwitchConfigTypes.emailConfig> = switch emailConfigJson {
  | Some(emailJson) => {
      let emailDict = getDictFromJsonObject(emailJson)
      Some({
        entity_name: getString(emailDict, "entity_name", ""),
        entity_logo_url: getString(emailDict, "entity_logo_url", ""),
        primary_color: getString(emailDict, "primary_color", ""),
        foreground_color: getString(emailDict, "foreground_color", ""),
        background_color: getString(emailDict, "background_color", ""),
      })
    }
  | None => None
  }
  {
    theme_data,
    email_config,
  }
}

open ThemeCreateType
open ThemeV2Types
open HyperSwitchConfigTypes
let themeBodyMapper = (json: JSON.t): themeCreate => {
  let dict = LogicUtils.getDictFromJsonObject(json)
  let lineage = {
    entity_type: LogicUtils.getString(dict, "entity_type", ""),
    tenant_id: LogicUtils.getString(dict, "tenant_id", ""),
    org_id: LogicUtils.getOptionString(dict, "org_id"),
    merchant_id: LogicUtils.getOptionString(dict, "merchant_id"),
    profile_id: LogicUtils.getOptionString(dict, "profile_id"),
  }
  let theme_name = LogicUtils.getString(dict, "theme_name", "")
  let themeDataJson =
    LogicUtils.getJsonObjectFromDict(dict, "theme_data")->ThemeProvider.themeDataJsonMapper
  let theme_data: customStylesTheme = themeDataJson
  let emailConfigJson = dict->LogicUtils.getvalFromDict("email_config")
  let email_config = switch emailConfigJson {
  | Some(emailJson) => {
      let emailDict = LogicUtils.getDictFromJsonObject(emailJson)
      Some({
        entity_name: LogicUtils.getString(emailDict, "entity_name", ""),
        entity_logo_url: LogicUtils.getString(emailDict, "entity_logo_url", ""),
        primary_color: LogicUtils.getString(emailDict, "primary_color", ""),
        foreground_color: LogicUtils.getString(emailDict, "foreground_color", ""),
        background_color: LogicUtils.getString(emailDict, "background_color", ""),
      })
    }
  | None => None
  }
  {
    lineage,
    theme_name,
    theme_data,
    email_config,
  }
}

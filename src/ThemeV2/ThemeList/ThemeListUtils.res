let extractThemeData = themeObj => {
  let themeDataDict = themeObj->LogicUtils.getDictFromJsonObject
  let themeData =
    themeDataDict->LogicUtils.getJsonObjectFromDict("theme_data")->LogicUtils.getDictFromJsonObject
  let settings =
    themeData->LogicUtils.getJsonObjectFromDict("settings")->LogicUtils.getDictFromJsonObject
  let colors =
    settings->LogicUtils.getJsonObjectFromDict("colors")->LogicUtils.getDictFromJsonObject
  let sidebarColors =
    settings->LogicUtils.getJsonObjectFromDict("sidebar")->LogicUtils.getDictFromJsonObject
  {
    "themeName": themeDataDict->LogicUtils.getString("theme_name", ""),
    "entityType": themeDataDict->LogicUtils.getString("entity_type", ""),
    "orgId": themeDataDict->LogicUtils.getString("org_id", "All"),
    "merchantId": themeDataDict->LogicUtils.getString("merchant_id", "All"),
    "profileId": themeDataDict->LogicUtils.getString("profile_id", "All"),
    "primaryColor": colors->LogicUtils.getString("primary", "#000"),
    "sidebarColor": sidebarColors->LogicUtils.getString("primary", "#fff"),
  }
}

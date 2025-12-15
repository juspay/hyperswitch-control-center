let extractThemeData = themeObj => {
  open LogicUtils
  let themeDataDict = themeObj->getDictFromJsonObject
  let themeData = themeDataDict->getJsonObjectFromDict("theme_data")->getDictFromJsonObject
  let settings = themeData->getJsonObjectFromDict("settings")->getDictFromJsonObject
  let colors = settings->getJsonObjectFromDict("colors")->getDictFromJsonObject
  let sidebarColors = settings->getJsonObjectFromDict("sidebar")->getDictFromJsonObject
  let newDefaultConfigSettings = ThemeProvider.newDefaultConfig.settings

  {
    "themeName": themeDataDict->getString("theme_name", ""),
    "entityType": themeDataDict->getString("entity_type", ""),
    "orgId": themeDataDict->getString("org_id", "All"),
    "merchantId": themeDataDict->getString("merchant_id", "All"),
    "profileId": themeDataDict->getString("profile_id", "All"),
    "primaryColor": colors->getString("primary", newDefaultConfigSettings.colors.primary),
    "sidebarColor": sidebarColors->getString("primary", newDefaultConfigSettings.sidebar.primary),
  }
}

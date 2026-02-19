let entityConfig = (themeData: ThemeListType.themeListObj) => [
  ("Organization", themeData.orgId, #Organization),
  ("Merchant Account", themeData.merchantId, #Merchant),
  ("Profile", themeData.profileId, #Profile),
]

let extractThemeData: _ => ThemeListType.themeListObj = themeObj => {
  open LogicUtils
  let themeDataDict = themeObj->getDictFromJsonObject
  let themeData = themeDataDict->getJsonObjectFromDict("theme_data")->getDictFromJsonObject
  let settings = themeData->getJsonObjectFromDict("settings")->getDictFromJsonObject
  let colors = settings->getJsonObjectFromDict("colors")->getDictFromJsonObject
  let sidebarColors = settings->getJsonObjectFromDict("sidebar")->getDictFromJsonObject
  let newDefaultConfigSettings = ThemeProvider.fallbackThemeConfig.settings

  {
    themeName: themeDataDict->getString("theme_name", ""),
    entityType: themeDataDict->getString("entity_type", ""),
    orgId: themeDataDict->getString("org_id", ""),
    merchantId: themeDataDict->getString("merchant_id", ""),
    profileId: themeDataDict->getString("profile_id", ""),
    primaryColor: colors->getString("primary", newDefaultConfigSettings.colors.primary),
    sidebarColor: sidebarColors->getString("background", newDefaultConfigSettings.sidebar.primary),
  }
}

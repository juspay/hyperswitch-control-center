let extractThemeData = themeObj => {
  open LogicUtils
  let themeDataDict = themeObj->getDictFromJsonObject
  let themeData = themeDataDict->getJsonObjectFromDict("theme_data")->getDictFromJsonObject
  let settings = themeData->getJsonObjectFromDict("settings")->getDictFromJsonObject
  let colors = settings->getJsonObjectFromDict("colors")->getDictFromJsonObject
  let sidebarColors = settings->getJsonObjectFromDict("sidebar")->getDictFromJsonObject
  {
    "themeName": themeDataDict->getString("theme_name", ""),
    "entityType": themeDataDict->getString("entity_type", ""),
    "orgId": themeDataDict->getString("org_id", "All"),
    "merchantId": themeDataDict->getString("merchant_id", "All"),
    "profileId": themeDataDict->getString("profile_id", "All"),
    "primaryColor": colors->getString("primary", "#000"),
    "sidebarColor": sidebarColors->getString("primary", "#fff"),
  }
}

// Helper function to render entity rows
let renderEntityRow = (label, value, entityType, getNameForId) => {
  <React.Fragment key={label}>
    <div className="text-nd_gray-500"> {label->React.string} </div>
    <div>
      {value != "All" ? getNameForId(entityType)->React.string : `All ${label}s`->React.string}
    </div>
  </React.Fragment>
}

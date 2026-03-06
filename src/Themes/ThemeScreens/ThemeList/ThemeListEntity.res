open ThemeHelper
open LogicUtils

type themeObj = {
  theme_id: string,
  theme_name: string,
  entity_type: string,
  merchant_id: option<string>,
  profile_id: option<string>,
  org_id: option<string>,
  tenant_id: option<string>,
  theme_data: Js.Json.t,
}

type cols =
  | ThemeName
  | ThemeEntity
  | Tenant
  | Organization
  | Merchant
  | Profile
  | ThemeColours

let visibleColumns = [ThemeName, ThemeEntity, Organization, Merchant, Profile, ThemeColours]

let colMapper = (col: cols) => {
  switch col {
  | ThemeName => "theme_name"
  | ThemeEntity => "entity_type"
  | Tenant => "tenant_id"
  | Organization => "org_id"
  | Merchant => "merchant_id"
  | Profile => "profile_id"
  | ThemeColours => "theme_colours"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => themeObj = dict => {
  {
    theme_id: dict->getString("theme_id", ""),
    theme_name: dict->getString("theme_name", ""),
    entity_type: dict->getString("entity_type", ""),
    merchant_id: dict->getOptionString("merchant_id"),
    profile_id: dict->getOptionString("profile_id"),
    org_id: dict->getOptionString("org_id"),
    tenant_id: dict->getOptionString("tenant_id"),
    theme_data: dict->getJsonObjectFromDict("theme_data"),
  }
}

let getObjects: JSON.t => array<themeObj> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => tableItemToObjMapper(item->getDictFromJsonObject))
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | ThemeName => Table.makeHeaderInfo(~key, ~title="Theme Name", ~dataType=TextType)
  | ThemeEntity => Table.makeHeaderInfo(~key, ~title="Theme Entity", ~dataType=TextType)
  | Tenant => Table.makeHeaderInfo(~key, ~title="Tenant", ~dataType=TextType)
  | Organization => Table.makeHeaderInfo(~key, ~title="Organization", ~dataType=TextType)
  | Merchant => Table.makeHeaderInfo(~key, ~title="Merchant", ~dataType=TextType)
  | Profile => Table.makeHeaderInfo(~key, ~title="Profile", ~dataType=TextType)
  | ThemeColours => Table.makeHeaderInfo(~key, ~title="Theme Colours", ~dataType=TextType)
  }
}
let fallbackThemeConfigSettings = ThemeProvider.fallbackThemeConfig.settings
let getCell = (themeObj, colType): Table.cell => {
  open Table
  switch colType {
  | ThemeName => Text(themeObj.theme_name)
  | ThemeEntity =>
    let entityLabel: UserInfoTypes.entity = themeObj.entity_type->UserInfoUtils.entityMapper
    Text(`${(entityLabel :> string)} level `)
  | Tenant => themeObj.tenant_id->Option.mapOr(Text("All Tenant"), id => Text(id))

  | Organization => themeObj.org_id->Option.mapOr(Text("All Organizations"), id => Text(id))
  | Merchant => themeObj.merchant_id->Option.mapOr(Text("All Merchants"), id => Text(id))
  | Profile => themeObj.profile_id->Option.mapOr(Text("All Profiles"), id => Text(id))
  | ThemeColours =>
    let themeDataDict = themeObj.theme_data->getDictFromJsonObject
    let settings = themeDataDict->getObj("settings", Dict.make())
    let colors = settings->getObj("colors", Dict.make())
    let sidebarObj = settings->getObj("sidebar", Dict.make())
    let primary = colors->getString("primary", fallbackThemeConfigSettings.colors.primary)
    let sidebar = sidebarObj->getString("primary", fallbackThemeConfigSettings.sidebar.primary)
    Table.CustomCell(<OverlappingCircles colorA=primary colorB=sidebar />, "")
  }
}

let themeTableEntity: EntityType.entityType<cols, Js.Json.t> = EntityType.makeEntity(
  ~uri=``,
  ~getObjects=json => json->getArrayFromJson([]),
  ~defaultColumns=visibleColumns,
  ~allColumns=visibleColumns,
  ~getHeading,
  ~getCell=(json, colType) => getCell(tableItemToObjMapper(json->getDictFromJsonObject), colType),
)

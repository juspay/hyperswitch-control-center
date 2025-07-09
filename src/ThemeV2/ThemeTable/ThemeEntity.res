open ThemeHelper
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
  open LogicUtils
  {
    theme_id: dict->getString("theme_id", ""),
    theme_name: dict->getString("theme_name", ""),
    entity_type: dict->getString("entity_type", ""),
    merchant_id: dict->getOptionString("merchant_id"),
    profile_id: dict->getOptionString("profile_id"),
    org_id: dict->getOptionString("org_id"),
    tenant_id: dict->getOptionString("tenant_id"),
    theme_data: dict->Dict.get("theme_data")->Option.getOr(JSON.Encode.object(Dict.make())), // fallback to empty object
  }
}

let getObjects: JSON.t => array<themeObj> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
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

// Custom cell rendering for each column
let getCell = (themeObj, colType): Table.cell => {
  switch colType {
  | ThemeName => Text(themeObj.theme_name)
  | ThemeEntity =>
    let entityLabel = switch themeObj.entity_type {
    | "organization" => "Organization level"
    | "merchant" => "Merchant level"
    | "profile" => "Profile level"
    | _ => themeObj.entity_type
    }
    Text(entityLabel)

  | Tenant =>
    switch themeObj.tenant_id {
    | Some(id) => Text(id)
    | None => Text("All Tenants")
    }
  | Organization =>
    switch themeObj.org_id {
    | Some(id) => Text(id)
    | None => Text("All")
    }
  | Merchant =>
    switch themeObj.merchant_id {
    | Some(id) => Text(id)
    | None => Text("All")
    }
  | Profile =>
    switch themeObj.profile_id {
    | Some(id) => Text(id)
    | None => Text("All")
    }
  | ThemeColours =>
    let themeDataDict = themeObj.theme_data->LogicUtils.getDictFromJsonObject
    let settings = themeDataDict->LogicUtils.getObj("settings", Dict.make())
    let colors = settings->LogicUtils.getObj("colors", Dict.make())
    let sidebar = settings->LogicUtils.getObj("sidebar", Dict.make())
    let primary = colors->LogicUtils.getString("primary", "#006DF9")
    let sidebar = sidebar->LogicUtils.getString("primary", "#FCFCFD")

    Table.CustomCell(<OverlappingCircles colorA=primary colorB=sidebar />, "")
  }
}

let themeTableEntity: EntityType.entityType<cols, Js.Json.t> = EntityType.makeEntity(
  ~uri="theme-list",
  ~getObjects=json => json->LogicUtils.getArrayFromJson([]),
  ~defaultColumns=visibleColumns,
  ~allColumns=visibleColumns,
  ~getHeading,
  ~getCell=(json, colType) =>
    getCell(tableItemToObjMapper(json->LogicUtils.getDictFromJsonObject), colType),
)

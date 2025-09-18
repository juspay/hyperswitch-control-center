open LogicUtils

type rolesTableTypes = {
  role_name: string,
  role_scope: string,
  groups: array<JSON.t>,
  entity_name: string,
}

type rolesColTypes =
  | RoleName
  | RoleScope
  | EntityType
  | RoleGroupAccess

let defaultColumnsForRoles = [RoleName, EntityType, RoleGroupAccess]

let itemToObjMapperForRoles = dict => {
  {
    role_name: getString(dict, "role_name", ""),
    role_scope: getString(dict, "role_scope", ""),
    groups: getArrayFromDict(dict, "groups", []),
    entity_name: getString(dict, "entity_type", ""),
  }
}

let getHeadingForRoles = (colType: rolesColTypes) => {
  switch colType {
  | RoleName => Table.makeHeaderInfo(~key="role_name", ~title="Role name", ~showSort=true)
  | RoleScope => Table.makeHeaderInfo(~key="role_scope", ~title="Role scope")
  | EntityType => Table.makeHeaderInfo(~key="entity_type", ~title="Entity Type")
  | RoleGroupAccess => Table.makeHeaderInfo(~key="groups", ~title="Module permissions")
  }
}

let getCellForRoles = (data: rolesTableTypes, colType: rolesColTypes): Table.cell => {
  switch colType {
  | RoleName => Text(data.role_name->LogicUtils.snakeToTitle)
  | RoleScope => Text(data.role_scope->LogicUtils.capitalizeString)
  | EntityType => Text(data.entity_name->LogicUtils.capitalizeString)
  | RoleGroupAccess =>
    Table.CustomCell(
      <div>
        {data.groups
        ->LogicUtils.getStrArrayFromJsonArray
        ->Array.map(item => `${item->LogicUtils.snakeToTitle}`)
        ->Array.joinWith(", ")
        ->React.string}
      </div>,
      "",
    )
  }
}

let getrolesData: JSON.t => array<rolesTableTypes> = json => {
  getArrayDataFromJson(json, itemToObjMapperForRoles)
}

let rolesEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getrolesData,
  ~defaultColumns=defaultColumnsForRoles,
  ~allColumns=defaultColumnsForRoles,
  ~getHeading=getHeadingForRoles,
  ~getCell=getCellForRoles,
  ~dataKey="",
)

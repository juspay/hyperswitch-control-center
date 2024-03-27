open LogicUtils

type rolesTableTypes = {
  role_name: string,
  role_scope: string,
  groups: array<JSON.t>,
}

type rolesColTypes =
  | RoleName
  | RoleScope
  | ModulePermissions

let defaultColumnsForRoles = [RoleName, RoleScope, ModulePermissions]

let allColumnsForUser = [RoleName, RoleScope, ModulePermissions]

let itemToObjMapperForRoles = dict => {
  {
    role_name: getString(dict, "role_name", ""),
    role_scope: getString(dict, "role_scope", ""),
    groups: getArrayFromDict(dict, "groups", []),
  }
}

let getHeadingForRoles = (colType: rolesColTypes) => {
  switch colType {
  | RoleName => Table.makeHeaderInfo(~key="role_name", ~title="Role name", ~showSort=true, ())
  | RoleScope => Table.makeHeaderInfo(~key="role_scope", ~title="Role scope", ~showSort=true, ())
  | ModulePermissions => Table.makeHeaderInfo(~key="groups", ~title="Module permissions", ())
  }
}

let getCellForRoles = (data: rolesTableTypes, colType: rolesColTypes): Table.cell => {
  switch colType {
  | RoleName => Text(data.role_name->LogicUtils.snakeToTitle)
  | RoleScope => Text(data.role_scope->LogicUtils.capitalizeString)
  | ModulePermissions =>
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
  ~allColumns=allColumnsForUser,
  ~getHeading=getHeadingForRoles,
  ~getCell=getCellForRoles,
  ~dataKey="",
  (),
)

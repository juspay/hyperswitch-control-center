open LogicUtils
open RolesMatrixTypes

let itemToObjMapperForRoles = dict => {
  {
    roleId: getString(dict, "role_id", ""),
    roleName: getString(dict, "role_name", "")->snakeToTitle,
    entityType: getString(dict, "entity_type", "")->capitalizeString,
    parent_groups: getArrayFromDict(dict, "parent_groups", [])->Array.map(groupDict => {
      let group = getDictFromJsonObject(groupDict)
      {
        name: getString(group, "name", ""),
        description: getString(group, "description", ""),
        scopes: getStrArrayFromDict(group, "scopes", []),
      }
    }),
    roleScope: getString(dict, "role_scope", "")->capitalizeString,
  }
}

let getPermissionLevel = (scopes: array<string>): permissionLevel => {
  let scopeSet = Belt.Set.String.fromArray(scopes)
  if scopeSet->Belt.Set.String.has("write") {
    Edit
  } else if scopeSet->Belt.Set.String.has("read") {
    View
  } else {
    NoAccess
  }
}

let processRolesData = (rolesData: array<roleData>): matrixData => {
  let allModules =
    rolesData
    ->Array.flatMap(r => r.parent_groups->Array.map(g => g.name))
    ->removeDuplicate
  let buildModulePermissions = (moduleName: string) =>
    rolesData->Array.reduce(Dict.make(), (moduleAcc, role) => {
      let permission = switch role.parent_groups->Array.find(g => g.name === moduleName) {
      | Some(group) => getPermissionLevel(group.scopes)
      | None => NoAccess
      }
      moduleAcc->Dict.set(role.roleId, permission)
      moduleAcc
    })
  let permissions = allModules->Array.reduce(Dict.make(), (acc, moduleName) => {
    acc->Dict.set(moduleName, buildModulePermissions(moduleName))
    acc
  })
  {
    modules: allModules,
    roles: rolesData,
    permissions,
  }
}

let getModuleDescription = (moduleName: string, rolesData: array<roleData>): string =>
  switch rolesData->Array.findMap(role =>
    role.parent_groups->Array.find(g => g.name === moduleName)
  ) {
  | Some(group) => group.description
  | None => ""
  }

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
  if scopes->Array.includes("write") {
    Edit
  } else if scopes->Array.includes("read") {
    View
  } else {
    NoAccess
  }
}

let processRolesData = (rolesData: array<roleData>): matrixData => {
  let allModules =
    rolesData
    ->Array.flatMap(role => role.parent_groups)
    ->Array.map(group => group.name)
    ->removeDuplicate

  let permissions = allModules->Array.reduce(Dict.make(), (acc, moduleName) => {
    let modulePermissions = rolesData->Array.reduce(Dict.make(), (moduleAcc, role) => {
      let parentGroup = role.parent_groups->Array.find(g => g.name === moduleName)
      let permissionLevel = switch parentGroup {
      | Some(group) => getPermissionLevel(group.scopes)
      | None => NoAccess
      }
      moduleAcc->Dict.set(role.roleId, permissionLevel)
      moduleAcc
    })
    acc->Dict.set(moduleName, modulePermissions)
    acc
  })

  {
    modules: allModules,
    roles: rolesData,
    permissions,
  }
}

let getModuleDescription = (moduleName: string, rolesData: array<roleData>): string => {
  let moduleData =
    rolesData
    ->Array.flatMap(role => role.parent_groups)
    ->Array.find(group => group.name === moduleName)

  switch moduleData {
  | Some(group) => group.description
  | None => ""
  }
}

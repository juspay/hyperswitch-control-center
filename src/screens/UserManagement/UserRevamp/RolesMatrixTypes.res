type parentGroup = {
  name: string,
  description: string,
  scopes: array<string>,
}

type roleData = {
  roleId: string,
  roleName: string,
  entityType: string,
  parent_groups: array<parentGroup>,
  roleScope: string,
}

type permissionLevel = View | Edit | NoAccess

type matrixData = {
  modules: array<string>,
  roles: array<roleData>,
  permissions: Dict.t<Dict.t<permissionLevel>>,
}

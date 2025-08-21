open LogicUtils
open UserManagementTypes
let validateCustomRoleForm = (values, permissionModules) => {
  let valuesDict = values->getDictFromJsonObject
  let errors = Dict.make()

  if valuesDict->getString("role_scope", "")->isEmptyString {
    Dict.set(errors, "role_scope", "Role scope is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->isEmptyString {
    Dict.set(errors, "role_name", "Role name is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->String.length > 64 {
    Dict.set(errors, "role_name", "Role name should be less than 64 characters"->JSON.Encode.string)
  }

  let hasPermissions = permissionModules->Array.some(module_ => {
    let moduleName = module_.name
    let moduleData = Dict.get(valuesDict, moduleName)

    switch moduleData {
    | Some(moduleJson) => {
        let moduleDict = moduleJson->getDictFromJsonObject
        let readSelected = getBool(moduleDict, "read", false)
        let writeSelected = getBool(moduleDict, "write", false)
        readSelected || writeSelected
      }
    | None => false
    }
  })

  if !hasPermissions {
    Dict.set(errors, "permissions", "At least one permission must be selected"->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}

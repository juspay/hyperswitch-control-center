open LogicUtils
open UserManagementTypes

let getInitialValuesForForm = entityType =>
  [
    ("role_scope", "merchant"->JSON.Encode.string),
    ("role_name", ""->JSON.Encode.string),
    ("entity_type", entityType->JSON.Encode.string),
  ]->Dict.fromArray

let validateCustomRoleForm = (values, ~permissionModules=[], ~isV2=false, ()) => {
  let errors = Dict.make()
  let valuesDict = values->getDictFromJsonObject
  if valuesDict->getString("role_scope", "")->isEmptyString {
    Dict.set(errors, "role_scope", "Role scope is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->isEmptyString {
    Dict.set(errors, "role_name", "Role name is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->String.length > 64 {
    Dict.set(errors, "role_name", "Role name should be less than 64 characters"->JSON.Encode.string)
  }

  if isV2 && permissionModules->Array.length > 0 {
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
      Dict.set(
        errors,
        "permissions",
        "At least one permission must be selected"->JSON.Encode.string,
      )
    }
  } else if !isV2 {
    if valuesDict->getArrayFromDict("groups", [])->Array.length === 0 {
      Dict.set(errors, "groups", "Roles required"->JSON.Encode.string)
    }
  }

  errors->JSON.Encode.object
}

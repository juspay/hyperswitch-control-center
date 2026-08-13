open LogicUtils
open UserManagementTypes

let updateScope = (scopes, action, targetScope: groupScopeType) => {
  let target = (targetScope :> string)->String.toLowerCase
  switch action {
  | Add => scopes->Array.includes(target) ? scopes : scopes->Array.concat([target])
  | Remove => scopes->Array.filter(s => s !== target)
  }
}

// The `Configurations` parent group maps to the `SuperpositionConfig` resource alone, so a role
// built out of it and nothing else carries no `Account` resource and lands the user on a dashboard
// that cannot bootstrap. It has to be paired with at least one other module.
let configurationsParentGroup = "Configurations"

let configurationsGroups =
  [ConfigurationsView, ConfigurationsManage]->Array.map(
    GroupACLMapper.mapGroupAccessTypeToString,
  )

let configurationsOnlyRoleError = "Configurations cannot be the only module in a role. Select at least one more module."

let getInitialValuesForForm = (entityType: UserInfoTypes.entity) =>
  [
    ("role_scope", "merchant"->JSON.Encode.string),
    ("role_name", ""->JSON.Encode.string),
    ("entity_type", (entityType :> string)->String.toLowerCase->JSON.Encode.string),
  ]->Dict.fromArray

let validateCustomRoleForm = (values, ~permissionModules=[], ~isV2=false) => {
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
    let selectedParentGroups =
      valuesDict
      ->getArrayFromDict("parent_groups", [])
      ->Array.filterMap(groupJson => {
        let groupDict = groupJson->getDictFromJsonObject
        let scopes = getStrArrayFromJson(getJsonObjectFromDict(groupDict, "scopes"))
        scopes->Array.length > 0 ? Some(groupDict->getString("name", "")) : None
      })

    if selectedParentGroups->Array.length === 0 {
      Dict.set(
        errors,
        "permissions",
        "At least one permission must be selected"->JSON.Encode.string,
      )
    } else if selectedParentGroups->Array.every(name => name === configurationsParentGroup) {
      Dict.set(errors, "permissions", configurationsOnlyRoleError->JSON.Encode.string)
    }
  } else if !isV2 {
    let selectedGroups = valuesDict->getArrayFromDict("groups", [])->getStrArrayFromJsonArray

    if selectedGroups->Array.length === 0 {
      Dict.set(errors, "groups", "Roles required"->JSON.Encode.string)
    } else if selectedGroups->Array.every(group => configurationsGroups->Array.includes(group)) {
      Dict.set(errors, "groups", configurationsOnlyRoleError->JSON.Encode.string)
    }
  }

  errors->JSON.Encode.object
}

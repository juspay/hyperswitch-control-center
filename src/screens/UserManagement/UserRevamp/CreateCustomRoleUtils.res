open LogicUtils
open UserManagementTypes

let updateScope = (scopes: array<string>, action: scopeAction, targetScope: string) => {
  switch action {
  | Add => scopes->Array.includes(targetScope) ? scopes : scopes->Array.concat([targetScope])
  | Remove => scopes->Array.filter(s => s !== targetScope)
  }
}

let getInitialValuesForForm = entityType =>
  [
    ("role_scope", "merchant"->JSON.Encode.string),
    ("role_name", ""->JSON.Encode.string),
    ("entity_type", entityType->JSON.Encode.string),
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
    let parentGroups = valuesDict->getArrayFromDict("parent_groups", [])
    let hasPermissions = parentGroups->Array.some(groupJson => {
      let groupDict = groupJson->getDictFromJsonObject
      let scopes = getStrArryFromJson(getJsonObjectFromDict(groupDict, "scopes"))
      scopes->Array.length > 0
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

let getCurrentScopes = (~moduleIndex, ~field: ReactFinalForm.fieldRenderProps) => {
  let allGroups = field.input.value->getArrayFromJson([])
  let currentGroup = allGroups[moduleIndex]

  switch currentGroup {
  | Some(groupJson) => {
      let groupDict = groupJson->getDictFromJsonObject
      getStrArryFromJson(getJsonObjectFromDict(groupDict, "scopes"))
    }
  | None => []
  }
}

let updateScopes = (newScopes, moduleIndex, field: ReactFinalForm.fieldRenderProps) => {
  let allGroups = field.input.value->getArrayFromJson([])
  let updatedGroups = allGroups->Array.mapWithIndex((group, index) => {
    if index === moduleIndex {
      let groupDict = group->getDictFromJsonObject
      groupDict->Dict.set("scopes", newScopes->JSON.Encode.array)
      groupDict->JSON.Encode.object
    } else {
      group
    }
  })
  field.input.onChange(updatedGroups->Identity.arrayOfGenericTypeToFormReactEvent)
}

let scopeToString = scope => {
  switch scope {
  | Read => "read"
  | Write => "write"
  }
}

let handleScopeChange = (
  scope,
  isSelected: bool,
  ~moduleIndex,
  ~field: ReactFinalForm.fieldRenderProps,
) => {
  let currentScopes = getCurrentScopes(~moduleIndex, ~field)
  let scopeString = scope->scopeToString
  let newScopes = updateScope(currentScopes, isSelected ? Add : Remove, scopeString)

  let finalScopes = switch (scope, isSelected) {
  | (Write, true) => updateScope(newScopes, Add, "read")
  | (Read, false) => updateScope(newScopes, Remove, "write")
  | _ => newScopes
  }

  updateScopes(finalScopes->Array.map(JSON.Encode.string), moduleIndex, field)
}

let getMerchantSelectBoxOption = (
  ~label,
  ~value,
  ~dropdownList: array<OMPSwitchTypes.ompListTypes>,
  ~showAllSelection=false,
) => {
  let allOptions: SelectBox.dropdownOption = {
    label,
    value,
    customRowClass: "!border-b py-2",
    textColor: "font-semibold",
  }
  let orgOptions =
    dropdownList->Array.map((item): SelectBox.dropdownOption => {label: item.name, value: item.id})

  if showAllSelection {
    [allOptions, ...orgOptions]
  } else {
    orgOptions
  }
}

let validateEmptyValue = (key, errors) => {
  switch key {
  | "emailList" => Dict.set(errors, "email", "Please enter Invite mails"->JSON.Encode.string)
  | "roleType" => Dict.set(errors, "roleType", "Please enter a role"->JSON.Encode.string)
  | _ => Dict.set(errors, key, `Please enter a ${key->LogicUtils.snakeToTitle}`->JSON.Encode.string)
  }
}

let validateForm = (values, ~fieldsToValidate: array<string>) => {
  let errors = Dict.make()
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    let value = valuesDict->getJsonObjectFromDict(key)

    switch value {
    | Array(listofemails) =>
      if listofemails->Array.length === 0 {
        key->validateEmptyValue(errors)
      } else {
        listofemails->Array.forEach(ele => {
          if ele->JSON.Decode.string->Option.getOr("")->HSwitchUtils.isValidEmail {
            errors->Dict.set("email", "Please enter a valid email"->JSON.Encode.string)
          }
        })
        ()
      }
    | String(roleType) =>
      if roleType->LogicUtils.isEmptyString {
        key->validateEmptyValue(errors)
      }
    | _ => key->validateEmptyValue(errors)
    }
  })

  errors->JSON.Encode.object
}

let itemToObjMapperForGetRoleInfro: Dict.t<JSON.t> => UserManagementTypes.userModuleType = dict => {
  open LogicUtils
  {
    parentGroup: getString(dict, "name", ""),
    description: getString(dict, "description", ""),
    groups: getStrArrayFromDict(dict, "groups", []),
  }
}

let groupsAccessWrtToArray = (groupsList, userRoleAccessValueList) => {
  groupsList->Array.reduce([], (acc, value) => {
    if userRoleAccessValueList->Array.includes(value) && value->String.includes("view") {
      acc->Array.push("View")
    } else if userRoleAccessValueList->Array.includes(value) && value->String.includes("manage") {
      acc->Array.push("Manage")
    }
    acc
  })
}

let modulesWithUserAccess = (
  roleInfo: array<UserManagementTypes.userModuleType>,
  userAcessGroup,
) => {
  open UserManagementTypes
  let modulesWithAccess = []
  let modulesWithoutAccess = []

  roleInfo->Array.forEach(items => {
    let access = groupsAccessWrtToArray(items.groups, userAcessGroup)
    let manipulatedObject = {
      parentGroup: items.parentGroup,
      description: items.description,
      groups: access,
    }

    if access->Array.length > 0 {
      modulesWithAccess->Array.push(manipulatedObject)
    } else {
      modulesWithoutAccess->Array.push(manipulatedObject)
    }
  })
  (modulesWithAccess, modulesWithoutAccess)
}

let getNameAndIdFromDict: (Dict.t<JSON.t>, string) => UserManagementTypes.orgObjectType = (
  dict,
  default,
) => {
  open LogicUtils
  dict->isEmptyDict
    ? {
        name: default,
        value: default,
        id: None,
      }
    : {
        name: dict->getString("name", ""),
        value: dict->getString("id", ""),
        id: dict->getOptionString("id"),
      }
}

let itemToObjMapper: Dict.t<JSON.t> => UserManagementTypes.userDetailstype = dict => {
  open LogicUtils
  {
    roleId: dict->getString("role_id", ""),
    roleName: dict->getString("role_name", ""),
    org: dict->getDictfromDict("org")->getNameAndIdFromDict("all_orgs"),
    merchant: dict->getDictfromDict("merchant")->getNameAndIdFromDict("all_merchants"),
    profile: dict->getDictfromDict("profile")->getNameAndIdFromDict("all_profiles"),
    status: dict->getString("status", ""),
    entityType: dict->getString("entity_type", ""),
  }
}

let valueToType: JSON.t => array<UserManagementTypes.userDetailstype> = json => {
  open LogicUtils
  json->getArrayDataFromJson(itemToObjMapper)
}

let groupByMerchants: array<UserManagementTypes.userDetailstype> => Dict.t<
  array<UserManagementTypes.userDetailstype>,
> = typedValue => {
  let dict = Dict.make()

  typedValue->Array.forEach(item => {
    switch dict->Dict.get(item.merchant.value) {
    | Some(value) => dict->Dict.set(item.merchant.value, [item, ...value])
    | None => dict->Dict.set(item.merchant.value, [item])
    }
  })

  dict
}

let getLabelForStatus = value => {
  switch value {
  | "InvitationSent" => (
      UserManagementTypes.InviteSent,
      "text-orange-950 bg-orange-950 bg-opacity-20",
    )
  | "Active" => (UserManagementTypes.Active, "text-green-700 bg-green-700 bg-opacity-20")
  | _ => (UserManagementTypes.None, "text-grey-700 opacity-50")
  }
}

let stringToVariantMapperForAccess = accessAvailable => {
  open UserManagementTypes
  switch accessAvailable {
  | "Manage" => Manage
  | "View" | _ => View
  }
}

let makeSelectBoxOptions = result => {
  open LogicUtils

  result
  ->getObjectArrayFromJson
  ->Array.map(objectvalue => {
    let value: SelectBox.dropdownOption = {
      label: objectvalue->getString("role_name", ""),
      value: objectvalue->getString("role_id", ""),
    }
    value
  })
}

let getEntityType = valueDict => {
  /*
 INFO: For the values (Organisation , Merchant , Profile) in form 

 (Some(org_id) , all merchants ,  all profiles) --> get roles for organisation
 (Some(org_id) , Some(merchant_id) ,  all profiles) --> get roles for merchants
 (Some(org_id) , Some(merchant_id) ,  Some(profile_id)) --> get roles for profiles
 */

  open LogicUtils
  let orgValue = valueDict->getOptionString("org_value")
  let merchantValue = valueDict->getOptionString("merchant_value")
  let profileValue = valueDict->getOptionString("profile_value")

  switch (orgValue, merchantValue, profileValue) {
  | (Some(_orgId), Some("all_merchants"), Some("all_profiles")) => "organisation"
  | (Some(_orgId), Some(_merchnatId), Some("all_profiles")) => "merchant"
  | (Some(_orgId), Some(_merchnatId), Some(_profileId)) => "profile"
  | _ => ""
  }
}

let stringToVariantForAllSelection = formStringValue =>
  switch formStringValue {
  | "all_merchants" => Some(#All_Merchants)
  | "all_profiles" => Some(#All_Profiles)
  | _ => None
  }

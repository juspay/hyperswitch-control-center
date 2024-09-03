let moduleListRecoil: Recoil.recoilAtom<array<UserManagementTypes.userModuleType>> = Recoil.atom(
  "moduleListRecoil",
  [],
)

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

let inviteEmail = FormRenderer.makeFieldInfo(
  ~label="Enter email (s) ",
  ~name="email_list",
  ~customInput=(~input, ~placeholder as _) => {
    let showPlaceHolder = input.value->LogicUtils.getArrayFromJson([])->Array.length === 0
    InputFields.textTagInput(
      ~input,
      ~placeholder=showPlaceHolder ? "Eg: mehak.sam@wise.com, deepak.ven@wise.com" : "",
      ~customButtonStyle="!rounded-full !px-4",
      ~seperateByComma=true,
    )
  },
  ~isRequired=true,
)

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
      if roleType->String.length === 0 {
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

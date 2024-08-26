let moduleListRecoil: Recoil.recoilAtom<array<UserManagementTypes.userModuleType>> = Recoil.atom(
  "moduleListRecoil",
  [],
)

let predefinedRoles: array<SelectBox.dropdownOption> = [
  {
    label: "Developer",
    value: "merchant_developer",
  },
  {
    label: "IAM",
    value: "merchant_iam_admin",
  },
  {
    label: "Operator",
    value: "merchant_operator",
  },
  {
    label: "Customer support",
    value: "merchant_customer_support",
  },
  {
    label: "View only",
    value: "merchant_view_only",
  },
  {
    label: "Merchant Admin",
    value: "merchant_admin",
  },
]

let getMerchantSelectBoxOption = (~label, ~value, ~options) => {
  let allMerchantOption: SelectBox.dropdownOption = {
    label,
    value,
    customRowClass: "!border-b py-2",
    textColor: "font-semibold",
  }
  [allMerchantOption, ...options->SelectBox.makeOptions]
}

let inviteEmail = FormRenderer.makeFieldInfo(
  ~label="Enter email (s) ",
  ~name="emailList",
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

let organizationSelection = FormRenderer.makeFieldInfo(
  ~label="Select an organization",
  ~name="org_value",
  ~customInput=InputFields.selectInput(
    ~options=getMerchantSelectBoxOption(
      ~label="All organizations",
      ~value="all_organizations",
      ~options=["Org1", "Org2", "Org3", "Org4", "Org5"],
    ),
    ~buttonText="Select an organization",
    ~fullLength=true,
    ~customButtonStyle="!rounded-lg",
    ~dropdownCustomWidth="!w-full",
    ~textStyle="!text-gray-500",
  ),
)
let merchantSelection = FormRenderer.makeFieldInfo(
  ~label="Merchants for access",
  ~name="merchant_value",
  ~customInput=InputFields.selectInput(
    ~options=getMerchantSelectBoxOption(
      ~label="All merchants",
      ~value="all_merchants",
      ~options=["Merch1", "Merch2", "Merch3", "Merch4", "Merch5"],
    ),
    ~buttonText="Select a Merchant",
    ~fullLength=true,
    ~customButtonStyle="!rounded-lg",
    ~dropdownCustomWidth="!w-full",
    ~textStyle="!text-gray-500",
  ),
)
let profileSelection = FormRenderer.makeFieldInfo(
  ~label="Profiles for access",
  ~name="profile_value",
  ~customInput=InputFields.selectInput(
    ~options=getMerchantSelectBoxOption(
      ~label="All profiles",
      ~value="all_profiles",
      ~options=["Profile1", "Profile2", "Profile3", "Profile4", "Profile5"],
    ),
    ~buttonText="Select a Profile",
    ~fullLength=true,
    ~customButtonStyle="!rounded-lg",
    ~dropdownCustomWidth="!w-full",
    ~textStyle="!text-gray-500",
  ),
)

let roleSelection = FormRenderer.makeFieldInfo(
  ~label="Select a role",
  ~name="roleType",
  ~customInput=InputFields.selectInput(
    ~options=predefinedRoles,
    ~buttonText="Select a role",
    ~fullLength=true,
    ~customButtonStyle="!rounded-lg",
    ~dropdownCustomWidth="!w-full",
    ~textStyle="!text-gray-500",
  ),
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
  let response = groupsList->Array.reduce([], (acc, value) => {
    if userRoleAccessValueList->Array.includes(value) && value->String.includes("view") {
      let _ = [acc->Array.push("View")]
    } else if userRoleAccessValueList->Array.includes(value) && value->String.includes("manage") {
      let _ = acc->Array.push("Manage")
    }
    acc
  })
  response
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

let tabIndexToVariantMapper = index => {
  open UserManagementTypes
  switch index {
  | 0 => Users
  | _ => Roles
  }
}

let stringToVariantMapperForAccess = accessAvailable => {
  open UserManagementTypes
  switch accessAvailable {
  | "View" => View
  | "Manage" => Manage
  | _ => View
  }
}
let getNameAndIdFromDict: (Dict.t<JSON.t>, string) => UserManagementTypes.orgObjectType = (
  dict,
  default,
) => {
  open LogicUtils
  dict->isEmptyDict
    ? {
        name: default,
        id: default,
      }
    : {
        name: dict->getString("name", ""),
        id: dict->getString("id", ""),
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
    switch dict->Dict.get(item.merchant.id) {
    | Some(value) => dict->Dict.set(item.merchant.id, [item, ...value])
    | None => dict->Dict.set(item.merchant.id, [item])
    }
  })

  dict
}

type userStatusTypes = Active | InviteSent | None

let getLabelForStatus = value =>
  switch value {
  | "invite_sent" => (InviteSent, "text-orange-950 bg-orange-950 bg-opacity-20")
  | "active" => (Active, "text-green-700 bg-green-700 bg-opacity-20")
  | _ => (None, "text-grey-700 opacity-50")
  }

open OMPSwitchTypes
let ompDefaultValue = (currUserId, currUserName) => [
  {
    id: currUserId,
    name: {currUserName->LogicUtils.isEmptyString ? currUserId : currUserName},
  },
]

let currentOMPName = (list: array<ompListTypes>, id: string) => {
  switch list->Array.find(user => user.id == id) {
  | Some(user) => user.name
  | None => id
  }
}

let orgItemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("org_id", ""),
    name: {
      dict->getString("org_name", "")->isEmptyString
        ? dict->getString("org_id", "")
        : dict->getString("org_name", "")
    },
  }
}

let merchantItemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("merchant_id", ""),
    name: {
      dict->getString("merchant_name", "")->isEmptyString
        ? dict->getString("merchant_id", "")
        : dict->getString("merchant_name", "")
    },
  }
}

let profileItemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("profile_id", ""),
    name: {
      dict->getString("profile_name", "")->isEmptyString
        ? dict->getString("profile_id", "")
        : dict->getString("profile_name", "")
    },
  }
}

let org = {
  lable: "Organization",
  entity: #Organization,
}
let merchant = {
  lable: "Merchant",
  entity: #Merchant,
}
let profile = {
  lable: "Profile",
  entity: #Profile,
}

let transactionViewList = (~checkUserEntity): ompViews => {
  if checkUserEntity([#Merchant, #Organization]) {
    [merchant, profile]
  } else {
    []
  }
}

let analyticsViewList = (~checkUserEntity): ompViews => {
  if checkUserEntity([#Organization]) {
    [org, merchant, profile]
  } else if checkUserEntity([#Merchant]) {
    [merchant, profile]
  } else {
    []
  }
}

let mapUserType = user => {
  switch user {
  | "org" => #Org
  | "merchant" => #Merchant
  | "profile" => #Profile
  | _ => #Merchant
  }
}

let mapRoleId = roleId => {
  switch roleId {
  | "org_admin" => #org_admin
  | "merchant_admin" => #merchant_admin
  | _ => #non_admin
  }
}

let allowedRoles = user =>
  switch user->mapUserType {
  | #Merchant => [#org_admin]
  | #Profile => [#org_admin, #merchant_admin]
  | _ => []
  }

let hasAccess = (user, roleId): CommonAuthTypes.authorization => {
  let roles = allowedRoles(user)
  if roles->Array.includes(roleId->mapRoleId) {
    Access
  } else {
    NoAccess
  }
}

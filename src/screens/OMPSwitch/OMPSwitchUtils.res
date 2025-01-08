open OMPSwitchTypes
let ompDefaultValue = (currUserId, currUserName) => [
  {
    id: currUserId,
    name: {currUserName->LogicUtils.isEmptyString ? currUserId : currUserName},
    isPlatformAccount: false,
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
    isPlatformAccount: dict->getBool("is_platform_account", false),
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
    isPlatformAccount: dict->getBool("is_platform_account", false),
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
    isPlatformAccount: false,
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
  if checkUserEntity([#Tenant, #Merchant, #Organization]) {
    [merchant, profile]
  } else if checkUserEntity([#Profile]) {
    [profile]
  } else {
    []
  }
}

let analyticsViewList = (~checkUserEntity): ompViews => {
  if checkUserEntity([#Tenant, #Organization]) {
    [org, merchant, profile]
  } else if checkUserEntity([#Merchant]) {
    [merchant, profile]
  } else if checkUserEntity([#Profile]) {
    [profile]
  } else {
    []
  }
}

let checkIsPlatformAccount = (~orgList, ~currentOrgId) => {
  let currentOrgDetails =
    orgList
    ->Array.find(item => item.id === currentOrgId)
    ->Option.getOr(Dict.make()->orgItemToObjMapper)
  currentOrgDetails.isPlatformAccount->Option.getOr(false)
}

let checkIsPlatformAccountMerchant = (~merchantList, ~merchantId) => {
  let currentOrgDetails =
    merchantList
    ->Array.find(item => item.id === merchantId)
    ->Option.getOr(Dict.make()->merchantItemToObjMapper)
  currentOrgDetails.isPlatformAccount->Option.getOr(false)
}

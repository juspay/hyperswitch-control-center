open OMPSwitchTypes
let ompDefaultValue = (currUserId, currUserName) => [
  {
    id: currUserId,
    name: {currUserName->LogicUtils.isEmptyString ? currUserId : currUserName},
  },
]

let currentOrgName = (list: array<orgList>, id: string) => {
  switch list->Array.find(user => user.id == id) {
  | Some(user) => user.name
  | None => id
  }
}
let currentMerchantName = (list: array<merchantList>, id: string) => {
  switch list->Array.find(user => user.id == id) {
  | Some(user) => user.name
  | None => id
  }
}
let currentProfileName = (list: array<profileList>, id: string) => {
  switch list->Array.find(user => user.id == id) {
  | Some(user) => user.name
  | None => id
  }
}

let convertToProfileListType = (list: JSON.t) => {
  open LogicUtils
  list
  ->getArrayFromJson([])
  ->Array.map(item => {
    let dict = item->getDictFromJsonObject
    {id: dict->getString("id", ""), name: dict->getString("name", "")}
  })
}

let orgTypeMapper: string => orgType = orgType => {
  switch orgType {
  | "default" => Default
  | "platform" => Platform
  | _ => Default
  }
}

let merchantTypeMapper: string => merchantType = merchantType =>
  switch merchantType {
  | "default" => Default
  | "platform" => Platform
  | "connected" => Connected
  | _ => Default
  }

let orgItemToObjMapper: dict<JSON.t> => orgList = dict => {
  open LogicUtils
  {
    id: dict->getString("org_id", ""),
    name: {
      dict->getString("org_name", "")->isEmptyString
        ? dict->getString("org_id", "")
        : dict->getString("org_name", "")
    },
    orgType: dict->getString("org_type", "")->orgTypeMapper,
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
    merchantType: dict->getString("merchant_type", "")->merchantTypeMapper,
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

let checkIfPlatformOrg = (~orgList: array<orgList>, ~orgId) => {
  let currOrg =
    orgList
    ->Array.find(item => item.id == orgId)
    ->Option.getOr(HyperswitchAtom.orgDefaultValue)
  switch currOrg.orgType {
  | Platform => true
  | Default => false
  }
}

let checkIfPlatformMerchant = (~merchantList: array<merchantList>, ~merchantId) => {
  let currMerchant =
    merchantList
    ->Array.find(item => item.id == merchantId)
    ->Option.getOr(HyperswitchAtom.merchantDefaultValue)
  switch currMerchant.merchantType {
  | Connected
  | Platform => true
  | Default => false
  }
}

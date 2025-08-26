open OMPSwitchTypes

let ompDefaultValue: (string, string) => ompListTypes = (currUserId, currUserName) => {
  id: currUserId,
  name: {currUserName->LogicUtils.isEmptyString ? currUserId : currUserName},
  type_: #standard,
}

let currentOMPName = (list: array<ompListTypes>, id: string) => {
  switch list->Array.find(listValue => listValue.id == id) {
  | Some(listValue) => listValue.name
  | None => id
  }
}

let ompTypeMapper = (ompType: string): ompType => {
  switch ompType {
  | "platform" => #platform
  | "standard" => #standard
  | _ => #standard
  }
}

let ompTypeHeading = (ompType: ompType): string => {
  switch ompType {
  | #platform => "Platform Merchant"
  | #standard => "Merchants"
  }
}

let orgItemToObjMapper: dict<JSON.t> => ompListTypes = dict => {
  open LogicUtils
  {
    id: dict->getString("org_id", ""),
    name: {
      dict->getString("org_name", "")->isEmptyString
        ? dict->getString("org_id", "")
        : dict->getString("org_name", "")
    },
    type_: dict->getString("org_type", "")->ompTypeMapper,
  }
}

let merchantItemToObjMapper: Dict.t<'t> => OMPSwitchTypes.ompListTypes = dict => {
  open LogicUtils
  {
    id: dict->getString("merchant_id", ""),
    name: {
      dict->getString("merchant_name", "")->isEmptyString
        ? dict->getString("merchant_id", "")
        : dict->getString("merchant_name", "")
    },
    productType: dict
    ->getString("product_type", "")
    ->ProductUtils.getProductVariantFromString(
      ~version=dict->getString("version", "v1")->UserInfoUtils.versionMapper,
    ),
    version: dict->getString("version", "v1")->UserInfoUtils.versionMapper,
    type_: dict->getString("merchant_account_type", "")->ompTypeMapper,
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

let keyExtractorForMerchantid = item => {
  open LogicUtils
  let dict = item->getDictFromJsonObject
  dict->getString("merchant_id", "")
}

let userSwitch = (~switchData, ~defaultValue: UserInfoTypes.userInfo) => {
  {
    orgId: switchData
    ->Dict.get("orgId")
    ->Option.getOr(defaultValue.orgId),
    merchantId: switchData
    ->Dict.get("merchantId")
    ->Option.getOr(defaultValue.merchantId),
    profileId: switchData
    ->Dict.get("profileId")
    ->Option.getOr(defaultValue.profileId),
    path: switchData
    ->Dict.get("path")
    ->Option.getOr(""),
  }
}

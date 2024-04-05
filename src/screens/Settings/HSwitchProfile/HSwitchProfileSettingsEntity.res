open SwitchMerchantUtils

type columns =
  | MerchantName
  | Role
  | MerchantID

let visibleColumns = [MerchantName, MerchantID]

let defaultColumns = [MerchantName, MerchantID]

let allColumns = [MerchantName, Role, MerchantID]

let itemToObjMapper = dict => {
  open LogicUtils
  {
    merchant_id: getString(dict, "merchant_id", ""),
    merchant_name: getString(dict, "merchant_name", ""),
    is_active: getBool(dict, "is_active", false),
  }
}

let getItems: JSON.t => array<switchMerchantListResponse> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let getHeading = colType => {
  switch colType {
  | MerchantName => Table.makeHeaderInfo(~key="merchant_name", ~title="Merchant Name", ())
  | Role => Table.makeHeaderInfo(~key="role", ~title="Role", ())
  | MerchantID => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID", ())
  }
}

let getCell = (item: switchMerchantListResponse, colType): Table.cell => {
  switch colType {
  | MerchantName => Text(item.merchant_name)
  | MerchantID => Text(item.merchant_id)
  | Role => Text("role")
  }
}

let profileTableEntity = (~permission: AuthTypes.authorization) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getItems,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~dataKey="",
    ~getCell,
    ~getShowLink={
      profile => PermissionUtils.linkForGetShowLinkViaAccess(~url="", ~permission)
    },
    (),
  )

open SwitchMerchantUtils

type columns =
  | MerchantName
  | RoleName
  | MerchantId

let visibleColumns = [MerchantId, MerchantName, RoleName]

let defaultColumns = [MerchantId, MerchantName, RoleName]

let allColumns = [MerchantId, MerchantName, RoleName]

let itemToObjMapper = dict => {
  open LogicUtils
  {
    merchant_id: getString(dict, "merchant_id", ""),
    merchant_name: getString(dict, "merchant_name", ""),
    is_active: getBool(dict, "is_active", false),
    role_id: getString(dict, "role_id", ""),
    role_name: getString(dict, "role_name", ""),
    org_id: getString(dict, "org_id", ""),
  }
}

let getItems = json => LogicUtils.getArrayDataFromJson(json, itemToObjMapper)

let getHeading = colType => {
  switch colType {
  | MerchantName => Table.makeHeaderInfo(~key="merchant_name", ~title="Merchant Name", ())
  | RoleName => Table.makeHeaderInfo(~key="role", ~title="Role", ())
  | MerchantId => Table.makeHeaderInfo(~key="merchant id", ~title="Merchant Id", ())
  }
}

let getCell = (item: switchMerchantListResponse, colType): Table.cell => {
  switch colType {
  | MerchantName => Text(item.merchant_name)
  | RoleName =>
    CustomCell(
      <div className="flex flex-row gap-2">
        <Icon name="user" className="text-jp-gray-700" size=12 />
        <span> {item.role_name->LogicUtils.snakeToTitle->React.string} </span>
      </div>,
      "",
    )
  | MerchantId => Text(item.merchant_id)
  }
}

let merchantTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getItems,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~dataKey="",
  ~getCell,
  (),
)

open HSwitchSettingTypes
open BusinessMappingUtils

type columns =
  | ProfileName
  | ProfileId

let visibleColumns = [ProfileId, ProfileName]

let defaultColumns = [ProfileId, ProfileName]

let allColumns = [ProfileId, ProfileName]

let getHeading = colType => {
  switch colType {
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ~showSort=true, ())
  | ProfileName =>
    Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ~showSort=true, ())
  }
}

let getCell = (item: profileEntity, colType): Table.cell => {
  switch colType {
  | ProfileId => Text(item.profile_id)
  | ProfileName => Text(item.profile_name)
  }
}

let itemToObjMapper = dict => {
  open LogicUtils
  open MerchantAccountUtils
  {
    profile_id: getString(dict, "profile_id", ""),
    profile_name: getString(dict, ProfileName->getStringFromVariant, ""),
    merchant_id: getString(dict, "merchant_id", ""),
    return_url: getOptionString(dict, "return_url"),
    payment_response_hash_key: getOptionString(dict, "payment_response_hash_key"),
    webhook_details: dict->getObj("webhook_details", Dict.make())->constructWebhookDetailsObject,
  }
}

let getItems: Js.Json.t => array<profileEntity> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let businessProfileTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getItems,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~dataKey="",
  ~getCell,
  (),
)

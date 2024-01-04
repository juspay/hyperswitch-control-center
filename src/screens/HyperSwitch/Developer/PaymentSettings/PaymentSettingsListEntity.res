open HSwitchSettingTypes
open BusinessMappingUtils

type columns =
  | ProfileName
  | ReturnUrl
  | WebhookUrl

let visibleColumns = [WebhookUrl, ReturnUrl, ProfileName]

let defaultColumns = [ProfileName, ReturnUrl, WebhookUrl]

let allColumns = [ProfileName, ReturnUrl, WebhookUrl]

let getHeading = colType => {
  switch colType {
  | ProfileName =>
    Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ~showSort=true, ())
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="Return URL", ~showSort=true, ())
  | WebhookUrl => Table.makeHeaderInfo(~key="webhook_url", ~title="Webhook URL", ~showSort=true, ())
  }
}

let getCell = (item: profileEntity, colType): Table.cell => {
  switch colType {
  | ProfileName => Text(item.profile_name)
  | ReturnUrl => Text(item.return_url->Belt.Option.getWithDefault(""))
  | WebhookUrl => Text(item.webhook_details.webhook_url->Belt.Option.getWithDefault(""))
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

let webhookProfileTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getItems,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~dataKey="",
  ~getCell,
  ~getShowLink={
    profile => `/payment-settings/${profile.profile_id}`
  },
  (),
)

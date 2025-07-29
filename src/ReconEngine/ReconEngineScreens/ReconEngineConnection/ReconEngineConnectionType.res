type connectionType = {
  is_active: bool,
  last_synced_at: string,
  name: string,
  data: JSON.t,
}

let connectionTypeToObjMapper = dict => {
  open LogicUtils
  {
    is_active: dict->getBool("is_active", false),
    last_synced_at: dict->getString("last_synced_at", ""),
    name: dict->getString("name", ""),
    data: dict->getJsonObjectFromDict("data"),
  }
}

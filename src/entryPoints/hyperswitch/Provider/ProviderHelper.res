open ProviderTypes

let itemIntegrationDetailsMapper = dict => {
  open LogicUtils
  {
    is_done: dict->getBool("is_done", false),
    metadata: dict->getDictfromDict("metadata")->Js.Json.object_,
  }
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    pricing_plan: dict->getDictfromDict("pricing_plan")->itemIntegrationDetailsMapper,
    connector_integration: dict
    ->getDictfromDict("connector_integration")
    ->itemIntegrationDetailsMapper,
    integration_checklist: dict
    ->getDictfromDict("integration_checklist")
    ->itemIntegrationDetailsMapper,
    account_activation: dict->getDictfromDict("account_activation")->itemIntegrationDetailsMapper,
  }
}

let getIntegrationDetails: Js.Json.t => integrationDetailsType = json => {
  open LogicUtils
  json->getDictFromJsonObject->itemToObjMapper
}

let itemToObjMapperForEnum = dict => {
  open LogicUtils
  {
    enum_name: getString(dict, "enum_name", ""),
    description: getString(dict, "description", ""),
    isPermissionAllowed: false,
  }
}

let itemToObjMapperForGetInfo = dict => {
  open LogicUtils
  {
    module_: getString(dict, "module", ""),
    description: getString(dict, "description", ""),
    permissions: getArrayFromDict(dict, "permissions", [])->Array.map(i =>
      i->getDictFromJsonObject->itemToObjMapperForEnum
    ),
  }
}

let getDefaultValueOfEnum = {
  {
    enum_name: "",
    description: "",
    isPermissionAllowed: false,
  }
}

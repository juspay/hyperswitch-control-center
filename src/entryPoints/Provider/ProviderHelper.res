open ProviderTypes

let itemIntegrationDetailsMapper = dict => {
  open LogicUtils
  {
    is_done: dict->getBool("is_done", false),
    metadata: dict->getDictfromDict("metadata")->JSON.Encode.object,
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

let getIntegrationDetails: JSON.t => integrationDetailsType = json => {
  open LogicUtils
  json->getDictFromJsonObject->itemToObjMapper
}

let itemToObjMapperForGetInfo: Dict.t<JSON.t> => UserManagementTypes.getInfoType = dict => {
  open LogicUtils
  {
    module_: getString(dict, "group", ""),
    description: getString(dict, "description", ""),
    isPermissionAllowed: false,
  }
}

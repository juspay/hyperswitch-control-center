type orgType = {id: string, name: string}

let defaultOrg = (currOrgId, currOrgName) => [
  {id: currOrgId, name: {currOrgName->LogicUtils.isEmptyString ? currOrgId : currOrgName}},
]

let itemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("org_id", ""),
    name: {
      dict->getString("org_name", "")->isEmptyString
        ? dict->getString("org_id", "")
        : dict->getString("org_name", "")
    },
  }
}

type orgListResponse = {
  org_id: string,
  org_name: string,
  is_active: bool,
  role_id: string,
  role_name: string,
}

let defaultValue = {
  org_id: "",
  org_name: "",
  is_active: false,
  role_id: "",
  role_name: "",
}

let convertListResponseToTypedResponse = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(ele => {
    let dictOfElement = ele->getDictFromJsonObject
    let orgId = dictOfElement->getString("org_id", "")
    let orgName =
      dictOfElement->getString("org_name", orgId)->isNonEmptyString
        ? dictOfElement->getString("org_name", orgId)
        : orgId
    let role_id = dictOfElement->getString("role_id", "")
    let role_name = dictOfElement->getString("role_name", "")

    {
      org_id: orgId,
      org_name: orgName,
      is_active: dictOfElement->getBool("is_active", false),
      role_id,
      role_name,
    }
  })
}

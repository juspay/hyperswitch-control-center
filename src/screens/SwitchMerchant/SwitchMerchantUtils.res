type switchMerchantListResponse = {
  merchant_id: string,
  merchant_name: string,
  is_active: bool,
  role_id: string,
  role_name: string,
  org_id: string,
}

let defaultValue = {
  merchant_id: "",
  merchant_name: "",
  is_active: false,
  role_id: "",
  role_name: "",
  org_id: "",
}

let convertListResponseToTypedResponse = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(ele => {
    let dictOfElement = ele->getDictFromJsonObject
    let merchantId = dictOfElement->getString("merchant_id", "")
    let merchantName =
      dictOfElement->getString("merchant_name", merchantId)->isNonEmptyString
        ? dictOfElement->getString("merchant_name", merchantId)
        : merchantId
    let role_id = dictOfElement->getString("role_id", "")
    let role_name = dictOfElement->getString("role_name", "")
    let org_id = dictOfElement->getString("org_id", "")

    {
      merchant_id: merchantId,
      merchant_name: merchantName,
      is_active: dictOfElement->getBool("is_active", false),
      role_id,
      role_name,
      org_id,
    }
  })
}

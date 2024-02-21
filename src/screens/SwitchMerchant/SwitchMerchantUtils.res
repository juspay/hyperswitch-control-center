type switchMerchantListResponse = {
  merchant_id: string,
  merchant_name: string,
  is_active: bool,
}

let defaultValue = {
  merchant_id: "",
  merchant_name: "",
  is_active: false,
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

    {
      merchant_id: merchantId,
      merchant_name: merchantName,
      is_active: dictOfElement->getBool("is_active", false),
    }
  })
}

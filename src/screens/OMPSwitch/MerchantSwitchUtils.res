type merchantType = {id: string, name: string}

let defaultMerchant = (currMerchantId, currMerchantName) => [
  {
    id: currMerchantId,
    name: {currMerchantName->LogicUtils.isEmptyString ? currMerchantId : currMerchantName},
  },
]

let itemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("merchant_id", ""),
    name: dict->getString("merchant_name", ""),
  }
}

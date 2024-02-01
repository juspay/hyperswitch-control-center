// will be removed once the backend does the URl mapping
let nameToURLMapper = (~id) => {
  let merchant_id = HSLocalStorage.getFromMerchantDetails("merchant_id")
  urlName =>
    switch urlName {
    | "PaymentsCreate" => "/payments"
    | "PaymentsStart" => `/payments/redirect/${id}/${merchant_id}`
    | "PaymentsCancel" => `/payments/${id}/cancel`
    | "PaymentsUpdate" => `/payments/${id}`
    | "PaymentsConfirm" => `/payments/${id}/confirm`
    | "PaymentsCapture" => `/payments/${id}/capture`
    | _ => urlName
    }
}

let filteredKeys = [
  "value",
  "merchant_id",
  "created_at_precise",
  "component",
  "platform",
  "version",
]

let sortByCreatedAt = (log1: JSON.t, log2: JSON.t) => {
  open LogicUtils
  let getKey = dict => dict->getDictFromJsonObject->getString("created_at", "")->Js.Date.fromString
  let keyA = log1->getKey
  let keyB = log2->getKey
  compareLogic(keyA, keyB)
}

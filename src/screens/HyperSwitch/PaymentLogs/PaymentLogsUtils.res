// will be removed once the backend does the URl mapping
let nameToURLMapper = (urlName, ~payment_id, ~merchant_id="", ()) => {
  switch urlName {
  | "PaymentsCreate" => "/payments"
  | "PaymentsStart" => `/payments/redirect/${payment_id}/${merchant_id}`
  | "PaymentsCancel" => `/payments/${payment_id}/cancel`
  | "PaymentsUpdate" => `/payments/${payment_id}`
  | "PaymentsConfirm" => `/payments/${payment_id}/confirm`
  | "PaymentsCapture" => `/payments/${payment_id}/capture`
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
  let getKey = dict => dict->getDictFromJsonObject->getString("created_at", "")->Date.fromString
  let keyA = log1->getKey
  let keyB = log2->getKey
  compareLogic(keyA, keyB)
}

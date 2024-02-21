let sortByCreatedAt = (log1: JSON.t, log2: JSON.t) => {
  open LogicUtils
  let getKey = dict => dict->getDictFromJsonObject->getString("created_at", "")->Date.fromString
  let keyA = log1->getKey
  let keyB = log2->getKey
  compareLogic(keyA, keyB)
}

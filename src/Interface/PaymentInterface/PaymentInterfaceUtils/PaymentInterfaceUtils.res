open LogicUtils

let concatAddressFromDict = (dict, keys) => {
  keys
  ->Array.map(key => dict->getString(key, ""))
  ->Array.filter(val => val->String.trim->String.length > 0)
  ->Array.joinWith(", ") ++ "."
}

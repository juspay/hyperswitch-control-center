open LogicUtils

let concatValueOfGivenKeysOfDict = (dict, keys) => {
  Array.reduceWithIndex(keys, "", (acc, key, i) => {
    let val = dict->getString(key, "")
    let delimiter = if val->isNonEmptyString {
      if key !== "first_name" {
        i + 1 == keys->Array.length ? "." : ", "
      } else {
        " "
      }
    } else {
      ""
    }
    String.concat(acc, `${val}${delimiter}`)
  })
}

let concatAddressWithFirstNameLogic = (dict, keys) => {
  Array.reduceWithIndex(keys, "", (acc, key, i) => {
    let val = dict->getString(key, "")->String.trim
    if val == "" {
      acc
    } else {
      let delimiter = switch key {
      | "first_name" => " "
      | _ =>
        if i + 1 == keys->Array.length {
          "."
        } else {
          ", "
        }
      }

      acc ++ val ++ delimiter
    }
  })
}

let concatAddressFromDict = (dict, keys) => {
  keys
  ->Array.map(key => dict->getString(key, ""))
  ->Array.filter(val => val->String.trim->String.length > 0)
  ->Array.joinWith(", ") ++ "."
}

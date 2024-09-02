open OMPSwitchTypes
let ompDefaultValue = (currUserId, currUserName) => [
  {
    id: currUserId,
    name: {currUserName->LogicUtils.isEmptyString ? currUserId : currUserName},
  },
]

let orgItemToObjMapper = dict => {
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

let merchantItemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("merchant_id", ""),
    name: {
      dict->getString("merchant_name", "")->isEmptyString
        ? dict->getString("merchant_id", "")
        : dict->getString("merchant_name", "")
    },
  }
}

let profileItemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("profile_id", ""),
    name: {
      dict->getString("profile_name", "")->isEmptyString
        ? dict->getString("profile_id", "")
        : dict->getString("profile_name", "")
    },
  }
}

let generateDropdownOptions = dropdownList => {
  let options: array<SelectBox.dropdownOption> =
    dropdownList->Array.map((item): SelectBox.dropdownOption => {label: item.name, value: item.id})
  options
}

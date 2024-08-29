type profileType = {id: string, name: string}

let defaultProfile = (currProfileId, currProfileName) => [
  {
    id: currProfileId,
    name: {currProfileName->LogicUtils.isEmptyString ? currProfileId : currProfileName},
  },
]

let itemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("profile_id", ""),
    name: dict->getString("profile_name", ""),
  }
}

open ReconEngineAccountsTypes
open ReconEngineTypes
open ReconEngineUtils

let getStatusVariantFromString = (status: string): status => {
  switch status {
  | "Active" => Active
  | "Inactive" => Inactive
  | _ => UnknownStatus
  }
}

let getAccountPayloadFromDict: Dict.t<JSON.t> => accountType = dict => {
  dict->accountItemToObjMapper
}

let getAccountRefPayloadFromDict: Dict.t<JSON.t> => accountRefType = dict => {
  dict->accountRefItemToObjMapper
}

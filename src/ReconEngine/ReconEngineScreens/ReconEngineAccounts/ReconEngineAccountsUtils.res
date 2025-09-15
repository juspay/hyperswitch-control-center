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

let getIngestionAndTransformationStatusVariantFromString = statusStr => {
  switch statusStr {
  | "pending" => Pending
  | "processing" => Processing
  | "processed" => Processed
  | "failed" => Failed
  | "discarded" => Discarded
  | _ => StatusNone
  }
}

let getIngestionAndTransformationStatusStringFromVariant = status => {
  switch status {
  | Pending => "pending"
  | Processing => "processing"
  | Processed => "processed"
  | Discarded => "discarded"
  | Failed => "failed"
  | StatusNone => "unknown"
  }
}

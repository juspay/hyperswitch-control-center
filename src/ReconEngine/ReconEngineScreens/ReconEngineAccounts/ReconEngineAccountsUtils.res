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

let getAccountRefPayloadFromDict: Dict.t<JSON.t> => reconRuleAccountRefType = dict => {
  dict->ruleAccountRefItemToObjMapper
}

let getIngestionAndTransformationStatusVariantFromString = (
  statusStr
): ingestionTransformationStatusType => {
  switch statusStr {
  | "pending" => Pending
  | "processing" => Processing
  | "processed" => Processed
  | "failed" => Failed
  | "discarded" => Discarded
  | _ => UnknownIngestionTransformationStatus
  }
}

let getStatusLabel = (statusString: ingestionTransformationStatusType): Table.cell => {
  Table.Label({
    title: (statusString :> string),
    color: switch statusString {
    | Pending => Table.LabelGray
    | Processing => Table.LabelOrange
    | Processed => Table.LabelGreen
    | Failed => Table.LabelRed
    | Discarded => Table.LabelGray
    | UnknownIngestionTransformationStatus => Table.LabelLightGray
    },
  })
}

let getIngestionAndTransformationStatusStringFromVariant = (
  status: ingestionTransformationStatusType,
) => {
  switch status {
  | Pending => "pending"
  | Processing => "processing"
  | Processed => "processed"
  | Discarded => "discarded"
  | Failed => "failed"
  | UnknownIngestionTransformationStatus => "unknown"
  }
}

open ConnectorTypes
let connectorsSupportEvidenceUpload = [CHECKOUT, STRIPE]
let connectorsSupportAcceptDispute = [CHECKOUT]
let connectorSupportCounterDispute = [CHECKOUT, STRIPE]

open DisputeTypes
let disputeStageVariantMapper = stage => {
  switch stage {
  | "pre_dispute" => PreDispute
  | "dispute" => Dispute
  | "pre-arbitration" => PreArbitration
  | _ => NotFound
  }
}

let disputeStatusVariantMapper = status => {
  switch status {
  | "dispute_opened" => DisputeOpened
  | "dispute_expired" => DisputeExpired
  | "dispute_accepted" => DisputeAccepted
  | "dispute_cancelled" => DisputeCancelled
  | "dispute_challenged" => DisputeChallenged
  | "dispute_won" => DisputeWon
  | "dispute_lost" => DisputeLost
  | _ => NotFound(status)
  }
}

let showDisputeInfoStatus = [DisputeOpened, DisputeAccepted, DisputeChallenged]
let evidenceList = [
  "Receipt",
  "Refund Policy",
  "Uncategorized File",
  "Customer Signature",
  "Service Documentation",
  "Customer Communication",
  "Shipping Documentation",
  "Recurring Transaction Agreement",
  "Invoice Showing Distinct Transactions",
]

let getDictFromFilesAvailable = arrayValue => {
  open LogicUtils
  let manipulatedDict = Dict.make()
  arrayValue->Array.forEach(val => {
    let dictFromJson = val->getDictFromJsonObject
    let evidenceTypekey = dictFromJson->getString("evidence_type", "")
    let filemetadata = dictFromJson->getDictfromDict("file_metadata_response")
    let file_id = filemetadata->getString("file_id", "")
    let file_name = filemetadata->getString("file_name", "")

    let fileVal =
      [
        ("fileId", file_id->JSON.Encode.string),
        ("fileName", file_name->JSON.Encode.string),
      ]->getJsonFromArrayOfJson

    manipulatedDict->Dict.set(evidenceTypekey, fileVal)
  })
  manipulatedDict
}

let constructDisputesBody = (dict, disputesId) => {
  let body = Dict.make()
  dict
  ->Dict.keysToArray
  ->Array.forEach(value => {
    let fileID = dict->LogicUtils.getDictfromDict(value)->LogicUtils.getString("fileId", "")
    if fileID->String.length > 0 {
      body->Dict.set(value, fileID->JSON.Encode.string)
    }
  })
  body->Dict.set("dispute_id", disputesId->JSON.Encode.string)
  body
}

let getFileTypeFromFileName = fileName => {
  let lastIndex = fileName->String.lastIndexOf(".")
  let afterDotFileType = fileName->String.substringToEnd(~start=lastIndex + 1)
  afterDotFileType
}

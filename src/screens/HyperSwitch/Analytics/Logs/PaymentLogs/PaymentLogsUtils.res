type flowType =
  | PaymentsCancel
  | PaymentsCapture
  | PaymentsConfirm
  | PaymentsCreate
  | PaymentsStart
  | PaymentsUpdate
  | RefundsCreate
  | RefundsUpdate
  | DisputesEvidenceSubmit
  | AttachDisputeEvidence
  | RetrieveDisputeEvidence
  | IncomingWebhookReceive
  | NotDefined

let itemToObjMapper = flowString => {
  switch flowString {
  | "PaymentsCancel" => PaymentsCancel
  | "PaymentsCapture" => PaymentsCapture
  | "PaymentsConfirm" => PaymentsConfirm
  | "PaymentsCreate" => PaymentsCreate
  | "PaymentsStart" => PaymentsStart
  | "PaymentsUpdate" => PaymentsUpdate
  | "RefundsCreate" => RefundsCreate
  | "RefundsUpdate" => RefundsUpdate
  | "DisputesEvidenceSubmit" => DisputesEvidenceSubmit
  | "AttachDisputeEvidence" => AttachDisputeEvidence
  | "RetrieveDisputeEvidence" => RetrieveDisputeEvidence
  | "IncomingWebhookReceive" => IncomingWebhookReceive
  | _ => NotDefined
  }
}

// will be removed once the backend does the URl mapping
let nameToURLMapper = (~id) => {
  let merchant_id = HSLocalStorage.getFromMerchantDetails("merchant_id")
  urlName =>
    switch urlName->itemToObjMapper {
    | PaymentsCancel => `/payments/${id}/cancel`
    | PaymentsCapture => `/payments/${id}/capture`
    | PaymentsConfirm => `/payments/${id}/confirm`
    | PaymentsCreate => "/payments"
    | PaymentsStart => `/payments/redirect/${id}/${merchant_id}`
    | PaymentsUpdate => `/payments/${id}`
    | RefundsCreate => "/refunds"
    | RefundsUpdate => `/refunds/${id}`
    | DisputesEvidenceSubmit | AttachDisputeEvidence => "/disputes/evidence"
    | RetrieveDisputeEvidence => `/disputes/evidence/${id}`
    | IncomingWebhookReceive | NotDefined => urlName
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

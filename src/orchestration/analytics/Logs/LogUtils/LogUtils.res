let sortByCreatedAt = (log1, log2) => {
  open LogicUtils
  let getKey = dict => dict->getDictFromJsonObject->getString("created_at", "")->Date.fromString
  let keyA = log1->getKey
  let keyB = log2->getKey
  compareLogic(keyA, keyB)
}

let reorderLogs = logs => {
  open LogicUtils
  logs->Array.reverse

  // Find the index of the log with "PaymentsCreate" in the "api_flow" field
  let index =
    logs->Array.findIndex(item =>
      item->getDictFromJsonObject->getString("api_flow", "") == "PaymentsCreate"
    )

  switch index {
  | 0 // If it's already at the first position, return the logs as is
  | -1 => logs // If not found, return the logs as is
  | _ => {
      // If found but not at the first position, move it to the front
      let element = logs->Array.find(item => {
        item->getDictFromJsonObject->getString("api_flow", "") == "PaymentsCreate"
      })

      let logs = switch element {
      | Some(val) => {
          let arr = logs->Array.filter(item => item != val)
          let newList = [val]->Array.concat(arr)
          newList->Array.reverse
          newList
        }
      | _ => logs
      }

      logs
    }
  }
}

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
let nameToURLMapper = (~id, ~merchantId) => {
  urlName =>
    switch urlName->itemToObjMapper {
    | PaymentsCancel => `/payments/${id}/cancel`
    | PaymentsCapture => `/payments/${id}/capture`
    | PaymentsConfirm => `/payments/${id}/confirm`
    | PaymentsCreate => "/payments"
    | PaymentsStart => `/payments/redirect/${id}/${merchantId}`
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

let detailsSectionFilterKeys = [
  "content",
  "created_at",
  "event_type",
  "flow_type",
  "api_flow",
  "request",
  "response",
  "user_agent",
  "ip_addr",
  "flow",
  "masked_response",
  "http_method",
  "hs_latency",
  "status_code",
]

@module("js-sha256") external sha256: string => string = "sha256"
let parseSdkResponse = arr => {
  open LogicUtils
  let sourceMapper = source => {
    switch source {
    | "ORCA-LOADER" => "HYPERLOADER"
    | "ORCA-PAYMENT-PAGE"
    | "STRIPE_PAYMENT_SHEET" => "PAYMENT_SHEET"
    | other => other
    }
  }

  let sdkLogsArray = arr->Array.map(event => {
    let eventDict = event->getDictFromJsonObject
    let eventName = eventDict->getString("event_name", "")
    let timestamp = eventDict->getString("created_at_precise", "")
    let logType = eventDict->getString("log_type", "")
    let updatedEventName =
      logType === "INFO" ? eventName->String.replace("Call", "Response") : eventName
    eventDict->Dict.set("event_name", updatedEventName->JSON.Encode.string)
    eventDict->Dict.set("event_id", sha256(updatedEventName ++ timestamp)->JSON.Encode.string)
    eventDict->Dict.set(
      "source",
      eventDict->getString("source", "")->sourceMapper->JSON.Encode.string,
    )
    eventDict->Dict.set(
      "checkout_platform",
      eventDict->getString("component", "")->JSON.Encode.string,
    )
    eventDict->Dict.set("customer_device", eventDict->getString("platform", "")->JSON.Encode.string)
    eventDict->Dict.set("sdk_version", eventDict->getString("version", "")->JSON.Encode.string)
    eventDict->Dict.set("event_name", updatedEventName->JSON.Encode.string)
    eventDict->Dict.set("created_at", timestamp->JSON.Encode.string)
    eventDict->JSON.Encode.object
  })
  let logsArr = sdkLogsArray->Array.filter(sdkLog => {
    let eventDict = sdkLog->getDictFromJsonObject
    let eventName = eventDict->getString("event_name", "")
    let filteredEventNames = ["OrcaElementsCalled"]
    filteredEventNames->Array.includes(eventName)->not
  })

  logsArr
}

let apiNameMapper = apiName => {
  switch apiName {
  | "PSync" => "Payments Sync"
  | _ => apiName
  }
}

open FRMTypes
let frmList: array<ConnectorTypes.connectorTypes> = [FRM(Signifyd), FRM(Riskifyed)]

let flowTypeList = [PreAuth, PostAuth]

let getFRMAuthType = (connector: ConnectorTypes.connectorTypes) => {
  switch connector {
  | FRM(Signifyd) => "HeaderKey"
  | FRM(Riskifyed) => "BodyKey"
  | _ => ""
  }
}

let stepsArr: array<ConnectorTypes.steps> = [PaymentMethods, IntegFields, SummaryAndTest]

let getNextStep: ConnectorTypes.steps => ConnectorTypes.steps = currentStep => {
  switch currentStep {
  | PaymentMethods => IntegFields
  | IntegFields => SummaryAndTest
  | SummaryAndTest => SummaryAndTest
  | _ => Preview
  }
}

let getPrevStep: ConnectorTypes.steps => ConnectorTypes.steps = currentStep => {
  switch currentStep {
  | IntegFields => PaymentMethods
  | SummaryAndTest => IntegFields
  | _ => Preview
  }
}

let getFlowTypeNameString = flowType => {
  switch flowType {
  | PreAuth => "pre"
  | PostAuth => "post"
  }
}

let getFlowTypeVariantFromString = flowTypeString => {
  switch flowTypeString {
  | "pre" => PreAuth
  | _ => PostAuth
  }
}

let getFlowTypeLabel = flowType => {
  switch flowType->getFlowTypeVariantFromString {
  | PreAuth => "Pre Auth"
  | PostAuth => "Post Auth"
  }
}

let frmPreActionList = [CancelTxn]
let frmPostActionList = [ManualReview]

let getActionTypeNameString = flowType => {
  switch flowType {
  | CancelTxn => "cancel_txn"
  | AutoRefund => "auto_refund"
  | ManualReview => "manual_review"
  | Process => "process"
  }
}

let getActionTypeNameVariantFromString = flowType => {
  switch flowType {
  | "auto_refund" => AutoRefund
  | "manual_review" => ManualReview
  | "process" => Process
  | "cancel_txn" | _ => CancelTxn
  }
}

let getActionTypeLabel = actionType => {
  switch actionType->getActionTypeNameVariantFromString {
  | CancelTxn => "Cancel Transactions"
  | AutoRefund => "Auto Refund"
  | ManualReview => "Manual Review"
  | Process => "Process Transactions"
  }
}

let flowTypeAllOptions = flowTypeList->Array.map(getFlowTypeNameString)

let getActionTypeAllOptions = flowType => {
  switch flowType->getFlowTypeVariantFromString {
  | PreAuth => frmPreActionList->Array.map(getActionTypeNameString)
  | PostAuth => frmPostActionList->Array.map(getActionTypeNameString)
  }
}

let ignoredField = [
  "business_country",
  "business_label",
  "business_sub_label",
  "connector_label",
  "merchant_connector_id",
  "connector_name",
  "profile_id",
  "applepay_verified_domains",
]

let actionDescriptionForFlow = flowType => {
  switch flowType {
  | PreAuth => "PreAuth flow - fraudulent transactions are cancelled before authorization."
  | PostAuth => "PostAuth flow - fraudulent transactions are flagged for a manual review before amount capture."
  }
}

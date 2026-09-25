open FRMTypes
let frmList: array<ConnectorTypes.connectorTypes> = [
  FRM(CybersourceDecisionManager),
  FRM(Signifyd),
  FRM(Riskifyed),
  FRM(SanlamPayshield),
]

let flowTypeList = [PreAuth]

let getFRMAuthType = (connector: ConnectorTypes.connectorTypes) => {
  switch connector {
  | FRM(Signifyd) => "HeaderKey"
  | FRM(Riskifyed) => "BodyKey"
  | FRM(CybersourceDecisionManager) => "SignatureKey"
  | FRM(SanlamPayshield) => "HeaderKey"
  | _ => ""
  }
}

// Which already-configured connectors an FRM player can screen. Each entry of
// `screenableMethodsByCategory` pairs a connector category with the payment methods the
// player screens *on that category*, so a method allowed for payments is never offered
// on payouts and vice versa. `note` carries any restriction we only surface as a
// message - the backend owns the actual enforcement.
type frmCompatibility = {
  screenableMethodsByCategory: array<(
    ConnectorTypes.connectorTypeVariants,
    array<ConnectorTypes.paymentMethod>,
  )>,
  note: option<string>,
}

let defaultFRMCompatibility: frmCompatibility = {
  screenableMethodsByCategory: [(PaymentProcessor, [Card])],
  note: None,
}

let getFRMCompatibility = (connector: ConnectorTypes.connectorTypes): frmCompatibility => {
  switch connector {
  | FRM(SanlamPayshield) => {
      screenableMethodsByCategory: [
        (PaymentProcessor, [BankDebit]),
        (PayoutProcessor, [BankTransfer]),
      ],
      note: Some(
        "Sanlam Payshield screens bank debit payments and bank transfer payouts. It is only compatible with the Absa payment connector and the GoTyme payout connector.",
      ),
    }
  | _ => defaultFRMCompatibility
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
  "additional_merchant_data",
]

let actionDescriptionForFlow = flowType => {
  switch flowType {
  | PreAuth => "PreAuth flow - fraudulent transactions are cancelled before authorization."
  | PostAuth => "PostAuth flow - fraudulent transactions are flagged for a manual review before amount capture."
  }
}

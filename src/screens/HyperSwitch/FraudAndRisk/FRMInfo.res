open FRMTypes
let frmList: array<frmName> = [Signifyd]

let flowTypeList = [PreAuth, PostAuth]

let getFRMNameString = frm => {
  switch frm {
  | Signifyd => "signifyd"
  | Riskifyed => "riskified"
  | UnknownFRM(str) => str
  }
}

let getFRMNameTypeFromString = connector => {
  switch connector {
  | "signifyd" => Signifyd
  | "riskified" => Riskifyed
  | _ => UnknownFRM("Not known")
  }
}

let getFRMAuthType = connector => {
  switch connector {
  | Signifyd | Riskifyed => "HeaderKey"
  | UnknownFRM(str) => str
  }
}

let signifydInfo: frmInfo = {
  name: Signifyd,
  description: "One platform to protect the entire shopper journey end-to-end",
  connectorFields: [
    {
      placeholder: "Enter API Key",
      label: "API Key",
      name: "connector_account_details.api_key",
      inputType: InputFields.textInput(),
      isRequired: true,
      encodeToBase64: false,
    },
  ],
}

let riskifyedInfo: frmInfo = {
  name: Riskifyed,
  description: "Frictionless fraud management for eCommerce",
  connectorFields: [
    {
      placeholder: "Enter API Key",
      label: "API Key",
      name: "connector_account_details.api_key",
      inputType: InputFields.textInput(),
      isRequired: true,
      encodeToBase64: false,
    },
  ],
}

let unknownFRMInfo: frmInfo = {
  name: UnknownFRM("Unknown FRM"),
  description: "",
  connectorFields: [],
}

let getFRMInfo = (frmPlayer: frmName) => {
  switch frmPlayer {
  | Signifyd => signifydInfo
  | Riskifyed => riskifyedInfo
  | UnknownFRM(_) => unknownFRMInfo
  }
}

let stepsArr: array<ConnectorTypes.steps> = [PaymentMethods, IntegFields, SummaryAndTest]

let getNextStep: ConnectorTypes.steps => ConnectorTypes.steps = currentStep => {
  switch currentStep {
  | PaymentMethods => IntegFields
  | IntegFields => SummaryAndTest
  | SummaryAndTest => SummaryAndTest
  | Preview => Preview
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

let frmPreActionList = [CancelTxn, ManualReview]
let frmPostActionList = [AutoRefund, ManualReview]

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

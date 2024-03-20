type frmName =
  | Signifyd
  | Riskifyed
  | UnknownFRM(string)

type frmIntegrationField = {
  placeholder: string,
  label: string,
  name: string,
  inputType: InputFields.customInputFn,
  isRequired: bool,
  encodeToBase64: bool,
  description?: string,
}

type frmInfo = {
  name: frmName,
  description: string,
  connectorFields: array<frmIntegrationField>,
}

type filterType = Connector | FRMPlayer | ThreedsAuthenticator

type frmPaymentMethodsSectionType = FlowType | ActionType

type flowType = PreAuth | PostAuth

type frmActionType = CancelTxn | AutoRefund | ManualReview | Process

let getDisableConnectorPayload = (connectorInfo, previousConnectorState) => {
  let dictToJson = connectorInfo->LogicUtils.getDictFromJsonObject
  [
    ("connector_type", dictToJson->LogicUtils.getString("connector_type", "")->JSON.Encode.string),
    ("disabled", !previousConnectorState->JSON.Encode.bool),
  ]->Dict.fromArray
}

type filterType = Connector | FRMPlayer | ThreedsAuthenticator

type flowType = PreAuth | PostAuth

type frmActionType = CancelTxn | AutoRefund | ManualReview | Process

let getDisableConnectorPayload = (connectorInfo, previousConnectorState) => {
  let dictToJson = connectorInfo->LogicUtils.getDictFromJsonObject
  [
    ("connector_type", dictToJson->LogicUtils.getString("connector_type", "")->JSON.Encode.string),
    ("disabled", !previousConnectorState->JSON.Encode.bool),
  ]->Dict.fromArray
}

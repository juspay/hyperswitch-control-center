let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let getBillingConnectorDetails = (connectorList: array<ConnectorTypes.connectorPayloadV2>) => {
  let (mca, name) = switch connectorList->Array.get(0) {
  | Some(connectorDetails) => (connectorDetails.id, connectorDetails.connector_name)
  | _ => ("", "")
  }

  (mca, name)
}

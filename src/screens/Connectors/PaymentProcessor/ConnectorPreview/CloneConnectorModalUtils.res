open LogicUtils
open ConnectorTypes
open CommonAuthTypes

let getCloneConnectorPayload = (values, connectorInfo) => {
  let valuesDict = values->getDictFromJsonObject
  let request = {
    source_mca_id: connectorInfo.merchant_connector_id,
    source_profile_id: connectorInfo.profile_id,
    destination_profile_id: valuesDict->getString("destination_profile_id", ""),
    connector_label: valuesDict->getString("connector_label", "")->String.trim,
  }
  request->Identity.genericTypeToJson
}

let getCloneErrorMessage = errorCode =>
  switch errorCode {
  | UR_59 => "Connector label already exists."
  | _ => "Failed to clone connector."
  }

let getDestinationOptions = (profileList: array<OMPSwitchTypes.ompListTypes>, ~sourceProfileId) =>
  profileList->Array.filterMap(profile =>
    profile.id != sourceProfileId ? Some({SelectBox.label: profile.name, value: profile.id}) : None
  )

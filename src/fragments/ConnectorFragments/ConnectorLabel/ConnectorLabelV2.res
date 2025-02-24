@react.component
let make = (
  ~labelTextStyleClass="",
  ~labelClass="font-semibold",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayload,
) => {
  open LogicUtils
  open ConnectorHelperV2

  // let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
  // let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString
  // let selectedConnector = React.useMemo(() => {
  //   connectorTypeFromName->ConnectorUtils.getConnectorInfo
  // }, [connector])
  let labelFieldDict = ConnectorFragmentUtils.connectorLabelDetailField
  let label = labelFieldDict->getString("connector_label", "")

  // let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  if isInEditState {
    <>
      <FormRenderer.FieldRenderer
        labelClass
        field={FormRenderer.makeFieldInfo(
          ~label,
          ~name="connector_label",
          ~placeholder="Enter Connector Label name",
          ~customInput=InputFields.textInput(~customStyle="rounded-xl "),
          ~isRequired=true,
        )}
        labelTextStyleClass
      />
    </>
  } else {
    <InfoField label str={connectorInfo.connector_label} />
  }
}

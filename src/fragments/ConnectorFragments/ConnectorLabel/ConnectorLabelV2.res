@react.component
let make = (
  ~labelTextStyleClass="",
  ~labelClass="font-semibold",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayloadCommonType,
) => {
  open LogicUtils
  open ConnectorHelperV2

  let labelFieldDict = ConnectorFragmentUtils.connectorLabelDetailField
  let label = labelFieldDict->getString("connector_label", "")

  if isInEditState {
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
  } else {
    <InfoField label str={connectorInfo.connector_label} />
  }
}

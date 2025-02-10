module VaultLabelFormField = {
  @react.component
  let make = () => {
    open LogicUtils
    let labelFieldDict = ConnectorAuthKeyUtils.connectorLabelDetailField
    let label = labelFieldDict->getString("connector_label", "")
    <FormRenderer.FieldRenderer
      labelClass="font-semibold"
      field={FormRenderer.makeFieldInfo(
        ~label,
        ~name="connector_label",
        ~placeholder="Enter Connector Label name",
        ~customInput=InputFields.textInput(~customStyle="rounded-xl"),
        ~isRequired=true,
      )}
    />
  }
}

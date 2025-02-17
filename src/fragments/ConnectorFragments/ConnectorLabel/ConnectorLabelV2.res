@react.component
let make = (~labelTextStyleClass="", ~labelClass="font-semibold", ~isInEditState) => {
  open LogicUtils
  let labelFieldDict = ConnectorFragmentUtils.connectorLabelDetailField
  let label = labelFieldDict->getString("connector_label", "")
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
}

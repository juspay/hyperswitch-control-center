let getOptions: array<ConnectorTypes.connectorTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  open ConnectorUtils
  open ConnectorTypes

  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    connector
  ): SelectBox.dropdownOption => {
    let connectorValue = connector->getConnectorNameString
    let connectorName = switch connector {
    | Processors(connector) => connector->getDisplayNameForProcessor
    | _ => ""
    }

    {
      label: connectorName,
      value: connectorValue,
    }
  })
  options
}

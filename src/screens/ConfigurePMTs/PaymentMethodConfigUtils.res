let getAdvanceConfiguration = (
  advanceConfiguration: option<ConnectorTypes.advancedConfigurationList>,
) => {
  let config = switch advanceConfiguration {
  | Some(obj) => obj.list->Array.toString
  | None => ""
  }
  config
}

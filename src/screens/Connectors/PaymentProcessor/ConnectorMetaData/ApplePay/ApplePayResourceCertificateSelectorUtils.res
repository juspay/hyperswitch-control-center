open ApplePayIntegrationUtils
open LogicUtils

let getResourceIdFieldName = (~connector) =>
  applePayNameMapper(~name="resource_id", ~integrationType=Some(#manual), ~connector)

let getResourceLinkedFieldName = (~connector) =>
  applePayNameMapper(~name="resource_linked", ~integrationType=Some(#manual), ~connector)

let resourceField: CommonConnectorTypes.inputField = {
  name: "resource_id",
  label: "Certificate",
  placeholder: "Select certificate",
  required: false,
  options: [],
  \"type": Select,
}

let getButtonState = (
  ~isLoading,
  ~selectedResourceId,
  ~linkedResourceId,
  ~isLinking,
): Button.buttonState =>
  switch (
    !isLoading && selectedResourceId->isNonEmptyString && selectedResourceId !== linkedResourceId,
    isLinking,
  ) {
  | (true, true) => Loading
  | (true, false) => Normal
  | (false, _) => Disabled
  }

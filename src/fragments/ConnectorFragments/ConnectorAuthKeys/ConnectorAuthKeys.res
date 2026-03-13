@react.component
let make = (
  ~initialValues,
  ~showVertically=true,
  ~processorType=ConnectorTypes.Processor,
  ~updateAccountDetails=true,
) => {
  open LogicUtils
  open ConnectorAuthKeysHelper
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let form = ReactFinalForm.useForm()
  let connectorTypeFromName =
    connector->ConnectorUtils.getConnectorNameTypeFromString(~connectorType=processorType)

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let (bodyType, connectorAccountFields) = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = switch processorType {
        | Processor => Window.getConnectorConfig(connector)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connector)
        | ThreeDsAuthenticator => Window.getAuthenticationConnectorConfig(connector)
        | PMAuthenticationProcessor => Window.getPMAuthenticationProcessorConfig(connector)
        | TaxProcessor => Window.getTaxProcessorConfig(connector)
        | BillingProcessor => BillingProcessorsUtils.getConnectorConfig(connector)
        | VaultProcessor => Window.getConnectorConfig(connector)
        | FRMPlayer => JSON.Encode.null
        }
        let connectorAccountDict = dict->getDictFromJsonObject->getDictfromDict("connector_auth")
        let bodyType = connectorAccountDict->Dict.keysToArray->getValueFromArray(0, "")
        let connectorAccountFields = connectorAccountDict->getDictfromDict(bodyType)
        (bodyType, connectorAccountFields)
      } else {
        ("", Dict.make())
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR AUTH KEYS CONFIG", e)
        ("", Dict.make())
      }
    }
  }, [selectedConnector])

  React.useEffect(() => {
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject

    if updateAccountDetails {
      let acc =
        [("auth_type", bodyType->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object
      let _ = updatedValues->Dict.set("connector_account_details", acc)
    }

    form.reset(updatedValues->JSON.Encode.object->Nullable.make)

    None
  }, [connector])

  <ConnectorConfigurationFields
    connector={connectorTypeFromName} connectorAccountFields selectedConnector showVertically
  />
}

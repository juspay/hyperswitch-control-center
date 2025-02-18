@react.component
let make = (~initialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorAuthKeysHelper
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let form = ReactFinalForm.useForm()
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let (bodyType, connectorAccountFields) = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        let connectorAccountDict = dict->getDictFromJsonObject->getDictfromDict("connector_auth")
        let bodyType = connectorAccountDict->Dict.keysToArray->Array.get(0)->Option.getOr("")
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

  // let (bodyType, connectorAccountFields, _, _, _, _, _) = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let acc =
      [("auth_type", bodyType->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object

    let _ = updatedValues->Dict.set("connector_account_details", acc)
    form.reset(updatedValues->JSON.Encode.object->Nullable.make)

    None
  }, [connector])

  <ConnectorConfigurationFields
    connector={connectorTypeFromName} connectorAccountFields selectedConnector showVertically
  />
}

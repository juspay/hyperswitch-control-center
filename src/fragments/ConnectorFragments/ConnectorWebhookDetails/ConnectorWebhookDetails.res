@react.component
let make = (
  ~showVertically=true,
  ~labelTextStyleClass="",
  ~labelClass="font-semibold ",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayload,
) => {
  open LogicUtils
  open ConnectorFragmentUtils
  open ConnectorHelperV2
  let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)

        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        Dict.make()->JSON.Encode.object
      }
    }
  }, [selectedConnector])

  let (_, _, _, _, connectorWebHookDetails, _, _) = getConnectorFields(connectorDetails)
  let webHookDetails = connectorInfo.connector_webhook_details->getDictFromJsonObject
  let keys = connectorWebHookDetails->Dict.keysToArray
  <>
    {keys
    ->Array.mapWithIndex((field, index) => {
      let label = connectorWebHookDetails->getString(field, "")
      let value = webHookDetails->getString(field, "")

      <div key={index->Int.toString}>
        {if isInEditState {
          <RenderIf condition={label->String.length > 0}>
            <FormRenderer.FieldRenderer
              labelClass
              field={FormRenderer.makeFieldInfo(
                ~label,
                ~name={`connector_webhook_details.${field}`},
                ~placeholder={label},
                ~customInput=InputFields.textInput(~customStyle="rounded-xl "),
                ~isRequired=false,
              )}
              labelTextStyleClass
            />
          </RenderIf>
        } else {
          <InfoField label str={value} />
        }}
      </div>
    })
    ->React.array}
  </>
}

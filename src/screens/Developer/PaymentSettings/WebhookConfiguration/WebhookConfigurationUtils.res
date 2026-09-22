open WebhookConfigurationTypes
open LogicUtils

let statusOptionMapper = (dict): webhookStatusOption => {
  value: dict->getString("value", ""),
  eventType: dict->getString("event_type", ""),
}

let eventClassConfigMapper = (json): webhookEventClassConfig => {
  let dict = json->getDictFromJsonObject
  {
    eventClass: dict->getString("event_class", ""),
    apiField: dict->getString("api_field", ""),
    statuses: dict
    ->getArrayFromDict("statuses", [])
    ->Array.map(statusJson => statusJson->getDictFromJsonObject->statusOptionMapper),
  }
}

let getWebhookEventClassConfigs = () => {
  try {
    Window.getWebhookStatusConfig()->Array.map(eventClassConfigMapper)
  } catch {
  | Exn.Error(e) => {
      Js.log2("FAILED TO LOAD WEBHOOK STATUS CONFIG", e)
      []
    }
  | _ => []
  }
}

let resourceTitle = config => config.apiField->String.replace("_statuses_enabled", "")->snakeToTitle

let makeStatusField = (config: webhookEventClassConfig) => {
  let resourceTitle = config->resourceTitle
  let options = config.statuses->Array.map(status => status.value)->DeveloperUtils.makeOptions

  FormRenderer.makeFieldInfo(
    ~label=`${resourceTitle} Statuses`,
    ~name=`webhook_details.${config.apiField}`,
    ~customInput=InputFields.multiSelectInput(
      ~options,
      ~buttonText=`Select ${resourceTitle} Statuses`,
      ~showSelectionAsChips=false,
      ~customButtonStyle="!rounded-lg",
      ~fixedDropDownDirection=BottomRight,
      ~dropdownClassName="!max-h-15-rem !overflow-auto",
      ~searchable=true,
    ),
    ~description=`Choose the ${resourceTitle->String.toLowerCase} statuses that should trigger an outgoing webhook. Leave empty to send webhooks for every status.`,
    ~isRequired=false,
  )
}

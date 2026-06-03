type logType = SDK | API_EVENTS | WEBHOOKS | CONNECTOR | ROUTING

type pageType = [#PAYMENT | #REFUND | #DISPUTE | #PAYOUT]

type eventLogs = Logdetails | Request | Response | Event | Metadata | UnknownEvent

type logDetails = {
  response: string,
  request: string,
  data: Dict.t<JSON.t>,
}

type selectedObj = {
  value: int,
  optionType: logType,
}

type authOrigin = Sdk | Backend | Dashboard | Webhook | UnknownAuth

type originFilter = AllOrigins | SdkOrigin | BackendOrigin | DashboardOrigin | WebhookOrigin

type sdkFilter = AllSdk | SdkUserEvent | SdkApiCall

type webhookDirection = Incoming | Outgoing | NoDirection

type urls = {
  url: string,
  apiMethod: Fetch.requestMethod,
  body?: JSON.t,
}

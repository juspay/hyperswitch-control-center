type logType = SDK | API_EVENTS | WEBHOOKS | CONNECTOR

type pageType = [#PAYMENT | #REFUND]

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: int,
  optionType: logType,
}

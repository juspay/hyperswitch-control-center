type logType = SDK | PAYMENTS | WEBHOOKS | CONNECTOR

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: int,
  optionType: logType,
}

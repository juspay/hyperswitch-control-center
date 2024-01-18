type logType = SDK | PAYMENTS | WEBHOOKS

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: string,
  optionType: logType,
}

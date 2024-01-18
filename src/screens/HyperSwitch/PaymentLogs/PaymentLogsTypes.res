type logType = Sdk | Payment | Webhooks

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: string,
  optionType: logType,
}

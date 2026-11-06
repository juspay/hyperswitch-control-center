type webhookStatusOption = {
  value: string,
  eventType: string,
}

type webhookEventClassConfig = {
  eventClass: string,
  apiField: string,
  statuses: array<webhookStatusOption>,
}

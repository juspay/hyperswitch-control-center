type tabs = Request | Response

type webhookObject = {
  eventId: string,
  merchantId: string,
  profileId: string,
  objectId: string,
  eventType: string,
  eventClass: string,
  isDeliverySuccessful: bool,
  initialAttemptId: string,
  created: string,
}

type webhook = {
  events: array<webhookObject>,
  total_count: int,
}

type request = {
  body: string,
  headers: JSON.t,
}

type response = {
  body: string,
  errorMessage: option<string>,
  headers: JSON.t,
  statusCode: int,
}

type attemptType = {
  eventId: string,
  merchantId: string,
  profileId: string,
  objectId: string,
  eventType: string,
  eventClass: string,
  isDeliverySuccessful: bool,
  initialAttemptId: string,
  created: string,
  request: request,
  response: response,
  deliveryAttempt: string,
}

type attempts = array<attemptType>

type attemptTable = {
  isDeliverySuccessful: bool,
  deliveryAttempt: string,
  eventId: string,
  created: string,
}

type searchType = [#object_id | #event_id]

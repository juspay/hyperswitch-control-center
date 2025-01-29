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

type webhook = array<webhookObject>

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
  request: JSON.t,
  response: JSON.t,
  deliveryAttempt: string,
}

type attempts = array<attemptType>

type attemptTable = {
  isDeliverySuccessful: bool,
  deliveryAttempt: string,
  eventId: string,
  created: string,
}

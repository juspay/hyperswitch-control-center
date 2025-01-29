open WebhooksTypes
open LogicUtils

let itemToObjectMapper: dict<JSON.t> => webhookObject = dict => {
  eventId: dict->getString("event_id", ""),
  eventClass: dict->getString("event_class", ""),
  eventType: dict->getString("event_type", ""),
  merchantId: dict->getString("merchant_id", ""),
  profileId: dict->getString("profile_id", ""),
  objectId: dict->getString("object_id", ""),
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  initialAttemptId: dict->getString("initial_attempt_id", ""),
  created: dict->getString("created", ""),
}

let itemToObjectMapperAttempts: dict<JSON.t> => attemptType = dict => {
  eventId: dict->getString("event_id", ""),
  eventClass: dict->getString("event_class", ""),
  eventType: dict->getString("event_type", ""),
  merchantId: dict->getString("merchant_id", ""),
  profileId: dict->getString("profile_id", ""),
  objectId: dict->getString("object_id", ""),
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  initialAttemptId: dict->getString("initial_attempt_id", ""),
  created: dict->getString("created", ""),
  deliveryAttempt: dict->getString("delivery_attempt", ""),
  request: dict->getJsonObjectFromDict("request"),
  response: dict->getJsonObjectFromDict("response"),
}

let itemToObjectMapperAttemptsTable: dict<JSON.t> => attemptTable = dict => {
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  deliveryAttempt: dict->getString("delivery_attempt", ""),
  eventId: dict->getString("event_id", ""),
  created: dict->getString("created", ""),
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let initialFixedFilter = () => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey,
          ~endKey=endTimeFilterKey,
          ~format="YYYY-MM-DDTHH:mm:ss[Z]",
          ~showTime=false,
          ~disablePastDates={false},
          ~disableFutureDates={true},
          ~predefinedDays=[
            Hour(0.5),
            Hour(1.0),
            Hour(2.0),
            Today,
            Yesterday,
            Day(2.0),
            Day(7.0),
            Day(30.0),
            ThisMonth,
            LastMonth,
          ],
          ~numMonths=2,
          ~disableApply=false,
          ~dateRangeLimit=180,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

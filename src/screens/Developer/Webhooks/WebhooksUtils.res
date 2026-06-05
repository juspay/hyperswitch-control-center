open WebhooksTypes
open LogicUtils

let tabkeys: array<tabs> = [Request, Response]

let labelColor = (statusCode): TableUtils.labelColor => {
  switch statusCode {
  | 200 => LabelGreen
  | 400
  | 404
  | 422 =>
    LabelRed
  | 500 => LabelGray
  | _ => LabelGreen
  }
}

let subHeading = (~text, ~customClass="") =>
  <div className={`text-nd_gray-600 font-medium ${customClass}`}> {text->React.string} </div>

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

let requestMapper = json => {
  body: json->getDictFromJsonObject->getString("body", ""),
  headers: json->getDictFromJsonObject->getJsonObjectFromDict("headers"),
}

let responseMapper = json => {
  body: json->getDictFromJsonObject->getString("body", ""),
  headers: json->getDictFromJsonObject->getJsonObjectFromDict("headers"),
  errorMessage: json->getDictFromJsonObject->getString("error_message", "")->getNonEmptyString,
  statusCode: json->getDictFromJsonObject->getInt("status_code", 0),
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
  request: dict->getJsonObjectFromDict("request")->requestMapper,
  response: dict->getJsonObjectFromDict("response")->responseMapper,
}

let itemToObjectMapperAttemptsTable: dict<JSON.t> => attemptTable = dict => {
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  deliveryAttempt: dict->getString("delivery_attempt", ""),
  eventId: dict->getString("event_id", ""),
  created: dict->getString("created", ""),
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let getAllowedDateRange = {
  let endDate = Date.now()->Js.Date.fromFloat->DateTimeUtils.toUtc->DayJs.getDayJsForJsDate //->Date.toISOString->JSON.Encode.string
  let startDate = endDate.subtract(90, "day")

  let dateObject: Calendar.dateObj = {
    startDate: startDate.toString(),
    endDate: endDate.toString(),
  }
  dateObject
}

// Type for filter options
type filterOptions = {
  eventClasses: array<dict<string>>,
  eventTypes: array<dict<string>>,
  deliveryStatusOptions: array<dict<string>>,
}

let initialFixedFilter = (~filterOptions: filterOptions) => [
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
          ~dateRangeLimit=90,
          ~allowedDateRange=getAllowedDateRange,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
  // Event Class filter
  (
    {
      localFilter: None,
      field: FormRenderer.makeFieldInfo(
        ~label="Event Class",
        ~name="event_classes",
        ~customInput=InputFields.multiSelectInput(
          ~options=filterOptions.eventClasses,
          ~showSelectionAsChips=true,
          ~searchable=true,
          ~showClearAll=true,
          (),
        ),
      ),
    }: EntityType.initialFilters<'t>
  ),
  // Event Type filter
  (
    {
      localFilter: None,
      field: FormRenderer.makeFieldInfo(
        ~label="Event Type",
        ~name="event_types",
        ~customInput=InputFields.multiSelectInput(
          ~options=filterOptions.eventTypes,
          ~showSelectionAsChips=true,
          ~searchable=true,
          ~showClearAll=true,
          (),
        ),
      ),
    }: EntityType.initialFilters<'t>
  ),
  // Delivery Status filter
  (
    {
      localFilter: None,
      field: FormRenderer.makeFieldInfo(
        ~label="Delivery Status",
        ~name="delivery_status",
        ~customInput=InputFields.singleSelectInput(
          ~options=filterOptions.deliveryStatusOptions,
          ~showClearSelection=true,
          (),
        ),
      ),
    }: EntityType.initialFilters<'t>
  ),
]

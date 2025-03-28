open WebhooksTypes
open LogicUtils

let tabkeys: array<tabs> = [Request, Response]

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

let setData = (
  ~offset,
  ~setOffset,
  ~total,
  ~data,
  ~setTotalCount,
  ~setWebhooksData,
  ~setScreenState,
) => {
  let arr = Array.make(~length=offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let webhookDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
    let webhookData =
      arr
      ->Array.concat(webhookDictArr)
      ->Array.map(itemToObjectMapper)

    let list = webhookData
    setTotalCount(_ => total)
    setWebhooksData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let fetchWebhooks = async (
  ~getURL: APIUtilsTypes.getUrlTypes,
  ~fetchDetails: (string, ~version: UserInfoTypes.version=?) => promise<JSON.t>,
  ~filterValueJson,
  ~offset,
  ~setOffset,
  ~searchText,
  ~setScreenState,
  ~setWebhooksData,
  ~setTotalCount,
) => {
  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
    let start_time = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
    let end_time = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

    let queryParamerters = `limit=50&offset=${offset->Int.toString}&created_after=${start_time}&created_before=${end_time}`

    let queryParam = searchText->isEmptyString ? queryParamerters : `&object_id=${searchText}`

    let url = getURL(
      ~entityName=V1(WEBHOOK_EVENTS),
      ~methodType=Get,
      ~queryParamerters=Some(queryParam),
    )
    let response = await fetchDetails(url)

    let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
    let events = response->getDictFromJsonObject->getArrayFromDict("events", [])

    if events->Array.length > 0 {
      setData(
        ~offset,
        ~setOffset,
        ~total=totalCount,
        ~data=events,
        ~setTotalCount,
        ~setWebhooksData,
        ~setScreenState,
      )
      setScreenState(_ => Success)
    } else {
      setScreenState(_ => Custom)
    }
  } catch {
  | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
  }
}

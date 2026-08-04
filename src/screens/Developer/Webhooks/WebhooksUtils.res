open WebhooksTypes
open LogicUtils

let tabkeys: array<tabs> = [Request, Response]

let eventRecipientToString = recipient =>
  switch recipient {
  | Merchant => "merchant"
  | Connector => "connector"
  }

let eventClassToString = eventClass =>
  switch eventClass {
  | Payments => "payments"
  | Refunds => "refunds"
  | Disputes => "disputes"
  | Mandates => "mandates"
  | Payouts => "payouts"
  | Subscriptions => "subscriptions"
  }

let allEventClasses = [Payments, Refunds, Disputes, Mandates, Payouts, Subscriptions]

let webhookEventTypeToString = eventType =>
  switch eventType {
  | PaymentSucceeded => "payment_succeeded"
  | PaymentFailed => "payment_failed"
  | PaymentProcessing => "payment_processing"
  | PaymentCancelled => "payment_cancelled"
  | PaymentCancelledPostCapture => "payment_cancelled_post_capture"
  | PaymentAuthorized => "payment_authorized"
  | PaymentCaptured => "payment_captured"
  | PaymentExpired => "payment_expired"
  | ActionRequired => "action_required"
  | SurchargePaymentSucceeded => "surcharge_payment_succeeded"
  | RefundSucceeded => "refund_succeeded"
  | RefundFailed => "refund_failed"
  | SurchargeRefundSucceeded => "surcharge_refund_succeeded"
  | DisputeOpened => "dispute_opened"
  | DisputeExpired => "dispute_expired"
  | DisputeAccepted => "dispute_accepted"
  | DisputeCancelled => "dispute_cancelled"
  | DisputeChallenged => "dispute_challenged"
  | DisputeWon => "dispute_won"
  | DisputeLost => "dispute_lost"
  | MandateActive => "mandate_active"
  | MandateRevoked => "mandate_revoked"
  | PayoutSuccess => "payout_success"
  | PayoutFailed => "payout_failed"
  | PayoutInitiated => "payout_initiated"
  | PayoutProcessing => "payout_processing"
  | PayoutCancelled => "payout_cancelled"
  | PayoutExpired => "payout_expired"
  | PayoutReversed => "payout_reversed"
  | InvoicePaid => "invoice_paid"
  }

let eventTypesForClass = eventClass =>
  switch eventClass {
  | Payments => [
      PaymentSucceeded,
      PaymentFailed,
      PaymentProcessing,
      PaymentCancelled,
      PaymentCancelledPostCapture,
      PaymentAuthorized,
      PaymentCaptured,
      PaymentExpired,
      ActionRequired,
      SurchargePaymentSucceeded,
    ]
  | Refunds => [RefundSucceeded, RefundFailed, SurchargeRefundSucceeded]
  | Disputes => [
      DisputeOpened,
      DisputeExpired,
      DisputeAccepted,
      DisputeCancelled,
      DisputeChallenged,
      DisputeWon,
      DisputeLost,
    ]
  | Mandates => [MandateActive, MandateRevoked]
  | Payouts => [
      PayoutSuccess,
      PayoutFailed,
      PayoutInitiated,
      PayoutProcessing,
      PayoutCancelled,
      PayoutExpired,
      PayoutReversed,
    ]
  | Subscriptions => [InvoicePaid]
  }

let allWebhookEventTypes = allEventClasses->Array.flatMap(eventTypesForClass)

let eventClassFilterKey = "event_classes"
let eventTypeFilterKey = "event_types"

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
          ~dateRangeLimit=90,
          ~allowedDateRange=getAllowedDateRange,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let webhookLocalFilters = (): array<EntityType.initialFilters<'t>> => [
  {
    field: FormRenderer.makeFieldInfo(
      ~label="Event Class",
      ~name=eventClassFilterKey,
      ~customInput=InputFields.filterMultiSelectInput(
        ~options=allEventClasses
        ->Array.map(eventClassToString)
        ->FilterSelectBox.makeOptions(~isTitle=true),
        ~buttonText="Event Class",
        ~showSelectionAsChips=false,
        ~searchable=true,
        (),
      ),
    ),
    localFilter: None,
  },
  {
    field: FormRenderer.makeFieldInfo(
      ~label="Event Type",
      ~name=eventTypeFilterKey,
      ~customInput=InputFields.filterMultiSelectInput(
        ~options=allWebhookEventTypes
        ->Array.map(webhookEventTypeToString)
        ->FilterSelectBox.makeOptions(~isTitle=true),
        ~buttonText="Event Type",
        ~showSelectionAsChips=false,
        ~searchable=true,
        (),
      ),
    ),
    localFilter: None,
  },
]

let restrictEventTypesToClasses = (~eventClasses: array<eventClass>, ~eventTypes: array<string>) => {
  if eventClasses->isEmptyArray {
    eventTypes
  } else {
    let allowed =
      eventClasses
      ->Array.flatMap(eventTypesForClass)
      ->Array.map(webhookEventTypeToString)
    eventTypes->Array.filter(eventType => allowed->Array.includes(eventType))
  }
}

let stringToEventClass = str =>
  allEventClasses->Array.find(eventClass => eventClass->eventClassToString === str)

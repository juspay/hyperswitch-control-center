open WebhooksTypes

type colType =
  | EventId
  | EventClass
  | EventType
  | MerchantId
  | ProfileId
  | ObjectId
  | IsDeliverySuccessful
  | InitialAttemptId
  | Created

let defaultColumns = [
  EventId,
  ObjectId,
  ProfileId,
  EventClass,
  EventType,
  IsDeliverySuccessful,
  Created,
]

let getHeading = colType => {
  switch colType {
  | EventId => Table.makeHeaderInfo(~key="event_id", ~title="Event Id")
  | EventClass => Table.makeHeaderInfo(~key="event_class", ~title="Event Class")
  | EventType => Table.makeHeaderInfo(~key="event_type", ~title="Event Type")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant Id")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id")
  | ObjectId => Table.makeHeaderInfo(~key="object_id", ~title="Object Id")
  | IsDeliverySuccessful =>
    Table.makeHeaderInfo(~key="is_delivery_successful", ~title="Delivery Status")
  | InitialAttemptId => Table.makeHeaderInfo(~key="initial_attempt_id", ~title="Initial Attempt Id")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  }
}

let getCell = (webhook: webhookObject, colType): Table.cell => {
  switch colType {
  | EventId => DisplayCopyCell(webhook.eventId)
  | EventClass => Text(webhook.eventClass)
  | EventType => Text(webhook.eventType)
  | MerchantId => Text(webhook.merchantId)
  | ProfileId => Text(webhook.profileId)
  | ObjectId => DisplayCopyCell(webhook.objectId)
  | IsDeliverySuccessful =>
    Text(webhook.isDeliverySuccessful->LogicUtils.getStringFromBool->LogicUtils.capitalizeString)
  | InitialAttemptId => DisplayCopyCell(webhook.initialAttemptId)
  | Created => Date(webhook.created)
  }
}

let webhooksEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    ~getShowLink={
      webhook =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${webhook.initialAttemptId}`),
          ~authorization,
        )
    },
  )
}

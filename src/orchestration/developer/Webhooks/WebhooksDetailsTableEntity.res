open WebhooksTypes

type colType =
  | IsDeliverySuccessful
  | DeliveryAttempt
  | EventId
  | Created

let defaultColumns = [IsDeliverySuccessful, DeliveryAttempt, Created]

let getHeading = colType => {
  switch colType {
  | IsDeliverySuccessful =>
    Table.makeHeaderInfo(~key="is_delivery_successful", ~title="Delivery Status")
  | DeliveryAttempt => Table.makeHeaderInfo(~key="delivery_attempt", ~title="Delivery Attempt")
  | EventId => Table.makeHeaderInfo(~key="event_id", ~title="Event Id")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  }
}

let getCell = (webhook: attemptTable, colType): Table.cell => {
  switch colType {
  | IsDeliverySuccessful =>
    Text(webhook.isDeliverySuccessful->LogicUtils.getStringFromBool->LogicUtils.capitalizeString)
  | DeliveryAttempt => Text(webhook.deliveryAttempt)
  | EventId => DisplayCopyCell(webhook.eventId)
  | Created => Date(webhook.created)
  }
}

let webhooksDetailsEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
  )
}

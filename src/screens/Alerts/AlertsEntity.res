open LogicUtils
open AlertsTypes
open AlertsUtils

let defaultColumns: array<colType> = [
  AlertDate,
  AlertType,
  AlertProduct,
  AlertDuration,
  AlertPriority,
  AlertMerchantId,
  AlertProfileId,
]

let allColumns: array<colType> =
  defaultColumns->Array.concat([AlertConnector, AlertStatus, AlertAttribution])

let getHeading = (colType: colType) =>
  switch colType {
  | AlertDate => Table.makeHeaderInfo(~key="ts_alert", ~title="Date")
  | AlertType => Table.makeHeaderInfo(~key="name", ~title="Type")
  | AlertProduct => Table.makeHeaderInfo(~key="product", ~title="Product")
  | AlertDuration => Table.makeHeaderInfo(~key="duration", ~title="Duration")
  | AlertPriority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  | AlertMerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | AlertProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile ID")
  | AlertConnector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | AlertStatus => Table.makeHeaderInfo(~key="status", ~title="Status")
  | AlertAttribution => Table.makeHeaderInfo(~key="attribution", ~title="Attribution")
  }

let placeholderIfEmpty = value => value->isNonEmptyString ? value : "-"

let getCell = (alert: alert, colType: colType): Table.cell =>
  switch colType {
  | AlertDate => Date(alert.tsAlert)
  | AlertType => EllipsisText(alert.name, "w-fit")
  | AlertProduct => Text(alert.product->placeholderIfEmpty)
  | AlertDuration => EllipsisText(formatDuration(alert.startTime, alert.endTime), "w-fit")
  | AlertPriority =>
    Label({
      title: (alert.priority :> string),
      color: alert.priority->priorityToLabelColor,
    })
  | AlertMerchantId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-32 truncate whitespace-nowrap"
        displayValue={Some(alert.merchantId)}
        copyValue={Some(alert.merchantId)}
        showTooltip=true
      />,
      "",
    )
  | AlertProfileId => Text(alert.profileId->placeholderIfEmpty)
  | AlertConnector => Text(alert.connector->placeholderIfEmpty)
  | AlertStatus => {
      let isActive = alert.endTime->isEmptyString
      Label({title: isActive ? "Active" : "Inactive", color: isActive ? LabelGreen : LabelGray})
    }
  | AlertAttribution => EllipsisText(alert.attribution, "w-64")
  }

let alertsEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
)

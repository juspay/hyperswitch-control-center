open AlertsTypes
open LogicUtils
open AlertsUtils
open AlertsHelper

let defaultColumns: array<colType> = [
  AlertDate,
  AlertType,
  AlertProduct,
  AlertBlacklisted,
  AlertSnoozeStatus,
  AlertDuration,
  AlertPriority,
  AlertMerchantId,
  AlertProfileId,
]

let allColumns: array<colType> =
  defaultColumns->Array.concat([AlertConnector, AlertStatus, AlertAttribution])

let getHeading = (colType: colType) =>
  switch colType {
  | AlertDate => Table.makeHeaderInfo(~key="tsAlert", ~title="Date")
  | AlertType => Table.makeHeaderInfo(~key="name", ~title="Type")
  | AlertProduct => Table.makeHeaderInfo(~key="product", ~title="Product")
  | AlertBlacklisted => Table.makeHeaderInfo(~key="isBlacklisted", ~title="Blacklisted")
  | AlertSnoozeStatus => Table.makeHeaderInfo(~key="isSnoozed", ~title="Snooze Status")
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
  | AlertDate =>
    CustomCell(
      <TableUtils.DateCell timestamp=alert.tsAlert textAlign={TableUtils.Left} />,
      alert.tsAlert,
    )
  | AlertType => EllipsisText(alert.name, "w-52")
  | AlertProduct => Text(alert.product->placeholderIfEmpty)
  | AlertBlacklisted => {
      let text = (alert.isBlacklisted ? Blacklisted : NotBlacklisted :> string)
      CustomCell(
        <div className="flex items-center gap-1.5 min-w-max">
          <TableUtils.LabelCell labelColor={alert.isBlacklisted ? LabelRed : LabelGreen} text />
          <BlacklistScopeTooltip
            isBlacklisted=alert.isBlacklisted fields={alert->getBlacklistFields}
          />
        </div>,
        text,
      )
    }
  | AlertSnoozeStatus => {
      let entry = alert->getSnoozeEntry
      CustomCell(
        <div className="flex items-center gap-1.5 min-w-max">
          <TableUtils.LabelCell
            labelColor={alert.isSnoozed ? LabelOrange : LabelBlue}
            text={alert.isSnoozed ? "Snoozed" : "Not Snoozed"}
          />
          <SnoozeWindowTooltip
            hasSnooze=alert.isSnoozed
            startTime={entry->getString("snooze_start_time", "")}
            endTime={entry->getString("snooze_end_time", "")}
          />
        </div>,
        alert.isSnoozed ? "true" : "false",
      )
    }
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
  ~getShowLink={
    alert =>
      GlobalVars.appendDashboardPath(
        ~url=`/alerts-business-insights/${alert.id->encodeURIComponent}`,
      )
  },
)

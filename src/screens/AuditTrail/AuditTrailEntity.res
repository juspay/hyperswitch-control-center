open AuditTrailUtils
open LogicUtils

type colType =
  | Timestamp
  | User
  | Email
  | Action
  | Merchant
  | Status

let defaultColumns = [Timestamp, User, Email, Action, Merchant, Status]

let getHeading = colType => {
  switch colType {
  | Timestamp => Table.makeHeaderInfo(~key="created_at", ~title="Timestamp")
  | User => Table.makeHeaderInfo(~key="user_name", ~title="User")
  | Email => Table.makeHeaderInfo(~key="user_email", ~title="Email")
  | Action => Table.makeHeaderInfo(~key="api_flow", ~title="Action")
  | Merchant => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant")
  | Status => Table.makeHeaderInfo(~key="status_code", ~title="Status")
  }
}

let getCell = (activityLog: activityLogEntry, colType): Table.cell => {
  switch colType {
  | Timestamp => Date(activityLog.createdAt)
  | User => Text(activityLog.userName->isNonEmptyString ? activityLog.userName : activityLog.userId)
  | Email => Text(activityLog.userEmail->isNonEmptyString ? activityLog.userEmail : "-")
  | Action => Text(activityLog.apiFlow->actionLabel)
  | Merchant =>
    Text(activityLog.merchantId->isNonEmptyString ? activityLog.merchantId : "Organization")
  | Status =>
    Label({
      title: activityLog.statusCode < 300 ? "SUCCESS" : "FAILED",
      color: activityLog.statusCode < 300 ? LabelGreen : LabelRed,
    })
  }
}

let auditTrailEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects=_ => [],
  ~defaultColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
)

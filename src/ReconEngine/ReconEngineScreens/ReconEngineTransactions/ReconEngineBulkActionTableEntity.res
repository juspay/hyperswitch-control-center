open Table
open ReconEngineTransactionsTypes

type bulkActionSummaryColType =
  | LogicalId
  | Status
  | StatusDetail
  | ViewDetails

let bulkActionAllSummaryColumns: array<bulkActionSummaryColType> = [
  LogicalId,
  Status,
  StatusDetail,
  ViewDetails,
]

let bulkActionTransformedEntryDefaultColumns: array<bulkActionSummaryColType> = [
  LogicalId,
  Status,
  StatusDetail,
]

let getBulkActionSummaryHeading = (colType: bulkActionSummaryColType) => {
  switch colType {
  | LogicalId => makeHeaderInfo(~key="logical_id", ~title="ID")
  | Status => makeHeaderInfo(~key="status", ~title="Status")
  | StatusDetail => makeHeaderInfo(~key="status_detail", ~title="Status Detail")
  | ViewDetails => makeHeaderInfo(~key="view_details", ~title="", ~customWidth="!w-40")
  }
}

let getBulkActionStatusLabel = (status: bulkActionStatusType) => {
  Table.Label({
    title: (status :> string)->String.toUpperCase,
    color: switch status {
    | BulkActionSuccess => LabelGreen
    | BulkActionFailed => LabelRed
    | BulkActionSkipped => LabelOrange
    | UnknownBulkActionStatus => LabelLightGray
    },
  })
}

let getBulkActionSummaryCell = (
  bulkActionResponse: bulkActionResponse,
  colType: bulkActionSummaryColType,
) => {
  switch colType {
  | LogicalId => DisplayCopyCell(bulkActionResponse.logical_id->Option.getOr(""))
  | Status => getBulkActionStatusLabel(bulkActionResponse.bulk_action_status)
  | StatusDetail => EllipsisText(bulkActionResponse.bulk_action_status_detail->Option.getOr(""), "")
  | ViewDetails =>
    CustomCell(
      <RenderIf condition={bulkActionResponse.logical_id->Option.isSome}>
        <Link
          className="text-nd_primary_blue-600 underline hover:text-nd_primary_blue-700 w-fit whitespace-nowrap"
          to_={GlobalVars.appendDashboardPath(
            ~url=`/v1/recon-engine/transactions/${bulkActionResponse.logical_id->Option.getOr("")}`,
          )}>
          {"View Details"->React.string}
        </Link>
      </RenderIf>,
      "!w-fit whitespace-nowrap",
    )
  }
}

let bulkActionTransactionSummaryLoadedTableEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=bulkActionAllSummaryColumns,
    ~allColumns=bulkActionAllSummaryColumns,
    ~getHeading=getBulkActionSummaryHeading,
    ~getCell=getBulkActionSummaryCell,
    ~dataKey="bulk_action_summary",
  )
}

let bulkActionTransformedEntrySummaryLoadedTableEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=bulkActionTransformedEntryDefaultColumns,
    ~allColumns=bulkActionAllSummaryColumns,
    ~getHeading=getBulkActionSummaryHeading,
    ~getCell=getBulkActionSummaryCell,
    ~dataKey="bulk_action_summary",
  )
}

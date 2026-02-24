open Table
open ReconEngineTransactionsTypes

type bulkActionSummaryColType =
  | EntityId
  | Status
  | StatusDetail
  | ViewDetails

let bulkActionSummaryColumns: array<bulkActionSummaryColType> = [
  EntityId,
  Status,
  StatusDetail,
  ViewDetails,
]

let getBulkActionSummaryHeading = (colType: bulkActionSummaryColType) => {
  switch colType {
  | EntityId => makeHeaderInfo(~key="entity_id", ~title="ID")
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
  | EntityId => DisplayCopyCell(bulkActionResponse.entity_id)
  | Status => getBulkActionStatusLabel(bulkActionResponse.bulk_action_status)
  | StatusDetail => EllipsisText(bulkActionResponse.bulk_action_status_detail->Option.getOr(""), "")
  | ViewDetails =>
    CustomCell(
      <Link
        className="text-nd_primary_blue-600 underline hover:text-nd_primary_blue-700 w-fit whitespace-nowrap"
        to_={GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/transactions/${bulkActionResponse.entity_id}`,
        )}>
        {"View Details"->React.string}
      </Link>,
      "!w-fit whitespace-nowrap",
    )
  }
}

let bulkActionSummaryLoadedTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=bulkActionSummaryColumns,
    ~allColumns=bulkActionSummaryColumns,
    ~getHeading=getBulkActionSummaryHeading,
    ~getCell=getBulkActionSummaryCell,
    ~dataKey="bulk_action_summary",
    ~getShowLink={
      bulkActionResponse => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${bulkActionResponse.entity_id}`),
          ~authorization,
        )
      }
    },
  )
}

open BlocklistTypes
open BlocklistUtils

let defaultColumns = [
  JobId,
  Status,
  TotalRows,
  SucceededRows,
  FailedRows,
  CreatedAt,
  UpdatedAt,
  Actions,
]

let getHeading = colType => {
  switch colType {
  | JobId => Table.makeHeaderInfo(~key="job_id", ~title="Job ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~dataType=LabelType)
  | TotalRows => Table.makeHeaderInfo(~key="total_rows", ~title="Total Rows")
  | SucceededRows => Table.makeHeaderInfo(~key="succeeded_rows", ~title="Succeeded")
  | FailedRows => Table.makeHeaderInfo(~key="failed_rows", ~title="Failed")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | UpdatedAt => Table.makeHeaderInfo(~key="updated_at", ~title="Updated At")
  | Actions => Table.makeHeaderInfo(~key="", ~title="")
  }
}

let getCell = (~onRefreshJob, job: blocklistBatchJob, colType): Table.cell => {
  switch colType {
  | JobId => DisplayCopyCell(job.job_id)
  | Status => Label({title: job.status->normalizeStatus, color: job.status->statusLabelColor})
  | TotalRows => Text(job.total_rows->Int.toString)
  | SucceededRows => Text(job.succeeded_rows->Int.toString)
  | FailedRows => Text(job.failed_rows->Int.toString)
  | CreatedAt => Date(job.created_at)
  | UpdatedAt => Date(job.updated_at)
  | Actions =>
    Table.CustomCell(
      <Button
        text="Refresh"
        buttonType=Secondary
        buttonSize=Small
        onClick={_ => onRefreshJob(job.job_id)->ignore}
        buttonState={job.status->isTerminalStatus ? Button.Disabled : Button.Normal}
      />,
      "",
    )
  }
}

let blocklistEntity = (~onRefreshJob) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell={(job, colType) => getCell(~onRefreshJob, job, colType)},
    ~dataKey="",
  )
}
